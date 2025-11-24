import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';
import '../models/cart_item.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create a new order with enhanced structure
  Future<String> createOrder({
    required List<CartItem> items,
    required String userId,
    required String userName,
    required String userPhone,
    required String address,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    try {
      // Generate order ID with timestamp
      final timestamp = DateTime.now();
      final orderId = 'ORD-${timestamp.millisecondsSinceEpoch}';

      // Calculate totals
      final subtotal = items.fold<double>(
          0, (sum, item) => sum + (item.item.salePrice1 * item.quantity)
      );
      final tax = 0.0; // Add tax calculation if needed
      final shipping = 0.0; // Free shipping
      final totalAmount = subtotal + tax + shipping;

      // Create order items with complete details
      final orderItems = items.map((cartItem) => {
        'productId': cartItem.item.id,
        'productName': cartItem.item.name,
        'quantity': cartItem.quantity,
        'unitPrice': cartItem.item.salePrice1,
        'totalPrice': cartItem.item.salePrice1 * cartItem.quantity,
        'thumbnail': cartItem.item.thumbnail,
        'currency': cartItem.item.currencySymbol,
      }).toList();

      // Create order data with organized structure
      final orderData = {
        // Order Information
        'orderId': orderId,
        'orderNumber': orderId.substring(4), // Numeric part only
        'status': 'pending',
        'paymentStatus': 'pending',
        'paymentMethod': 'cash_on_delivery',

        // Customer Information
        'customer': {
          'userId': userId,
          'name': userName,
          'phone': userPhone,
          'email': '', // Add if available
        },

        // Delivery Information
        'delivery': {
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'deliveryStatus': 'pending',
          'deliveryDate': null,
          'deliveryTime': null,
          'deliveryNotes': notes ?? '',
        },

        // Order Items
        'items': orderItems,
        'itemCount': items.length,
        'totalQuantity': items.fold<int>(0, (sum, item) => sum + item.quantity),

        // Pricing Information
        'pricing': {
          'subtotal': subtotal,
          'tax': tax,
          'shipping': shipping,
          'discount': 0.0,
          'total': totalAmount,
          'currency': 'د.ع',
        },

        // Timestamps
        'timestamps': {
          'created': FieldValue.serverTimestamp(),
          'updated': FieldValue.serverTimestamp(),
          'confirmed': null,
          'processed': null,
          'shipped': null,
          'delivered': null,
          'cancelled': null,
        },

        // Additional Information
        'metadata': {
          'platform': 'mobile_app',
          'appVersion': '1.0.0',
          'deviceInfo': '', // Add device info if needed
        },

        // Admin Notes (for control panel)
        'adminNotes': '',
        'isRead': false, // For admin notifications
        'isPriority': false,
      };

      // Create batch for atomic operations
      final batch = _firestore.batch();

      // 1. Save to main orders collection
      batch.set(
        _firestore.collection('orders').doc(orderId),
        orderData,
      );

      // 2. Save to user's orders subcollection
      batch.set(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(orderId),
        orderData,
      );

      // 3. Create order in pending_orders collection for admin
      batch.set(
        _firestore.collection('pending_orders').doc(orderId),
        {
          ...orderData,
          'requiresAction': true,
        },
      );

      // 4. Update inventory for each item
      for (var item in items) {
        final itemRef = _firestore.collection('items1').doc(item.item.id);
        batch.update(itemRef, {
          'lastUpdated': FieldValue.serverTimestamp(),
          'lastSoldAt': FieldValue.serverTimestamp(),
        });
      }

      // 5. Create admin notification
      batch.set(
        _firestore.collection('admin_notifications').doc(),
        {
          'type': 'new_order',
          'orderId': orderId,
          'customerName': userName,
          'totalAmount': totalAmount,
          'itemCount': items.length,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'priority': 'high',
          'message': 'طلب جديد من ${userName}',
        },
      );

      // 6. Update statistics (create document if it doesn't exist)
      final statsRef = _firestore.collection('statistics').doc('orders');
      final statsDoc = await statsRef.get();

      if (statsDoc.exists) {
        batch.update(statsRef, {
          'totalOrders': FieldValue.increment(1),
          'pendingOrders': FieldValue.increment(1),
          'totalRevenue': FieldValue.increment(totalAmount),
          'lastOrderAt': FieldValue.serverTimestamp(),
        });
      } else {
        batch.set(statsRef, {
          'totalOrders': 1,
          'pendingOrders': 1,
          'totalRevenue': totalAmount,
          'lastOrderAt': FieldValue.serverTimestamp(),
        });
      }

      // Commit all operations
      await batch.commit();

      return orderId;
    } catch (e) {
      print('Error creating order: $e');
      throw Exception('فشل إنشاء الطلب: ${e.toString()}');
    }
  }

  // Get user orders stream
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('orders')
        .orderBy('timestamps.created', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          // Convert the new structure to OrderModel
          return OrderModel(
            id: data['orderId'] ?? doc.id,
            userId: data['customer']['userId'] ?? userId,
            userName: data['customer']['name'] ?? 'Unknown',
            userPhone: data['customer']['phone'] ?? 'Unknown',
            items: (data['items'] as List).map((item) => OrderItem(
              productId: item['productId'] ?? '',
              productName: item['productName'] ?? '',
              quantity: item['quantity'] ?? 0,
              price: (item['unitPrice'] ?? 0).toDouble(),
              thumbnail: item['thumbnail'],
            )).toList(),
            totalAmount: (data['pricing']['total'] ?? 0).toDouble(),
            status: data['status'] ?? 'pending',
            deliveryAddress: data['delivery']['address'] ?? '',
            latitude: data['delivery']['latitude']?.toDouble(),
            longitude: data['delivery']['longitude']?.toDouble(),
            createdAt: (data['timestamps']['created'] as Timestamp).toDate(),
            notes: data['delivery']['deliveryNotes'],
          );
        } catch (e) {
          print('Error parsing order ${doc.id}: $e');
          // Return a default order in case of error
          return OrderModel(
            id: doc.id,
            userId: userId,
            userName: 'Unknown',
            userPhone: 'Unknown',
            items: [],
            totalAmount: 0,
            status: 'error',
            deliveryAddress: 'Unknown',
            createdAt: DateTime.now(),
          );
        }
      }).toList();
    });
  }

  // Get single order
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();

      if (doc.exists) {
        final data = doc.data()!;
        return OrderModel(
          id: data['orderId'] ?? orderId,
          userId: data['customer']['userId'] ?? '',
          userName: data['customer']['name'] ?? '',
          userPhone: data['customer']['phone'] ?? '',
          items: (data['items'] as List).map((item) => OrderItem(
            productId: item['productId'] ?? '',
            productName: item['productName'] ?? '',
            quantity: item['quantity'] ?? 0,
            price: (item['unitPrice'] ?? 0).toDouble(),
            thumbnail: item['thumbnail'],
          )).toList(),
          totalAmount: (data['pricing']['total'] ?? 0).toDouble(),
          status: data['status'] ?? 'pending',
          deliveryAddress: data['delivery']['address'] ?? '',
          latitude: data['delivery']['latitude']?.toDouble(),
          longitude: data['delivery']['longitude']?.toDouble(),
          createdAt: (data['timestamps']['created'] as Timestamp).toDate(),
          notes: data['delivery']['deliveryNotes'],
        );
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      return null;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final batch = _firestore.batch();
      final timestamp = FieldValue.serverTimestamp();

      // Get order details first
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (!orderDoc.exists) throw Exception('Order not found');

      final orderData = orderDoc.data()!;
      final userId = orderData['customer']['userId'];

      // Update main order collection
      batch.update(
        _firestore.collection('orders').doc(orderId),
        {
          'status': newStatus,
          'timestamps.updated': timestamp,
          'timestamps.$newStatus': timestamp,
        },
      );

      // Update user's order subcollection
      batch.update(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('orders')
            .doc(orderId),
        {
          'status': newStatus,
          'timestamps.updated': timestamp,
          'timestamps.$newStatus': timestamp,
        },
      );

      // Update pending_orders collection
      if (newStatus != 'pending') {
        batch.delete(_firestore.collection('pending_orders').doc(orderId));
      }

      // Add status history
      batch.set(
        _firestore
            .collection('orders')
            .doc(orderId)
            .collection('statusHistory')
            .doc(),
        {
          'status': newStatus,
          'timestamp': timestamp,
          'updatedBy': _auth.currentUser?.uid ?? 'system',
        },
      );

      // Update statistics
      if (newStatus == 'delivered') {
        batch.update(
          _firestore.collection('statistics').doc('orders'),
          {
            'pendingOrders': FieldValue.increment(-1),
            'deliveredOrders': FieldValue.increment(1),
          },
        );
      } else if (newStatus == 'cancelled') {
        batch.update(
          _firestore.collection('statistics').doc('orders'),
          {
            'pendingOrders': FieldValue.increment(-1),
            'cancelledOrders': FieldValue.increment(1),
            'totalRevenue': FieldValue.increment(-orderData['pricing']['total']),
          },
        );
      }

      await batch.commit();
    } catch (e) {
      print('Error updating order status: $e');
      throw Exception('فشل تحديث حالة الطلب: ${e.toString()}');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      // Get order details
      final order = await getOrder(orderId);
      if (order == null) throw Exception('الطلب غير موجود');

      // Check if order can be cancelled
      if (order.status != 'pending' && order.status != 'processing') {
        throw Exception('لا يمكن إلغاء الطلب في هذه المرحلة');
      }

      // Update order status
      await updateOrderStatus(orderId, 'cancelled');

      // Restore inventory
      final batch = _firestore.batch();

      for (var item in order.items) {
        final itemRef = _firestore.collection('items1').doc(item.productId);

        // Increment the quantity back
        batch.update(itemRef, {
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      // Send cancellation notification
      batch.set(
        _firestore.collection('notifications').doc(),
        {
          'type': 'order_cancelled',
          'orderId': order.id,
          'userName': order.userName,
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        },
      );

      await batch.commit();
    } catch (e) {
      print('Error cancelling order: $e');
      throw Exception('فشل إلغاء الطلب: ${e.toString()}');
    }
  }

  // Get order statistics for user
  Future<Map<String, dynamic>> getUserOrderStats(String userId) async {
    try {
      final orders = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .get();

      int totalOrders = orders.docs.length;
      int pendingOrders = 0;
      int processingOrders = 0;
      int shippedOrders = 0;
      int deliveredOrders = 0;
      int cancelledOrders = 0;
      double totalSpent = 0;

      for (var doc in orders.docs) {
        final data = doc.data();
        final status = data['status'] as String;
        final amount = (data['pricing']['total'] ?? 0).toDouble();

        switch (status) {
          case 'pending':
            pendingOrders++;
            break;
          case 'processing':
            processingOrders++;
            break;
          case 'shipped':
            shippedOrders++;
            break;
          case 'delivered':
            deliveredOrders++;
            totalSpent += amount;
            break;
          case 'cancelled':
            cancelledOrders++;
            break;
        }
      }

      return {
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'processingOrders': processingOrders,
        'shippedOrders': shippedOrders,
        'deliveredOrders': deliveredOrders,
        'cancelledOrders': cancelledOrders,
        'totalSpent': totalSpent,
        'activeOrders': pendingOrders + processingOrders + shippedOrders,
      };
    } catch (e) {
      print('Error getting order stats: $e');
      return {
        'totalOrders': 0,
        'pendingOrders': 0,
        'processingOrders': 0,
        'shippedOrders': 0,
        'deliveredOrders': 0,
        'cancelledOrders': 0,
        'totalSpent': 0.0,
        'activeOrders': 0,
      };
    }
  }

  // Get recent orders (for dashboard)
  Stream<List<OrderModel>> getRecentOrders({int limit = 5}) {
    return _firestore
        .collection('orders')
        .orderBy('timestamps.created', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      return OrderModel(
        id: data['orderId'] ?? doc.id,
        userId: data['customer']['userId'] ?? '',
        userName: data['customer']['name'] ?? '',
        userPhone: data['customer']['phone'] ?? '',
        items: (data['items'] as List).map((item) => OrderItem(
          productId: item['productId'] ?? '',
          productName: item['productName'] ?? '',
          quantity: item['quantity'] ?? 0,
          price: (item['unitPrice'] ?? 0).toDouble(),
          thumbnail: item['thumbnail'],
        )).toList(),
        totalAmount: (data['pricing']['total'] ?? 0).toDouble(),
        status: data['status'] ?? 'pending',
        deliveryAddress: data['delivery']['address'] ?? '',
        latitude: data['delivery']['latitude']?.toDouble(),
        longitude: data['delivery']['longitude']?.toDouble(),
        createdAt: (data['timestamps']['created'] as Timestamp).toDate(),
        notes: data['delivery']['deliveryNotes'],
      );
    })
        .toList());
  }

  // Search orders by ID or user name
  Future<List<OrderModel>> searchOrders(String query) async {
    try {
      // Search by order ID
      final orderById = await _firestore
          .collection('orders')
          .where('orderId', isEqualTo: query)
          .get();

      if (orderById.docs.isNotEmpty) {
        return orderById.docs
            .map((doc) {
          final data = doc.data();
          return OrderModel(
            id: data['orderId'] ?? doc.id,
            userId: data['customer']['userId'] ?? '',
            userName: data['customer']['name'] ?? '',
            userPhone: data['customer']['phone'] ?? '',
            items: (data['items'] as List).map((item) => OrderItem(
              productId: item['productId'] ?? '',
              productName: item['productName'] ?? '',
              quantity: item['quantity'] ?? 0,
              price: (item['unitPrice'] ?? 0).toDouble(),
              thumbnail: item['thumbnail'],
            )).toList(),
            totalAmount: (data['pricing']['total'] ?? 0).toDouble(),
            status: data['status'] ?? 'pending',
            deliveryAddress: data['delivery']['address'] ?? '',
            latitude: data['delivery']['latitude']?.toDouble(),
            longitude: data['delivery']['longitude']?.toDouble(),
            createdAt: (data['timestamps']['created'] as Timestamp).toDate(),
            notes: data['delivery']['deliveryNotes'],
          );
        })
            .toList();
      }

      // Search by user name (partial match)
      final ordersByName = await _firestore
          .collection('orders')
          .where('customer.name', isGreaterThanOrEqualTo: query)
          .where('customer.name', isLessThanOrEqualTo: query + '\uf8ff')
          .limit(20)
          .get();

      return ordersByName.docs
          .map((doc) {
        final data = doc.data();
        return OrderModel(
          id: data['orderId'] ?? doc.id,
          userId: data['customer']['userId'] ?? '',
          userName: data['customer']['name'] ?? '',
          userPhone: data['customer']['phone'] ?? '',
          items: (data['items'] as List).map((item) => OrderItem(
            productId: item['productId'] ?? '',
            productName: item['productName'] ?? '',
            quantity: item['quantity'] ?? 0,
            price: (item['unitPrice'] ?? 0).toDouble(),
            thumbnail: item['thumbnail'],
          )).toList(),
          totalAmount: (data['pricing']['total'] ?? 0).toDouble(),
          status: data['status'] ?? 'pending',
          deliveryAddress: data['delivery']['address'] ?? '',
          latitude: data['delivery']['latitude']?.toDouble(),
          longitude: data['delivery']['longitude']?.toDouble(),
          createdAt: (data['timestamps']['created'] as Timestamp).toDate(),
          notes: data['delivery']['deliveryNotes'],
        );
      })
          .toList();
    } catch (e) {
      print('Error searching orders: $e');
      return [];
    }
  }

  // Get orders by status
  Stream<List<OrderModel>> getOrdersByStatus(String status) {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: status)
        .orderBy('timestamps.created', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      return OrderModel(
        id: data['orderId'] ?? doc.id,
        userId: data['customer']['userId'] ?? '',
        userName: data['customer']['name'] ?? '',
        userPhone: data['customer']['phone'] ?? '',
        items: (data['items'] as List).map((item) => OrderItem(
          productId: item['productId'] ?? '',
          productName: item['productName'] ?? '',
          quantity: item['quantity'] ?? 0,
          price: (item['unitPrice'] ?? 0).toDouble(),
          thumbnail: item['thumbnail'],
        )).toList(),
        totalAmount: (data['pricing']['total'] ?? 0).toDouble(),
        status: data['status'] ?? 'pending',
        deliveryAddress: data['delivery']['address'] ?? '',
        latitude: data['delivery']['latitude']?.toDouble(),
        longitude: data['delivery']['longitude']?.toDouble(),
        createdAt: (data['timestamps']['created'] as Timestamp).toDate(),
        notes: data['delivery']['deliveryNotes'],
      );
    })
        .toList());
  }

  // Check if user has any orders
  Future<bool> userHasOrders(String userId) async {
    try {
      final orders = await _firestore
          .collection('users')
          .doc(userId)
          .collection('orders')
          .limit(1)
          .get();

      return orders.docs.isNotEmpty;
    } catch (e) {
      print('Error checking user orders: $e');
      return false;
    }
  }

  // Get order status history
  Stream<List<Map<String, dynamic>>> getOrderStatusHistory(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .collection('statusHistory')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => {
      ...doc.data(),
      'timestamp': (doc.data()['timestamp'] as Timestamp).toDate(),
    })
        .toList());
  }

  // Calculate estimated delivery time (example implementation)
  DateTime calculateEstimatedDelivery(String status) {
    final now = DateTime.now();

    switch (status) {
      case 'pending':
        return now.add(Duration(days: 3));
      case 'processing':
        return now.add(Duration(days: 2));
      case 'shipped':
        return now.add(Duration(days: 1));
      case 'delivered':
        return now;
      default:
        return now.add(Duration(days: 3));
    }
  }
}