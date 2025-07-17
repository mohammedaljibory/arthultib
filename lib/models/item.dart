// models/item.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  final String id;
  final String name;
  final List<String> nameParts;
  final double salePrice1;
  final double salePrice2;
  final double salePrice3;
  final int number; // quantity/amount
  final int saleCurrencyId;
  final String? thumbnail;
  final String? barcodeText;
  final DateTime? lastUpdated;

  Item({
    required this.id,
    required this.name,
    required this.nameParts,
    required this.salePrice1,
    this.salePrice2 = 0,
    this.salePrice3 = 0,
    required this.number,
    required this.saleCurrencyId,
    this.thumbnail,
    this.barcodeText,
    this.lastUpdated,
  });

  factory Item.fromFirestore(Map<String, dynamic> data, String docId) {
    return Item(
      id: docId,
      name: data['name'] ?? '',
      nameParts: List<String>.from(data['nameParts'] ?? []),
      salePrice1: (data['SalePrice1'] ?? 0).toDouble(),
      salePrice2: (data['SalePrice2'] ?? 0).toDouble(),
      salePrice3: (data['SalePrice3'] ?? 0).toDouble(),
      number: data['Number'] ?? 0,
      saleCurrencyId: data['SaleCurrencyId'] ?? 1,
      thumbnail: data['thumbnail'],
      barcodeText: data['BarcodeText'],
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  String get currencySymbol => saleCurrencyId == 2 ? '\$' : 'د.ع';

  String get formattedPrice => '$currencySymbol ${salePrice1.toStringAsFixed(0)}';

  bool get inStock => number > 0;
}