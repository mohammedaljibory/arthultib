import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../models/item.dart';
import '../sections/product_details.dart';

class SavedItemsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'المفضلة',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (authProvider.currentUser != null &&
                authProvider.currentUser!.savedItems.isNotEmpty)
              TextButton(
                onPressed: () {
                  _showClearAllDialog(context, authProvider);
                },
                child: Text(
                  'حذف الكل',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        body: _buildBody(context, authProvider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AuthProvider authProvider) {
    if (authProvider.currentUser == null) {
      return _buildLoginPrompt(context);
    }

    final savedItemIds = authProvider.currentUser!.savedItems;

    if (savedItemIds.isEmpty) {
      return _buildEmptyState(context);
    }

    // Firestore has a limit of 10 items for whereIn query
    // If user has more than 10 saved items, we need to batch the queries
    if (savedItemIds.length > 10) {
      return _buildBatchedSavedItems(context, savedItemIds);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items1')
          .where(FieldPath.documentId, whereIn: savedItemIds)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'حدث خطأ في تحميل المفضلة',
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    // Trigger rebuild
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => SavedItemsPage()),
                    );
                  },
                  child: Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(context);
        }

        final items = snapshot.data!.docs
            .map((doc) => Item.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        return _buildItemsGrid(context, items);
      },
    );
  }

  Widget _buildBatchedSavedItems(BuildContext context, List<String> savedItemIds) {
    // Split savedItemIds into batches of 10
    List<List<String>> batches = [];
    for (int i = 0; i < savedItemIds.length; i += 10) {
      int end = i + 10;
      if (end > savedItemIds.length) end = savedItemIds.length;
      batches.add(savedItemIds.sublist(i, end));
    }

    return FutureBuilder<List<Item>>(
      future: _fetchBatchedItems(batches),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: Colors.red),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text('حدث خطأ في تحميل المفضلة'),
          );
        }

        if (snapshot.data!.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildItemsGrid(context, snapshot.data!);
      },
    );
  }

  Future<List<Item>> _fetchBatchedItems(List<List<String>> batches) async {
    List<Item> allItems = [];

    for (var batch in batches) {
      final snapshot = await FirebaseFirestore.instance
          .collection('items1')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      final items = snapshot.docs
          .map((doc) => Item.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      allItems.addAll(items);
    }

    return allItems;
  }

  Widget _buildItemsGrid(BuildContext context, List<Item> items) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final crossAxisCount = isMobile ? 2 : 4;

    return RefreshIndicator(
      onRefresh: () async {
        // Trigger refresh by navigating to same page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => SavedItemsPage()),
        );
      },
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildItemCard(context, item);
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, Item item) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsPage(
              item: item,
              onAddToCart: (item, quantity) {
                cartProvider.addToCart(item, quantity: quantity);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تمت إضافة ${item.name} إلى السلة'),
                    action: SnackBarAction(
                      label: 'عرض السلة',
                      onPressed: () {
                        Navigator.pushNamed(context, '/cart');
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: item.thumbnail != null && item.thumbnail!.isNotEmpty
                          ? Image.network(
                        item.thumbnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                          : Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // Favorite Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () async {
                          await authProvider.removeFromFavorites(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم إزالة ${item.name} من المفضلة'),
                              action: SnackBarAction(
                                label: 'تراجع',
                                onPressed: () async {
                                  await authProvider.addToFavorites(item.id);
                                },
                              ),
                            ),
                          );
                        },
                        padding: EdgeInsets.all(6),
                        constraints: BoxConstraints(),
                      ),
                    ),
                  ),

                  // Stock Badge
                  if (!item.inStock)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'نفذ المخزون',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Item Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.formattedPrice,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0288D1),
                          ),
                        ),
                        if (item.inStock)
                          InkWell(
                            onTap: () {
                              cartProvider.addToCart(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('تمت إضافة ${item.name} إلى السلة'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color(0xFF0288D1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
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
            'قم بتسجيل الدخول لحفظ المنتجات المفضلة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/sign-in');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            'لا توجد عناصر محفوظة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'ابدأ بإضافة المنتجات إلى المفضلة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/store');
            },
            icon: Icon(Icons.shopping_bag),
            label: Text('تصفح المنتجات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0288D1),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('حذف جميع المفضلات'),
          content: Text('هل أنت متأكد من حذف جميع العناصر من المفضلة؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                // Save current items for undo
                final currentItems = List<String>.from(
                    authProvider.currentUser!.savedItems
                );

                // Clear all favorites
                for (String itemId in currentItems) {
                  await authProvider.removeFromFavorites(itemId);
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف جميع العناصر من المفضلة'),
                    action: SnackBarAction(
                      label: 'تراجع',
                      onPressed: () async {
                        // Restore all items
                        for (String itemId in currentItems) {
                          await authProvider.addToFavorites(itemId);
                        }
                      },
                    ),
                  ),
                );
              },
              child: Text(
                'حذف الكل',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}