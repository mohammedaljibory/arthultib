// 4. REDESIGNED CART PAGE (cartPage_m.dart)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../models/user_model.dart';
import '../services/order_service.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final cartItems = cartProvider.cartItems;
    final total = cartProvider.totalAmount;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'سلة التسوق',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w300,
              fontSize: 22,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (cartItems.isNotEmpty)
              TextButton.icon(
                icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                label: Text('مسح السلة', style: TextStyle(color: Colors.red)),
                onPressed: () => _showClearCartDialog(),
              ),
          ],
        ),
        body: cartItems.isEmpty
            ? _buildEmptyCart()
            : isDesktop
            ? _buildDesktopLayout(cartItems, total)
            : _buildMobileLayout(cartItems, total),
      ),
    );
  }

  Widget _buildDesktopLayout(List<dynamic> cartItems, double total) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cart Items Section
        Expanded(
          flex: 2,
          child: Container(
            margin: EdgeInsets.all(24),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المنتجات (${cartItems.length})',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) => Divider(height: 30),
                    itemBuilder: (context, index) {
                      return _buildCartItem(cartItems[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Summary Section
        Container(
          width: 400,
          margin: EdgeInsets.all(24),
          child: _buildSummaryCard(total),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(List<dynamic> cartItems, double total) {
    return Column(
      children: [
        // Items List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildCartItem(cartItems[index]),
              );
            },
          ),
        ),

        // Bottom Summary
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المجموع الكلي',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${total.toStringAsFixed(0)} د.ع',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _proceedToCheckout(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0D47A1),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'إتمام الشراء',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(dynamic cartItem) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[100],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: cartItem.item.thumbnail != null
                  ? Image.network(
                cartItem.item.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_outlined,
                      size: 40, color: Colors.grey);
                },
              )
                  : Icon(Icons.image_outlined,
                  size: 40, color: Colors.grey),
            ),
          ),
          SizedBox(width: 16),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.item.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  '${cartItem.item.salePrice1.toStringAsFixed(0)} د.ع',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 12),

                // Quantity Controls
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, size: 18),
                            onPressed: cartItem.quantity > 1
                                ? () => cartProvider.updateQuantity(
                              cartItem.item.id,
                              cartItem.quantity - 1,
                            )
                                : null,
                            padding: EdgeInsets.all(4),
                            constraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${cartItem.quantity}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, size: 18),
                            onPressed: cartItem.quantity < cartItem.item.number
                                ? () => cartProvider.updateQuantity(
                              cartItem.item.id,
                              cartItem.quantity + 1,
                            )
                                : null,
                            padding: EdgeInsets.all(4),
                            constraints: BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Text(
                      '${cartItem.totalPrice.toStringAsFixed(0)} د.ع',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () {
                        cartProvider.removeFromCart(cartItem.item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم حذف ${cartItem.item.name}'),
                            action: SnackBarAction(
                              label: 'تراجع',
                              onPressed: () {
                                cartProvider.addToCart(cartItem.item,
                                    quantity: cartItem.quantity);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double total) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ملخص الطلب',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 24),

          _buildSummaryRow('المنتجات', '${total.toStringAsFixed(0)} د.ع'),
          SizedBox(height: 12),
          _buildSummaryRow('التوصيل', 'مجاني', isHighlighted: true),
          SizedBox(height: 12),
          _buildSummaryRow('الخصم', '0 د.ع'),
          SizedBox(height: 20),
          Divider(),
          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع الكلي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                '${total.toStringAsFixed(0)} د.ع',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _proceedToCheckout(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0D47A1),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'إتمام الشراء',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),

          SizedBox(height: 16),

          // Security badges
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 16, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'دفع آمن 100%',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isHighlighted ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'السلة فارغة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'أضف منتجات لتبدأ التسوق',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/store'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0D47A1),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              'تصفح المنتجات',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('مسح السلة'),
          content: Text('هل أنت متأكد من حذف جميع المنتجات من السلة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Provider.of<CartProvider>(context, listen: false).clearCart();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('حذف الكل'),
            ),
          ],
        );
      },
    );
  }

  void _proceedToCheckout() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      _showLoginDialog();
    } else {
      _showEnhancedCheckoutDialog();
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('تسجيل الدخول مطلوب'),
        content: Text('يجب عليك تسجيل الدخول لإتمام الشراء'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/sign-in');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0D47A1)),
            child: Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  void _showEnhancedCheckoutDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final user = authProvider.currentUser!;
    final _notesController = TextEditingController();
    String? selectedAddress = user.address;
    double? latitude = user.latitude;
    double? longitude = user.longitude;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              width: 500,
              padding: EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(Icons.shopping_cart_checkout,
                            color: Color(0xFF0D47A1), size: 28),
                        SizedBox(width: 12),
                        Text(
                          'تأكيد الطلب',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // User Info
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.grey[600], size: 20),
                              SizedBox(width: 8),
                              Text(user.name, style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(user.email != null ? Icons.email : Icons.phone, color: Colors.grey[600], size: 20),
                              SizedBox(width: 8),
                              Text(user.email ?? user.phoneNumber ?? '', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Location Section
                    Text(
                      'عنوان التوصيل',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 12),

                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                        color: selectedAddress != null ? Colors.green[50] : Colors.orange[50],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (selectedAddress != null && selectedAddress!.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    selectedAddress!,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Icon(Icons.warning,
                                    color: Colors.orange, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'لم يتم تحديد عنوان',
                                  style: TextStyle(color: Colors.orange[700]),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.my_location, size: 18),
                                  label: Text('موقعي الحالي'),
                                  onPressed: () async {
                                    // Show location selector dialog
                                    final result = await _showLocationSelector(context);
                                    if (result != null) {
                                      setState(() {
                                        selectedAddress = result['address'];
                                        latitude = result['latitude'];
                                        longitude = result['longitude'];
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.edit_location, size: 18),
                                  label: Text('كتابة العنوان'),
                                  onPressed: () async {
                                    final result = await _showManualAddressDialog(context);
                                    if (result != null) {
                                      setState(() {
                                        selectedAddress = result;
                                        latitude = null;
                                        longitude = null;
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // Notes
                    Text(
                      'ملاحظات (اختياري)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'أضف أي ملاحظات للطلب...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Order Summary
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('عدد المنتجات:',
                                  style: TextStyle(fontSize: 14)),
                              Text('${cartProvider.itemCount}',
                                  style: TextStyle(fontWeight: FontWeight.w500)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('المجموع الكلي:',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              Text(
                                '${cartProvider.totalAmount.toStringAsFixed(0)} د.ع',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              _notesController.dispose();
                              Navigator.pop(dialogContext);
                            },
                            child: Text('إلغاء'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (selectedAddress == null || selectedAddress!.isEmpty)
                                ? null
                                : () async {
                              Navigator.pop(dialogContext);
                              await _processOrder(
                                user: user,
                                address: selectedAddress!,
                                latitude: latitude,
                                longitude: longitude,
                                notes: _notesController.text,
                              );
                              _notesController.dispose();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0D47A1),
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'تأكيد الطلب',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _showLocationSelector(BuildContext context) async {
    // Implement GPS location selection
    // This would integrate with Geolocator and Geocoding packages
    // For now, returning a mock location
    return {
      'address': 'النجف، حي السلام، شارع المدينة',
      'latitude': 32.0,
      'longitude': 44.3
    };
  }

  Future<String?> _showManualAddressDialog(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('أدخل عنوان التوصيل'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'المحافظة، المنطقة، الشارع، رقم البناية...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final address = controller.text.trim();
              controller.dispose();
              Navigator.pop(context, address.isNotEmpty ? address : null);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0D47A1)),
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _processOrder({
    required UserModel user,
    required String address,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final OrderService orderService = OrderService();

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
              CircularProgressIndicator(color: Color(0xFF0D47A1)),
              SizedBox(height: 20),
              Text('جاري إرسال الطلب...'),
            ],
          ),
        ),
      ),
    );

    try {
      String orderId = await orderService.createOrder(
        items: cartProvider.cartItems,
        userId: user.uid,
        userName: user.name,
        userPhone: user.phoneNumber,
        userEmail: user.email,
        address: address,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );

      cartProvider.clearCart();
      Navigator.pop(context); // Close loading

      // Show success
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, size: 60, color: Colors.green),
              ),
              SizedBox(height: 20),
              Text(
                'تم إرسال طلبك بنجاح!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 10),
              Text(
                'رقم الطلب: ${orderId.substring(4)}',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              Text(
                'سيتم التواصل معك قريباً',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/store',
                      (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0D47A1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text('حسناً'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}