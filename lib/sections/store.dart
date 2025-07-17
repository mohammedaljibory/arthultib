// pages/store_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/item.dart';
import '../models/cart_item.dart';
import '../widgets/item_card.dart';
import 'search.dart';
import 'cart.dart';
import 'product_details.dart';

class StorePage extends StatefulWidget {
  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController = ScrollController();

  // Filter States
  String selectedCategory = 'الكل';
  String selectedCategoryId = '';

  // Cart
  List<CartItem> cartItems = [];

  // Pagination
  static const int _itemsPerPage = 12;
  List<DocumentSnapshot> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreItems();
      }
    }
  }

  Future<void> _loadItems() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query query = _firestore.collection('items1');

      // Apply category filter if selected
      if (selectedCategoryId.isNotEmpty) {
        query = query.where('category', isEqualTo: selectedCategory);
      }

      // Get more items than needed to filter client-side
      query = query.limit(_itemsPerPage * 2);

      final snapshot = await query.get();

      // Filter items client-side for stock and hidden status
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final number = data['Number'] ?? 0;
        final hidden = data['hidden'] ?? false;
        return number > 0 && !hidden;
      }).take(_itemsPerPage).toList();

      setState(() {
        _items = filteredDocs;
        _lastDocument = filteredDocs.isNotEmpty ? filteredDocs.last : null;
        _hasMore = filteredDocs.length == _itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoading || !_hasMore || _lastDocument == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Query query = _firestore.collection('items1')
          .startAfterDocument(_lastDocument!);

      // Apply category filter if selected
      if (selectedCategoryId.isNotEmpty) {
        query = query.where('category', isEqualTo: selectedCategory);
      }

      // Get more items than needed to filter client-side
      query = query.limit(_itemsPerPage * 2);

      final snapshot = await query.get();

      // Filter items client-side for stock and hidden status
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final number = data['Number'] ?? 0;
        final hidden = data['hidden'] ?? false;
        return number > 0 && !hidden;
      }).take(_itemsPerPage).toList();

      setState(() {
        _items.addAll(filteredDocs);
        _lastDocument = filteredDocs.isNotEmpty ? filteredDocs.last : null;
        _hasMore = filteredDocs.length == _itemsPerPage;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading more items: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCategoryChanged(String category, String categoryId) {
    setState(() {
      selectedCategory = category;
      selectedCategoryId = categoryId;
      _items.clear();
      _lastDocument = null;
      _hasMore = true;
    });
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth >= 900;
    bool isMobile = screenWidth < 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'المتجر',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.black87),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchPage(),
                  ),
                );
                if (result != null && result is Item) {
                  _navigateToItemDetails(result);
                }
              },
            ),
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined, color: Colors.black87),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CartPage(
                          cartItems: cartItems,
                          onUpdate: (updatedCart) {
                            setState(() {
                              cartItems = updatedCart;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                if (cartItems.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cartItems.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Categories Bar (Mobile & Desktop)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: _buildCategoriesBar(isMobile),
            ),

            // Items Grid
            Expanded(
              child: _buildItemsGrid(isDesktop, isMobile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesBar(bool isMobile) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('settings').doc('categories').snapshots(),
      builder: (context, snapshot) {
        List<String> categories = [];

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && data['list'] != null) {
            categories = List<String>.from(data['list']);
          }
        }

        final allCategories = ['الكل', ...categories];

        return Container(
          height: 56,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
            itemCount: allCategories.length,
            itemBuilder: (context, index) {
              final category = allCategories[index];
              final isSelected = selectedCategory == category;

              return Padding(
                padding: EdgeInsets.only(left: isMobile ? 8 : 16),
                child: InkWell(
                  onTap: () => _onCategoryChanged(
                      category,
                      category == 'الكل' ? '' : category
                  ),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.black87
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.black87
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: isMobile ? 14 : 15,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildItemsGrid(bool isDesktop, bool isMobile) {
    final filteredItems = _items
        .map((doc) => Item.fromFirestore(
        doc.data() as Map<String, dynamic>, doc.id))
        .where((item) => item.number > 0) // Double check for stock
        .toList();

    if (_items.isEmpty && _isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              'لا توجد منتجات متوفرة',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _items.clear();
          _lastDocument = null;
          _hasMore = true;
        });
        await _loadItems();
      },
      child: GridView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(isMobile ? 12 : 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : (isMobile ? 2 : 3),
          childAspectRatio: 0.65,
          crossAxisSpacing: isMobile ? 12 : 20,
          mainAxisSpacing: isMobile ? 16 : 24,
        ),
        itemCount: filteredItems.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredItems.length) {
            // Loading indicator at the bottom
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final item = filteredItems[index];
          return _buildProductCard(item, isMobile);
        },
      ),
    );
  }

  Widget _buildProductCard(Item item, bool isMobile) {
    return InkWell(
      onTap: () => _navigateToItemDetails(item),
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.thumbnail != null && item.thumbnail!.isNotEmpty
                        ? Image.network(
                      item.thumbnail!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                        : Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                // Quick Add Button
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: ElevatedButton(
                    onPressed: () => _addToCart(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      foregroundColor: Colors.black87,
                      elevation: 2,
                      padding: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'إضافة للسلة',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          // Product Name
          Text(
            item.name,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          // Price
          Text(
            item.formattedPrice,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          // Stock Status
          if (item.number <= 5)
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'متبقي ${item.number} فقط',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _navigateToItemDetails(Item item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailsPage(
          item: item,
          onAddToCart: (item, quantity) => _addToCart(item, quantity: quantity),
        ),
      ),
    );
  }

  void _addToCart(Item item, {int quantity = 1}) {
    setState(() {
      final existingIndex = cartItems.indexWhere((ci) => ci.item.id == item.id);
      if (existingIndex != -1) {
        cartItems[existingIndex].quantity += quantity;
      } else {
        cartItems.add(CartItem(item: item, quantity: quantity));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة ${item.name} إلى السلة'),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'عرض السلة',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CartPage(
                  cartItems: cartItems,
                  onUpdate: (updatedCart) {
                    setState(() {
                      cartItems = updatedCart;
                    });
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}