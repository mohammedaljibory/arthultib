// ENHANCED MEDICAL STORE WITH COMPLETE FIREBASE STRUCTURE

import 'dart:math';

import 'package:company_website/sections/product_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:async';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/item.dart';
import '../screens/cartPage_m.dart';

// ============= DATA MODELS =============

class Category {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? icon;
  final String? imageUrl;
  final int order;
  final bool isActive;
  final int itemCount;
  final String? parentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.icon,
    this.imageUrl,
    required this.order,
    required this.isActive,
    required this.itemCount,
    this.parentId,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromFirestore(Map<String, dynamic> data, String docId) {
    return Category(
      id: docId,
      nameAr: data['nameAr'] ?? '',
      nameEn: data['nameEn'] ?? '',
      icon: data['icon'],
      imageUrl: data['imageUrl'],
      order: data['order'] ?? 999,
      isActive: data['isActive'] ?? true,
      itemCount: data['itemCount'] ?? 0,
      parentId: data['parentId'],
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }
}

class Banner {
  final String id;
  final String titleAr;
  final String? titleEn;
  final String? subtitleAr;
  final String imageUrl;
  final String actionType;
  final String? actionValue;
  final int order;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  Banner({
    required this.id,
    required this.titleAr,
    this.titleEn,
    this.subtitleAr,
    required this.imageUrl,
    required this.actionType,
    this.actionValue,
    required this.order,
    required this.isActive,
    this.startDate,
    this.endDate,
  });

  factory Banner.fromFirestore(Map<String, dynamic> data, String docId) {
    return Banner(
      id: docId,
      titleAr: data['titleAr'] ?? '',
      titleEn: data['titleEn'],
      subtitleAr: data['subtitleAr'],
      imageUrl: data['imageUrl'] ?? '',
      actionType: data['actionType'] ?? 'none',
      actionValue: data['actionValue'],
      order: data['order'] ?? 999,
      isActive: data['isActive'] ?? true,
      startDate: data['startDate']?.toDate(),
      endDate: data['endDate']?.toDate(),
    );
  }
}

// Enhanced Item Model
class EnhancedItem extends Item {
  final String? nameAr;
  final String? nameEn;
  final String categoryId;
  final String? categoryName;
  final List<String>? images;
  final bool isFeatured;
  final int? featuredOrder;
  final bool isNewArrival;
  final bool isBestSeller;
  final double? discount;
  final String? description;
  final String? brand;
  final List<String>? tags;
  final bool isActive;

  EnhancedItem({
    required String id,
    required String name,
    required List<String> nameParts,
    required double salePrice1,
    double salePrice2 = 0,
    double salePrice3 = 0,
    required int number,
    required int saleCurrencyId,
    String? thumbnail,
    String? barcodeText,
    DateTime? lastUpdated,
    this.nameAr,
    this.nameEn,
    required this.categoryId,
    this.categoryName,
    this.images,
    this.isFeatured = false,
    this.featuredOrder,
    this.isNewArrival = false,
    this.isBestSeller = false,
    this.discount,
    this.description,
    this.brand,
    this.tags,
    this.isActive = true,
  }) : super(
    id: id,
    name: name,
    nameParts: nameParts,
    salePrice1: salePrice1,
    salePrice2: salePrice2,
    salePrice3: salePrice3,
    number: number,
    saleCurrencyId: saleCurrencyId,
    thumbnail: thumbnail,
    barcodeText: barcodeText,
    lastUpdated: lastUpdated,
  );

  factory EnhancedItem.fromFirestore(Map<String, dynamic> data, String docId) {
    // Handle both old and new field names
    return EnhancedItem(
      id: docId,
      name: data['name'] ?? '',
      nameAr: data['nameAr'] ?? data['name'],
      nameEn: data['nameEn'],
      nameParts: List<String>.from(data['nameParts'] ?? []),
      categoryId: data['categoryId'] ?? 'uncategorized',
      categoryName: data['categoryName'],
      // Handle both naming conventions for prices
      salePrice1: (data['SalePrice1'] ?? data['salePrice1'] ?? 0).toDouble(),
      salePrice2: (data['SalePrice2'] ?? data['salePrice2'] ?? 0).toDouble(),
      salePrice3: (data['SalePrice3'] ?? data['salePrice3'] ?? 0).toDouble(),
      // Handle both naming conventions for number
      number: data['Number'] ?? data['number'] ?? 0,
      saleCurrencyId: data['SaleCurrencyId'] ?? data['saleCurrencyId'] ?? 1,
      thumbnail: data['thumbnail'],
      images: data['images'] != null ? List<String>.from(data['images']) : null,
      isFeatured: data['isFeatured'] ?? false,
      featuredOrder: data['featuredOrder'],
      isNewArrival: data['isNewArrival'] ?? false,
      isBestSeller: data['isBestSeller'] ?? false,
      discount: data['discount']?.toDouble(),
      description: data['description'],
      brand: data['brand'],
      barcodeText: data['BarcodeText'] ?? data['barcodeText'],
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
      isActive: data['isActive'] ?? true,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  double get discountedPrice {
    if (discount != null && discount! > 0) {
      return salePrice1 * (1 - discount! / 100);
    }
    return salePrice1;
  }
}
// ============= MAIN STORE PAGE =============

class MedicalStorePage extends StatefulWidget {
  @override
  _EnhancedMedicalStorePageState createState() => _EnhancedMedicalStorePageState();
}

class _EnhancedMedicalStorePageState extends State<MedicalStorePage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController = PageController();
  late AnimationController _animationController;
  bool _isScrolled = false;
  Timer? _bannerTimer;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Data holders
  List<Banner> _banners = [];
  List<Category> _categories = [];
  List<EnhancedItem> _featuredProducts = [];
  List<EnhancedItem> _newArrivals = [];
  List<EnhancedItem> _bestSellers = [];

  // Loading states
  bool _isLoadingBanners = true;
  bool _isLoadingCategories = true;
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();

    _scrollController.addListener(() {
      setState(() {
        _isScrolled = _scrollController.offset > 50;
      });
    });

    _loadAllData();
    _startBannerTimer();
  }

  void _loadAllData() {
    _loadBanners();
    _loadCategories();
    _loadFeaturedProducts();
    _loadNewArrivals();
    _loadBestSellers();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = _bannerController.page!.round() + 1;
        if (nextPage >= _banners.length) {
          nextPage = 0;
        }
        _bannerController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadBanners() async {
    try {
      final snapshot = await _firestore
          .collection('banners')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      setState(() {
        _banners = snapshot.docs
            .map((doc) => Banner.fromFirestore(doc.data(), doc.id))
            .where((banner) {
          final now = DateTime.now();
          if (banner.startDate != null && now.isBefore(banner.startDate!)) return false;
          if (banner.endDate != null && now.isAfter(banner.endDate!)) return false;
          return true;
        })
            .toList();
        _isLoadingBanners = false;
      });
    } catch (e) {
      print('Error loading banners: $e');
      setState(() => _isLoadingBanners = false);
    }
  }

  Future<void> _loadCategories() async {
   // print('Starting to load categories...'); // Debug
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .limit(8)
          .get();

      print('Query executed. Found ${snapshot.docs.length} documents'); // Debug

      for (var doc in snapshot.docs) {
        print('Doc ID: ${doc.id}, Data: ${doc.data()}'); // Debug
      }

      setState(() {
        _categories = snapshot.docs
            .map((doc) => Category.fromFirestore(doc.data(), doc.id))
            .toList();
        _isLoadingCategories = false;
      });

      print('Categories loaded: ${_categories.length}'); // Debug
    } catch (e) {
      print('Error loading categories: $e'); // This will show the actual error
      print('Error type: ${e.runtimeType}'); // Debug
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadFeaturedProducts() async {
    try {
      final snapshot = await _firestore
          .collection('items1')
          .where('isFeatured', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .where('Number', isGreaterThan: 0)
          .orderBy('Number')
          .orderBy('featuredOrder')
          .limit(8)
          .get();

      setState(() {

        _featuredProducts = snapshot.docs
            .map((doc) => EnhancedItem.fromFirestore(doc.data(), doc.id))
            .toList();
        _isLoadingProducts = false;
        print( 'vvvvv' );
        print( _featuredProducts );
        print( 'vvvvv' );

      });
    } catch (e) {
      print('Error loading featured products: $e');
      setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _loadNewArrivals() async {
    try {
      final snapshot = await _firestore
          .collection('items1')
          .where('isNewArrival', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .where('Number', isGreaterThan: 0)
          .orderBy('Number')
          .limit(6)
          .get();

      setState(() {
        _newArrivals = snapshot.docs
            .map((doc) => EnhancedItem.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error loading new arrivals: $e');
    }
  }

  Future<void> _loadBestSellers() async {
    try {
      final snapshot = await _firestore
          .collection('items1')
          .where('isBestSeller', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .where('Number', isGreaterThan: 0)
          .orderBy('Number')
          .limit(6)
          .get();

      setState(() {
        _bestSellers = snapshot.docs
            .map((doc) => EnhancedItem.fromFirestore(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('Error loading best sellers: $e');
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
        endDrawer: _buildDrawer(),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => _loadAllData(),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Hero Section with Banners
                  SliverToBoxAdapter(
                    child: _buildHeroWithBanners(isDesktop, isMobile),
                  ),

                  // Categories Section
                  SliverToBoxAdapter(
                    child: _buildCategoriesSection(isDesktop, isMobile),
                  ),

                  // Featured Products
                  SliverToBoxAdapter(
                    child: _buildProductSection(
                      title: 'منتجات مميزة',
                      products: _featuredProducts,
                      isLoading: _isLoadingProducts,
                      isDesktop: isDesktop,
                      isMobile: isMobile,
                      showAllLink: true,
                    ),
                  ),

                  // New Arrivals
                  if (_newArrivals.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildProductSection(
                        title: 'وصل حديثاً',
                        products: _newArrivals,
                        isLoading: false,
                        isDesktop: isDesktop,
                        isMobile: isMobile,
                        backgroundColor: Colors.blue.shade50,
                      ),
                    ),

                  // Best Sellers
                  if (_bestSellers.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildProductSection(
                        title: 'الأكثر مبيعاً',
                        products: _bestSellers,
                        isLoading: false,
                        isDesktop: isDesktop,
                        isMobile: isMobile,
                      ),
                    ),

                  // Services Section
                  SliverToBoxAdapter(
                    child: _buildServicesSection(isDesktop, isMobile),
                  ),

                  // Footer
                  SliverToBoxAdapter(
                    child: _buildFooter(isDesktop, isMobile),
                  ),
                ],
              ),
            ),

            // Navigation Bar
            _buildNavBar(isDesktop, isMobile, cartProvider),
          ],
        ),
      ),
    );
  }

  // HERO SECTION WITH BANNER CAROUSEL
  Widget _buildHeroWithBanners(bool isDesktop, bool isMobile) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Stack(
        children: [
          // Banner Carousel
          if (_isLoadingBanners)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else if (_banners.isEmpty)
          // Default hero if no banners
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'رعاية طبية متميزة',
                      style: TextStyle(
                        fontSize: isDesktop ? 56 : 36,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'أفضل المستلزمات الطبية بجودة عالمية',
                      style: TextStyle(
                        fontSize: isDesktop ? 20 : 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            PageView.builder(
              controller: _bannerController,
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return GestureDetector(
                  onTap: () => _handleBannerTap(banner),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Banner Image
                      Image.network(
                        banner.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                              ),
                            ),
                          );
                        },
                      ),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                      // Banner Text
                      Positioned(
                        bottom: isDesktop ? 100 : 60,
                        left: isDesktop ? 60 : 20,
                        right: isDesktop ? 60 : 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner.titleAr,
                              style: TextStyle(
                                fontSize: isDesktop ? 48 : 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                            if (banner.subtitleAr != null) ...[
                              SizedBox(height: 12),
                              Text(
                                banner.subtitleAr!,
                                style: TextStyle(
                                  fontSize: isDesktop ? 20 : 16,
                                  color: Colors.white.withOpacity(0.9),
                                  shadows: [
                                    Shadow(
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // Page Indicators
          if (_banners.length > 1)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _banners.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(
                        _bannerController.hasClients &&
                            _bannerController.page?.round() == entry.key
                            ? 1.0
                            : 0.4,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _handleBannerTap(Banner banner) {
    switch (banner.actionType) {
      case 'category':
        if (banner.actionValue != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryItemsPage(
                categoryId: banner.actionValue!,
                categoryName: banner.titleAr,
              ),
            ),
          );
        }
        break;
      case 'product':
      // Navigate to product details
        break;
      case 'url':
      // Open URL
        break;
      default:
        break;
    }
  }

  // CATEGORIES SECTION
  Widget _buildCategoriesSection(bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 20,
        vertical: isDesktop ? 80 : 40,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأقسام',
                style: TextStyle(
                  fontSize: isDesktop ? 36 : 28,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllCategoriesPage(),
                    ),
                  );
                },
                child: Text(
                  'جميع الأقسام',
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: Color(0xFF0D47A1),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 60 : 30),

          if (_isLoadingCategories)
            Center(child: CircularProgressIndicator())
          else if (_categories.isEmpty)
            _buildEmptyState('لا توجد أقسام متاحة حالياً', Icons.category_outlined)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 4 : 2,
                childAspectRatio: isDesktop ? 1.3 : 1.1,
                crossAxisSpacing: isDesktop ? 30 : 15,
                mainAxisSpacing: isDesktop ? 30 : 15,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildEnhancedCategoryCard(category, isDesktop);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEnhancedCategoryCard(Category category, bool isDesktop) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryItemsPage(
              categoryName: category.nameAr,
              categoryId: category.id,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (category.imageUrl != null)
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Image.network(
                    category.imageUrl!,
                    width: 100,
                    height: 100,
                    errorBuilder: (context, error, stackTrace) => Container(),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.icon ?? '🏥',
                    style: TextStyle(fontSize: isDesktop ? 40 : 32),
                  ),
                  SizedBox(height: 12),
                  Text(
                    category.nameAr,
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${category.itemCount} منتج',
                    style: TextStyle(
                      fontSize: isDesktop ? 12 : 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PRODUCT SECTION BUILDER
  Widget _buildProductSection({
    required String title,
    required List<EnhancedItem> products,
    required bool isLoading,
    required bool isDesktop,
    required bool isMobile,
    bool showAllLink = false,
    Color? backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 20,
        vertical: isDesktop ? 60 : 30,
      ),
      color: backgroundColor ?? Colors.grey[50],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: isDesktop ? 32 : 24,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),
              if (showAllLink)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllProductsPage(),
                      ),
                    );
                  },
                  child: Text(
                    'عرض الكل',
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: isDesktop ? 40 : 20),

          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (products.isEmpty)
            _buildEmptyState('لا توجد منتجات متاحة حالياً', Icons.shopping_bag_outlined)
          else
            Container(
              height: isDesktop ? 440 : 380,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    width: isDesktop ? 280 : 200,
                    margin: EdgeInsets.only(left: isDesktop ? 20 : 15),
                    child: _buildEnhancedProductCard(product, isDesktop),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // ENHANCED PRODUCT CARD
  Widget _buildEnhancedProductCard(EnhancedItem product, bool isDesktop) {
    final hasDiscount = product.discount != null && product.discount! > 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailsPage(
              item: product,
              onAddToCart: (item, quantity) {
                final cartProvider = Provider.of<CartProvider>(context, listen: false);
                cartProvider.addToCart(item, quantity: quantity);
              },
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Container(
              height: isDesktop ? 240 : 180,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    child: product.thumbnail != null
                        ? Image.network(
                      product.thumbnail!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: Icon(Icons.image_outlined,
                                size: 50, color: Colors.grey),
                          ),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Icon(Icons.image_outlined,
                            size: 50, color: Colors.grey),
                      ),
                    ),
                  ),

                  // Badges
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Column(
                      children: [
                        if (hasDiscount)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${product.discount!.toInt()}%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (product.isNewArrival) ...[
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'جديد',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (!product.inStock) ...[
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'نفذ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.brand != null)
                          Text(
                            product.brand!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        SizedBox(height: 4),
                        Text(
                          product.nameAr ?? product.name,
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasDiscount)
                                  Text(
                                    product.formattedPrice,
                                    style: TextStyle(
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                                Text(
                                  '${product.currencySymbol} ${hasDiscount ? product.discountedPrice.toStringAsFixed(0) : product.salePrice1.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                              ],
                            ),
                            if (product.inStock)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'متوفر',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 12),

                        // Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: product.inStock
                                ? () => _showQuantityDialog(product)
                                : null,
                            icon: Icon(Icons.shopping_cart_outlined, size: 18),
                            label: Text('أضف للسلة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: product.inStock
                                  ? Color(0xFF0D47A1)
                                  : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 10),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        children: [
          Icon(icon, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // Rest of your existing methods (navbar, services, footer, drawer, quantity dialog, etc.)
  // ... [Keep all your existing methods like _buildNavBar, _buildServicesSection, etc.]

  void _showQuantityDialog(EnhancedItem product) {
    int quantity = 1;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      _showAuthDialog();
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.all(24),
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'إضافة إلى السلة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 20),
                Text(
                  product.nameAr ?? product.name,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) setState(() => quantity--);
                      },
                      icon: Icon(Icons.remove_circle_outline,
                          color: Color(0xFF0D47A1)),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$quantity',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (quantity < product.number) setState(() => quantity++);
                      },
                      icon: Icon(Icons.add_circle_outline,
                          color: Color(0xFF0D47A1)),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'المجموع: ${(product.discountedPrice * quantity).toStringAsFixed(0)} ${product.currencySymbol}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('إلغاء'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          cartProvider.addToCart(product, quantity: quantity);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تمت الإضافة إلى السلة'),
                              backgroundColor: Colors.green,
                              action: SnackBarAction(
                                label: 'عرض السلة',
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CartPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0D47A1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('إضافة'),
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
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('تسجيل الدخول مطلوب'),
        content: Text('يجب عليك تسجيل الدخول أولاً'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0D47A1),
            ),
            child: Text('تسجيل الدخول'),
          ),
        ],
      ),
    );
  }

  // Keep your existing navbar, drawer, services, footer methods here
  Widget _buildNavBar(bool isDesktop, bool isMobile, CartProvider cartProvider) {
    // Your existing navbar code
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
              : Colors.transparent,
          boxShadow: _isScrolled
              ? [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          )]
              : [],
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
                  if (isMobile)
                    Builder(
                      builder: (context) => IconButton(
                        icon: Icon(Icons.menu,
                            color: _isScrolled ? Colors.black87 : Colors.white),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                    ),
                  Text(
                    'أرض الطب',
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 20,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                      color: _isScrolled ? Colors.black87 : Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.search,
                            color: _isScrolled ? Colors.black54 : Colors.white),
                        onPressed: () => Navigator.pushNamed(context, '/search'),
                      ),
                      IconButton(
                        icon: Icon(Icons.person_outline,
                            color: _isScrolled ? Colors.black54 : Colors.white),
                        onPressed: () => Navigator.pushNamed(context, '/account'),
                      ),
                      SizedBox(width: 8),
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(Icons.shopping_bag_outlined,
                                color: _isScrolled ? Colors.black54 : Colors.white),
                            onPressed: () => Navigator.pushNamed(context, '/cart'),
                          ),
                          // ... cart badge
                        ],
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

  Widget _buildServicesSection(bool isDesktop, bool isMobile) {
    final services = [
      {'icon': Icons.local_shipping_outlined, 'title': 'توصيل سريع', 'subtitle': 'خلال 24 ساعة'},
      {'icon': Icons.verified_outlined, 'title': 'منتجات أصلية', 'subtitle': 'ضمان 100%'},
      {'icon': Icons.support_agent_outlined, 'title': 'دعم متواصل', 'subtitle': '24/7'},
      {'icon': Icons.card_giftcard_outlined, 'title': 'عروض حصرية', 'subtitle': 'خصومات مميزة'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 20,
        vertical: isDesktop ? 80 : 40,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 4 : 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: isDesktop ? 30 : 15,
          mainAxisSpacing: isDesktop ? 30 : 15,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF0D47A1).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  service['icon'] as IconData,
                  size: isDesktop ? 32 : 24,
                  color: Color(0xFF0D47A1),
                ),
              ),
              SizedBox(height: 12),
              Text(
                service['title'] as String,
                style: TextStyle(
                  fontSize: isDesktop ? 16 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                service['subtitle'] as String,
                style: TextStyle(
                  fontSize: isDesktop ? 14 : 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFooter(bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 20,
        vertical: isDesktop ? 60 : 30,
      ),
      color: Color(0xFF0D47A1),
      child: Column(
        children: [
          Text(
            'أرض الطب',
            style: TextStyle(
              fontSize: isDesktop ? 32 : 24,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'info@arthultib.com | +964 780 017 5770',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 30),
          Text(
            '© 2024 جميع الحقوق محفوظة',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Colors.white60,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(

      child: Container(

        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [

              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  ),
                ),
                child: Center(
                  child: Text(
                    'أرض الطب',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: Icon(Icons.home_outlined, color: Color(0xFF0D47A1)),
                      title: Text('الرئيسية'),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: Icon(Icons.category_outlined, color: Color(0xFF0D47A1)),
                      title: Text('الأقسام'),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: Icon(Icons.shopping_bag_outlined, color: Color(0xFF0D47A1)),
                      title: Text('السلة'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => CartPage()));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.person_outline, color: Color(0xFF0D47A1)),
                      title: Text('حسابي'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/account');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.favorite_outline, color: Color(0xFF0D47A1)),
                      title: Text('المفضلة'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/saved-items');
                      },
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

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }
}

// Placeholder Pages - Replace with your actual implementations
class CategoryItemsPage extends StatelessWidget {
  final String categoryName;
  final String categoryId;

  CategoryItemsPage({required this.categoryName, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: Center(child: Text('Category: $categoryName')),
    );
  }
}

class AllCategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('جميع الأقسام')),
      body: Center(child: Text('All Categories')),
    );
  }
}

class AllProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('جميع المنتجات')),
      body: Center(child: Text('All Products')),
    );
  }
}

class ProductDetailsPage extends StatelessWidget {
  final EnhancedItem item;

  ProductDetailsPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.nameAr ?? item.name)),
      body: Center(child: Text('Product: ${item.name}')),
    );
  }
}



class ItemAdapter {
  static Map<String, dynamic> fromStockToEnhanced(Map<String, dynamic> stockItem) {
    // Convert your existing stock item to enhanced format
    return {
      'name': stockItem['name'],
      'nameAr': stockItem['name'], // Using name as nameAr for now
      'nameEn': null, // Can be added later
      'nameParts': stockItem['nameParts'] ?? [],
      'namePartsLower': stockItem['namePartsLower'] ?? [],

      // Prices
      'SalePrice1': stockItem['SalePrice1'] ?? 0,
      'SalePrice2': stockItem['SalePrice2'] ?? 0,
      'SalePrice3': stockItem['SalePrice3'] ?? 0,
      'SalePricePrivate': stockItem['SalePricePrivate'] ?? 0,
      'SalePriceWhole': stockItem['SalePriceWhole'] ?? 0,

      // Stock info
      'Number': stockItem['Number'] ?? 0,
      'SaleCurrencyId': stockItem['SaleCurrencyId'] ?? 1,
      'BarcodeText': stockItem['BarcodeText'] ?? '',

      // Enhanced fields (defaults)
      'categoryId': stockItem['categoryId'] ?? 'uncategorized',
      'categoryName': stockItem['categoryName'] ?? 'غير مصنف',
      'thumbnail': stockItem['thumbnail'],
      'images': stockItem['images'] ?? [],

      // Feature flags
      'isFeatured': stockItem['isFeatured'] ?? false,
      'featuredOrder': stockItem['featuredOrder'] ?? 999,
      'isNewArrival': stockItem['isNewArrival'] ?? false,
      'isBestSeller': stockItem['isBestSeller'] ?? false,

      // Additional info
      'discount': stockItem['discount'] ?? 0,
      'description': stockItem['description'] ?? '',
      'brand': stockItem['brand'] ?? '',
      'tags': stockItem['tags'] ?? [],
      'isActive': stockItem['isActive'] ?? true,

      // Timestamps
      'lastUpdated': stockItem['lastUpdated'] ?? FieldValue.serverTimestamp(),
      'lastSoldAt': stockItem['lastSoldAt'],
      'createdAt': stockItem['createdAt'] ?? FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> updateFromStock(
      Map<String, dynamic> enhancedItem,
      Map<String, dynamic> stockUpdate) {
    // Update only stock-related fields from your inventory system
    enhancedItem['Number'] = stockUpdate['Number'] ?? enhancedItem['Number'];
    enhancedItem['SalePrice1'] = stockUpdate['SalePrice1'] ?? enhancedItem['SalePrice1'];
    enhancedItem['SalePrice2'] = stockUpdate['SalePrice2'] ?? enhancedItem['SalePrice2'];
    enhancedItem['SalePrice3'] = stockUpdate['SalePrice3'] ?? enhancedItem['SalePrice3'];
    enhancedItem['lastUpdated'] = FieldValue.serverTimestamp();

    return enhancedItem;
  }
}
