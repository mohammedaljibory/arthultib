import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/cart_item.dart';
import '../models/item.dart';
import '../services/order_service.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];
  final OrderService _orderService = OrderService();

  List<CartItem> get cartItems => _cartItems;

  int get itemCount => _cartItems.length;

  int get totalQuantity => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _cartItems.fold(0, (sum, item) => sum + item.totalPrice);

  String get currencySymbol => _cartItems.isNotEmpty ? _cartItems.first.item.currencySymbol : 'د.ع';

  CartProvider() {
    _loadCart();
  }

  // Load cart from local storage
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = prefs.getString('cart_items');

      if (cartData != null) {
        final List<dynamic> decodedData = json.decode(cartData);
        _cartItems = decodedData.map((item) => _deserializeCartItem(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading cart: $e');
      _cartItems = [];
    }
  }

  // Save cart to local storage
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = _cartItems.map((item) => _serializeCartItem(item)).toList();
      await prefs.setString('cart_items', json.encode(cartData));
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // Add item to cart
  void addToCart(Item item, {int quantity = 1}) {
    try {
      final existingIndex = _cartItems.indexWhere((ci) => ci.item.id == item.id);

      if (existingIndex != -1) {
        // Update quantity if item already exists
        final newQuantity = _cartItems[existingIndex].quantity + quantity;
        if (newQuantity <= item.number) {
          _cartItems[existingIndex].quantity = newQuantity;
        } else {
          throw Exception('الكمية المطلوبة غير متوفرة');
        }
      } else {
        // Add new item
        if (quantity <= item.number) {
          _cartItems.add(CartItem(item: item, quantity: quantity));
        } else {
          throw Exception('الكمية المطلوبة غير متوفرة');
        }
      }

      notifyListeners();
      _saveCart();
    } catch (e) {
      throw e;
    }
  }

  // Remove item from cart
  void removeFromCart(String itemId) {
    _cartItems.removeWhere((item) => item.item.id == itemId);
    notifyListeners();
    _saveCart();
  }

  // Update item quantity
  void updateQuantity(String itemId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.item.id == itemId);

    if (index != -1) {
      if (quantity > 0 && quantity <= _cartItems[index].item.number) {
        _cartItems[index].quantity = quantity;
        notifyListeners();
        _saveCart();
      } else if (quantity <= 0) {
        removeFromCart(itemId);
      }
    }
  }

  // Clear entire cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
    _saveCart();
  }

  // Check if item is in cart
  bool isInCart(String itemId) {
    return _cartItems.any((item) => item.item.id == itemId);
  }

  // Get quantity of specific item in cart
  int getItemQuantity(String itemId) {
    final cartItem = _cartItems.firstWhere(
          (item) => item.item.id == itemId,
      orElse: () => CartItem(
        item: Item(
          id: '',
          name: '',
          nameParts: [],
          salePrice1: 0,
          number: 0,
          saleCurrencyId: 1,
        ),
        quantity: 0,
      ),
    );
    return cartItem.quantity;
  }

  // Checkout
  Future<String> checkout({
    required String userId,
    required String userName,
    required String userPhone,
    required String address,
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    if (_cartItems.isEmpty) {
      throw Exception('السلة فارغة');
    }

    if (address.isEmpty) {
      throw Exception('يرجى تحديد عنوان التوصيل');
    }

    try {
      // Validate cart items
      final errors = await validateCart();
      if (errors.isNotEmpty) {
        throw Exception(errors.join('\n'));
      }

      // Create order
      final orderId = await _orderService.createOrder(
        items: _cartItems,
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        address: address,
        latitude: latitude,
        longitude: longitude,
        notes: notes,
      );

      // Clear cart after successful order
      clearCart();

      return orderId;
    } catch (e) {
      throw Exception('فشل إتمام الطلب: ${e.toString()}');
    }
  }

  // Validate cart items (check stock availability)
  Future<List<String>> validateCart() async {
    List<String> errors = [];

    for (var cartItem in _cartItems) {
      if (cartItem.quantity > cartItem.item.number) {
        errors.add('${cartItem.item.name} - الكمية المطلوبة (${cartItem.quantity}) أكثر من المتوفر (${cartItem.item.number})');
      }

      if (cartItem.item.number == 0) {
        errors.add('${cartItem.item.name} - غير متوفر حالياً');
      }
    }

    return errors;
  }

  // Get cart summary for checkout
  Map<String, dynamic> getCartSummary() {
    return {
      'items': _cartItems.map((item) => {
        'itemId': item.item.id,
        'itemName': item.item.name,
        'quantity': item.quantity,
        'price': item.item.salePrice1,
        'total': item.totalPrice,
        'thumbnail': item.item.thumbnail,
      }).toList(),
      'subtotal': totalAmount,
      'tax': 0.0,
      'shipping': 0.0,
      'total': totalAmount,
      'currency': currencySymbol,
      'itemCount': itemCount,
      'totalQuantity': totalQuantity,
    };
  }

  // Serialize cart item for storage
  Map<String, dynamic> _serializeCartItem(CartItem cartItem) {
    return {
      'item': {
        'id': cartItem.item.id,
        'name': cartItem.item.name,
        'nameParts': cartItem.item.nameParts,
        'salePrice1': cartItem.item.salePrice1,
        'salePrice2': cartItem.item.salePrice2,
        'salePrice3': cartItem.item.salePrice3,
        'number': cartItem.item.number,
        'saleCurrencyId': cartItem.item.saleCurrencyId,
        'thumbnail': cartItem.item.thumbnail,
        'barcodeText': cartItem.item.barcodeText,
        'lastUpdated': cartItem.item.lastUpdated?.toIso8601String(),
      },
      'quantity': cartItem.quantity,
    };
  }

  // Deserialize cart item from storage
  CartItem _deserializeCartItem(Map<String, dynamic> data) {
    final itemData = data['item'];
    final item = Item(
      id: itemData['id'] ?? '',
      name: itemData['name'] ?? '',
      nameParts: List<String>.from(itemData['nameParts'] ?? []),
      salePrice1: (itemData['salePrice1'] ?? 0).toDouble(),
      salePrice2: (itemData['salePrice2'] ?? 0).toDouble(),
      salePrice3: (itemData['salePrice3'] ?? 0).toDouble(),
      number: itemData['number'] ?? 0,
      saleCurrencyId: itemData['saleCurrencyId'] ?? 1,
      thumbnail: itemData['thumbnail'],
      barcodeText: itemData['barcodeText'],
      lastUpdated: itemData['lastUpdated'] != null
          ? DateTime.parse(itemData['lastUpdated'])
          : null,
    );

    return CartItem(
      item: item,
      quantity: data['quantity'] ?? 1,
    );
  }

  // Get cart badge count (for UI)
  String get badgeCount {
    if (_cartItems.isEmpty) return '';
    if (_cartItems.length > 99) return '99+';
    return _cartItems.length.toString();
  }

  // Calculate savings (if implementing discount system)
  double calculateSavings() {
    // Implement your savings calculation logic here
    // For example, comparing with original prices
    return 0.0;
  }

  // Apply coupon (if implementing coupon system)
  Future<bool> applyCoupon(String couponCode) async {
    // Implement coupon validation and application logic
    // This is a placeholder for future implementation
    return false;
  }
}