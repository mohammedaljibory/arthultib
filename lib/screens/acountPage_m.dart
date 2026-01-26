import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../language_provider.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final OrderService _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    if (!authProvider.isAuthenticated) {
      return _buildLoginPrompt(languageProvider);
    }

    final user = authProvider.currentUser!;

    return Directionality(
      textDirection: languageProvider.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Column(
          children: [
            // App Bar
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 10,
                left: 20,
                right: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'حسابي',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // User Info Card
                    _buildUserInfoCard(user),
                    SizedBox(height: 20),

                    // Statistics Cards
                    _buildStatisticsSection(user.uid),
                    SizedBox(height: 20),

                    // Orders Section
                    _buildOrdersSection(user.uid),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add these methods to handle button actions
  void _editProfile(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final addressController = TextEditingController(text: user.address ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(Icons.edit, color: Colors.green),
              SizedBox(width: 10),
              Text('تعديل الملف الشخصي'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'الاسم',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: TextEditingController(text: user.email ?? user.phoneNumber ?? ''),
                  decoration: InputDecoration(
                    labelText: user.email != null ? 'البريد الإلكتروني' : 'رقم الهاتف',
                    prefixIcon: Icon(user.email != null ? Icons.email_outlined : Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  enabled: false,
                ),
                SizedBox(height: 15),
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'العنوان',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    hintText: 'المحافظة، المنطقة، الشارع...',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () {
                nameController.dispose();
                addressController.dispose();
                Navigator.pop(dialogContext);
              },
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                final newName = nameController.text.trim();
                final newAddress = addressController.text.trim();

                if (newName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('الرجاء إدخال الاسم'), backgroundColor: Colors.red),
                  );
                  return;
                }

                if (newName.length < 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('الاسم يجب أن يكون 3 أحرف على الأقل'), backgroundColor: Colors.red),
                  );
                  return;
                }

                setState(() => isLoading = true);

                try {
                  // Update in Firestore
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({
                    'name': newName,
                    'address': newAddress.isNotEmpty ? newAddress : null,
                    'lastUpdated': FieldValue.serverTimestamp(),
                  });

                  // Update local user in provider
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  authProvider.updateCurrentUser(user.copyWith(
                    name: newName,
                    address: newAddress.isNotEmpty ? newAddress : null,
                  ));

                  nameController.dispose();
                  addressController.dispose();
                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث الملف الشخصي بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  setState(() => isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text('حفظ'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  // Cancel order method
  void _cancelOrder(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 10),
            Text('إلغاء الطلب'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من إلغاء الطلب؟'),
            SizedBox(height: 10),
            Text(
              'رقم الطلب: #${order.id.substring(0, 8)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            Text(
              'المبلغ: ${order.totalAmount.toStringAsFixed(0)} د.ع',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('تراجع'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: Container(
                    padding: EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.red),
                        SizedBox(height: 20),
                        Text('جاري إلغاء الطلب...'),
                      ],
                    ),
                  ),
                ),
              );

              try {
                await _orderService.cancelOrder(order.id);
                Navigator.pop(context); // Close loading

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('تم إلغاء الطلب بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context); // Close loading

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceAll('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('نعم، إلغاء الطلب'),
          ),
        ],
      ),
    );
  }

  void _viewOrders(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('طلباتي'),
        content: Text('سيتم عرض جميع طلباتك هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً'),
          ),
        ],
      ),
    );
  }
  Widget _buildLoginPrompt(LanguageProvider languageProvider) {
    return Directionality(
      textDirection: languageProvider.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle,
                size: 100,
                color: Colors.grey[400],
              ),
              SizedBox(height: 20),
              Text(
                'يرجى تسجيل الدخول',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'قم بتسجيل الدخول لعرض حسابك وطلباتك',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/sign-in');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(user) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          SizedBox(height: 15),

          // User Name
          Text(
            user.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 5),

          // Phone Number
          Text(
            user.phoneNumber,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          // Address
          if (user.address != null && user.address!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey),
                  SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      user.address!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 20),

          // Action Buttons
          // Replace the Action Buttons section with this:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () => _editProfile(context, user),  // Add action
                icon: Icon(Icons.edit, size: 18),
                label: Text('تعديل'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: Colors.green),
                ),
              ),
              SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/saved-items');
                },
                icon: Icon(Icons.favorite, size: 18),
                label: Text('المفضلة'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox();
        }

        final orders = snapshot.data!.docs;
        int totalOrders = orders.length;
        int pendingOrders = 0;
        int completedOrders = 0;
        double totalSpent = 0;

        for (var doc in orders) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] as String;
          final amount = (data['totalAmount'] ?? 0).toDouble();

          if (status == 'pending' || status == 'processing') {
            pendingOrders++;
          } else if (status == 'delivered') {
            completedOrders++;
          }

          totalSpent += amount;
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'إجمالي الطلبات',
                totalOrders.toString(),
                Icons.shopping_bag_outlined,
                Colors.blue,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                'قيد التنفيذ',
                pendingOrders.toString(),
                Icons.access_time,
                Colors.orange,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                'مكتملة',
                completedOrders.toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersSection(String userId) {
    return StreamBuilder<List<OrderModel>>(
      stream: _orderService.getUserOrders(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            padding: EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 60,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 15),
                Text(
                  'لا توجد طلبات بعد',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/store');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'تصفح المتجر',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }

        final orders = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلباتي',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${orders.length} طلبات',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            ...orders.map((order) => _buildOrderCard(order)).toList(),
          ],
        );
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Order Header
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رقم الطلب: #${order.id.substring(0, 8)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      _formatDate(order.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Order Progress
          Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Progress Indicator
                Row(
                  children: [
                    _buildProgressStep('تم الطلب', true, order.status),
                    _buildProgressLine(order.status == 'processing' || order.status == 'shipped' || order.status == 'delivered'),
                    _buildProgressStep('قيد التحضير', order.status == 'processing' || order.status == 'shipped' || order.status == 'delivered', order.status),
                    _buildProgressLine(order.status == 'shipped' || order.status == 'delivered'),
                    _buildProgressStep('قيد التوصيل', order.status == 'shipped' || order.status == 'delivered', order.status),
                    _buildProgressLine(order.status == 'delivered'),
                    _buildProgressStep('تم التسليم', order.status == 'delivered', order.status),
                  ],
                ),
                SizedBox(height: 20),

                // Order Items
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المنتجات:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    ...order.items.map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '• ${item.productName} (${item.quantity}x)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Text(
                            '${(item.price * item.quantity).toStringAsFixed(0)} د.ع',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
                SizedBox(height: 15),

                // Total
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المجموع:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${order.totalAmount.toStringAsFixed(0)} د.ع',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // Cancel Order Button (only for pending/processing orders)
                if (order.status == 'pending' || order.status == 'processing')
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 10),
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelOrder(context, order),
                      icon: Icon(Icons.cancel_outlined, size: 18),
                      label: Text('إلغاء الطلب'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isActive, String currentStatus) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: isActive ? Colors.green : Colors.grey,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Container(
      height: 2,
      width: 20,
      margin: EdgeInsets.only(bottom: 25),
      color: isActive ? Colors.green : Colors.grey[300],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'processing':
        return 'قيد التحضير';
      case 'shipped':
        return 'قيد التوصيل';
      case 'delivered':
        return 'تم التسليم';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}