// models/cart_item.dart
import 'item.dart';

class CartItem {
  final Item item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  double get totalPrice => item.salePrice1 * quantity;
  String get formattedTotal => '${item.currencySymbol} ${totalPrice.toStringAsFixed(0)}';
}