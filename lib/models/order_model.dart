
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // 'pending', 'processing', 'shipped', 'delivered'
  final String deliveryAddress;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final String? notes;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    this.latitude,
    this.longitude,
    required this.createdAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      items: List<OrderItem>.from(
        map['items']?.map((item) => OrderItem.fromMap(item)) ?? [],
      ),
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      deliveryAddress: map['deliveryAddress'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      notes: map['notes'],
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String? thumbnail;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.thumbnail,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'thumbnail': thumbnail,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
      thumbnail: map['thumbnail'],
    );
  }

  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(
      productId: cartItem.item.id,
      productName: cartItem.item.name,
      quantity: cartItem.quantity,
      price: cartItem.item.salePrice1,
      thumbnail: cartItem.item.thumbnail,
    );
  }
}