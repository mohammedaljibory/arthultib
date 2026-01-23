import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../providers/auth_provider.dart';
import '../sections/product_details.dart';
import 'cartPage_m.dart';
import '../providers/cart_provider.dart';
import 'dart:ui';

// Import luxury colors
class LuxuryColors {
  static const Color gold = Color(0xFFB8860B);
  static const Color lightGold = Color(0xFFD4AF37);
  static const Color champagne = Color(0xFFF7E7CE);
  static const Color cream = Color(0xFFFAF9F6);
  static const Color navy = Color(0xFF1B2838);
  static const Color darkNavy = Color(0xFF0F1419);
  static const Color charcoal = Color(0xFF2C3E50);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color platinum = Color(0xFFE5E4E2);
}

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

  static const int _itemsPerPage = 12;
  List<DocumentSnapshot> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  String _selectedSort = 'featured';
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
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreItems();
      }
    }

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
        backgroundColor: LuxuryColors.cream,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Luxury Header
                SliverToBoxAdapter(
                  child: _buildLuxuryHeader(isDesktop, isMobile),
                ),

                // Filter Bar
                SliverToBoxAdapter(
                  child: _buildLuxuryFilterBar(isDesktop, isMobile),
                ),

                // Products Grid
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 80 : 20,
                    vertical: isDesktop ? 60 : 40,
                  ),
                  sliver: _buildLuxuryProductsGrid(isDesktop, isMobile),
                ),

                // Loading Indicator
                if (_isLoading)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: LuxuryColors.gold,
                        ),
                      ),
                    ),
                  ),

                // Bottom Spacing
                SliverToBoxAdapter(
                  child: SizedBox(height: 60),
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
        height: isDesktop ? 90 : 75,
        decoration: BoxDecoration(
          color: _isScrolled
              ? Colors.white.withOpacity(0.98)
              : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: LuxuryColors.platinum,
              width: 1,
            ),
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _isScrolled ? 10 : 0,
              sigmaY: _isScrolled ? 10 : 0,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 20,
                vertical: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: LuxuryColors.platinum),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: LuxuryColors.navy,
                      ),
                    ),
                  ),

                  // Logo
                  Text(
                    'أرض الطب',
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                      color: LuxuryColors.navy,
                    ),
                  ),

                  // Cart
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CartPage()),
                        ),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(color: LuxuryColors.platinum),
                          ),
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 18,
                            color: LuxuryColors.navy,
                          ),
                        ),
                      ),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: LuxuryColors.gold,
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

  // LUXURY HEADER
  Widget _buildLuxuryHeader(bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.only(
        top: isDesktop ? 160 : 130,
        bottom: isDesktop ? 80 : 50,
        left: isDesktop ? 80 : 20,
        right: isDesktop ? 80 : 20,
      ),
      color: Colors.white,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 2,
              color: LuxuryColors.gold,
            ),
            SizedBox(height: 24),
            Text(
              widget.categoryName,
              style: TextStyle(
                fontSize: isDesktop ? 48 : 32,
                fontWeight: FontWeight.w200,
                letterSpacing: 4,
                color: LuxuryColors.navy,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              '${_items.length} منتج متاح',
              style: TextStyle(
                fontSize: isDesktop ? 15 : 13,
                color: LuxuryColors.gold,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // LUXURY FILTER BAR
  Widget _buildLuxuryFilterBar(bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: LuxuryColors.platinum),
          bottom: BorderSide(color: LuxuryColors.platinum),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Filter Button
          GestureDetector(
            onTap: () {
              // Show filter dialog
            },
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  size: 18,
                  color: LuxuryColors.navy,
                ),
                SizedBox(width: 10),
                Text(
                  'تصفية',
                  style: TextStyle(
                    color: LuxuryColors.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          // Sort Dropdown
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: LuxuryColors.platinum),
            ),
            child: DropdownButton<String>(
              value: _selectedSort,
              underline: SizedBox(),
              icon: Icon(Icons.keyboard_arrow_down, size: 18, color: LuxuryColors.navy),
              isDense: true,
              style: TextStyle(
                color: LuxuryColors.navy,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
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

  // LUXURY PRODUCTS GRID
  Widget _buildLuxuryProductsGrid(bool isDesktop, bool isMobile) {
    final filteredItems = _items
        .map((doc) => Item.fromFirestore(
        doc.data() as Map<String, dynamic>, doc.id))
        .where((item) => item.number > 0)
        .toList();

    if (filteredItems.isEmpty && !_isLoading) {
      return SliverToBoxAdapter(
        child: Center(
          child: Container(
            padding: EdgeInsets.all(80),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: LuxuryColors.platinum),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 32,
                    color: LuxuryColors.silver,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  'لا توجد منتجات',
                  style: TextStyle(
                    fontSize: 18,
                    color: LuxuryColors.navy,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'يرجى التحقق من أقسام أخرى',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
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
        childAspectRatio: isDesktop ? 0.65 : 0.58,
        crossAxisSpacing: isDesktop ? 30 : 16,
        mainAxisSpacing: isDesktop ? 50 : 30,
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
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: LuxuryColors.platinum),
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
                      color: LuxuryColors.cream,
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
                              color: LuxuryColors.silver,
                            ),
                          );
                        },
                      )
                          : Center(
                        child: Icon(
                          Icons.medical_services_outlined,
                          size: 32,
                          color: LuxuryColors.silver,
                        ),
                      ),
                    ),

                    // Stock Badge
                    if (item.number <= 5 && item.number > 0)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          color: LuxuryColors.gold,
                          child: Text(
                            'محدود',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Product Info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 20 : 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: isDesktop ? 14 : 13,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                          color: LuxuryColors.navy,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            item.formattedPrice,
                            style: TextStyle(
                              fontSize: isDesktop ? 16 : 14,
                              color: LuxuryColors.navy,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (item.inStock)
                            GestureDetector(
                              onTap: () => _addToCart(item),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  border: Border.all(color: LuxuryColors.navy),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 16,
                                  color: LuxuryColors.navy,
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تمت الإضافة إلى السلة',
          style: TextStyle(fontSize: 14),
        ),
        duration: Duration(seconds: 2),
        backgroundColor: LuxuryColors.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        margin: EdgeInsets.all(20),
        action: SnackBarAction(
          label: 'عرض السلة',
          textColor: LuxuryColors.gold,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CartPage()),
            );
          },
        ),
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
              Container(
                width: 40,
                height: 2,
                color: LuxuryColors.gold,
              ),
              SizedBox(height: 24),
              Text(
                'تسجيل الدخول مطلوب',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1,
                  color: LuxuryColors.navy,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'يرجى تسجيل الدخول للمتابعة',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/sign-in');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LuxuryColors.navy,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(letterSpacing: 1),
                  ),
                ),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
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
