import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../models/cart_item.dart' as models;
import '../providers/auth_provider.dart';
import '../sections/product_details.dart';
import 'cartPage_m.dart';
import '../providers/cart_provider.dart';
import 'dart:ui';

class CategoryItemsPage extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const CategoryItemsPage({
    Key? key,
    required this.categoryName,
    required this.categoryId,
  }) : super(key: key);

  @override
  _CategoryItemsPageState createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Pagination
  static const int _itemsPerPage = 12;
  List<DocumentSnapshot> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  // Filter & Sort
  String _selectedSort = 'featured';
  RangeValues _priceRange = RangeValues(0, 10000);
  bool _showFilters = false;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    _loadItems();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Load more items
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreItems();
      }
    }

    // Update navbar style
    setState(() {
      _isScrolled = _scrollController.offset > 50;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      Query query = _firestore.collection('items1');

      if (widget.categoryId.isNotEmpty && widget.categoryId != 'all') {
        query = query.where('category', isEqualTo: widget.categoryName);
      }

      query = query.limit(_itemsPerPage * 2);

      final snapshot = await query.get();
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
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreItems() async {
    if (_isLoading || !_hasMore || _lastDocument == null) return;
    setState(() => _isLoading = true);

    try {
      Query query = _firestore.collection('items1')
          .startAfterDocument(_lastDocument!);

      if (widget.categoryId.isNotEmpty && widget.categoryId != 'all') {
        query = query.where('category', isEqualTo: widget.categoryName);
      }

      query = query.limit(_itemsPerPage * 2);

      final snapshot = await query.get();
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isMobile = screenWidth < 768;
    final cartProvider = Provider.of<CartProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Main Content
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Minimal Header
                SliverToBoxAdapter(
                  child: _buildMinimalHeader(isDesktop, isMobile),
                ),

                // Filter Bar
                SliverToBoxAdapter(
                  child: _buildFilterBar(isDesktop, isMobile),
                ),

                // Products Grid
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 60 : 20,
                    vertical: 40,
                  ),
                  sliver: _buildProductsGrid(isDesktop, isMobile),
                ),

                // Loading Indicator
                if (_isLoading)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Luxury Navigation
            _buildLuxuryNav(isDesktop, isMobile, cartProvider),
          ],
        ),
      ),
    );
  }

  // LUXURY NAVIGATION BAR
  Widget _buildLuxuryNav(bool isDesktop, bool isMobile, CartProvider cartProvider) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: isDesktop ? 80 : 70,
        decoration: BoxDecoration(
          color: _isScrolled
              ? Colors.white.withOpacity(0.98)
              : Colors.white.withOpacity(0.95),
          border: Border(
            bottom: BorderSide(
              color: _isScrolled ? Colors.grey[200]! : Colors.transparent,
              width: 1,
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 60 : 20,
                vertical: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),

                  // Title
                  Text(
                    'أرض الطب',
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                    ),
                  ),

                  // Cart
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_bag_outlined, size: 20),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CartPage()),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
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
      ),
    );
  }

  // MINIMAL HEADER
  Widget _buildMinimalHeader(bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.only(
        top: isDesktop ? 140 : 110,
        bottom: isDesktop ? 60 : 40,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Text(
              widget.categoryName,
              style: TextStyle(
                fontSize: isDesktop ? 48 : 32,
                fontWeight: FontWeight.w200,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 60,
              height: 1,
              color: Colors.black12,
            ),
            SizedBox(height: 20),
            Text(
              '${_items.length} منتج',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FILTER BAR
  Widget _buildFilterBar(bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Filter Button
          TextButton.icon(
            onPressed: () => setState(() => _showFilters = !_showFilters),
            icon: Icon(
              Icons.tune,
              size: 18,
              color: Colors.black87,
            ),
            label: Text(
              'تصفية',
              style: TextStyle(
                color: Colors.black87,
                fontSize: isDesktop ? 15 : 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          ),

          // Sort Dropdown
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButton<String>(
              value: _selectedSort,
              underline: SizedBox(),
              icon: Icon(Icons.arrow_drop_down, size: 20),
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              items: [
                DropdownMenuItem(value: 'featured', child: Text('المميز')),
                DropdownMenuItem(value: 'price_asc', child: Text('السعر: الأقل')),
                DropdownMenuItem(value: 'price_desc', child: Text('السعر: الأعلى')),
                DropdownMenuItem(value: 'newest', child: Text('الأحدث')),
              ],
              onChanged: (value) => setState(() => _selectedSort = value!),
            ),
          ),
        ],
      ),
    );
  }

  // PRODUCTS GRID
  Widget _buildProductsGrid(bool isDesktop, bool isMobile) {
    final filteredItems = _items
        .map((doc) => Item.fromFirestore(
        doc.data() as Map<String, dynamic>, doc.id))
        .where((item) => item.number > 0)
        .toList();

    if (filteredItems.isEmpty && !_isLoading) {
      return SliverToBoxAdapter(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(60),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 20),
                Text(
                  'لا توجد منتجات',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        childAspectRatio: isDesktop ? 0.65 : 0.6,
        crossAxisSpacing: isDesktop ? 30 : 15,
        mainAxisSpacing: isDesktop ? 50 : 25,
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final item = filteredItems[index];
          return _buildLuxuryProductCard(item, isDesktop);
        },
        childCount: filteredItems.length,
      ),
    );
  }

  // LUXURY PRODUCT CARD
  Widget _buildLuxuryProductCard(Item item, bool isDesktop) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _navigateToItemDetails(item),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Container
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                      ),
                      child: item.thumbnail != null
                          ? Image.network(
                        item.thumbnail!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.medical_services_outlined,
                              size: 32,
                              color: Colors.grey[300],
                            ),
                          );
                        },
                      )
                          : Center(
                        child: Icon(
                          Icons.medical_services_outlined,
                          size: 32,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),

                    // Hover Overlay
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0),
                        ),
                        child: Center(
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 200),
                            opacity: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                              ),
                              child: Text(
                                'عرض السريع',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Stock Badge
                    if (item.number <= 5)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          color: Colors.white.withOpacity(0.9),
                          child: Text(
                            'محدود',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Product Info
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: isDesktop ? 15 : 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.formattedPrice,
                          style: TextStyle(
                            fontSize: isDesktop ? 14 : 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        if (item.inStock)
                          GestureDetector(
                            onTap: () => _addToCart(item),
                            child: Icon(
                              Icons.add_circle_outline,
                              size: 20,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      _showAuthDialog();
      return;
    }

    cartProvider.addToCart(item, quantity: quantity);

    // Minimal notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تمت الإضافة إلى السلة',
          style: TextStyle(fontSize: 14),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        margin: EdgeInsets.all(20),
      ),
    );
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تسجيل الدخول مطلوب',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/sign-in');
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: Colors.black87),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      color: Colors.black87,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}