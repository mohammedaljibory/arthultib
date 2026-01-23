// LUXURY MEDICAL STORE - FORMAL ELEGANT DESIGN

import 'dart:math';

import 'package:company_website/sections/product_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:async';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../language_provider.dart';
import '../models/item.dart';
import '../screens/cartPage_m.dart';
import '../screens/categoryItemPage.dart';

// ============= LUXURY COLORS =============
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
    return EnhancedItem(
      id: docId,
      name: data['name'] ?? '',
      nameAr: data['nameAr'] ?? data['name'],
      nameEn: data['nameEn'],
      nameParts: List<String>.from(data['nameParts'] ?? []),
      categoryId: data['categoryId'] ?? 'uncategorized',
      categoryName: data['categoryName'],
      salePrice1: (data['SalePrice1'] ?? data['salePrice1'] ?? 0).toDouble(),
      salePrice2: (data['SalePrice2'] ?? data['salePrice2'] ?? 0).toDouble(),
      salePrice3: (data['SalePrice3'] ?? data['salePrice3'] ?? 0).toDouble(),
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

  List<Banner> _banners = [];
  List<Category> _categories = [];
  List<EnhancedItem> _featuredProducts = [];
  List<EnhancedItem> _newArrivals = [];
  List<EnhancedItem> _bestSellers = [];

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
    _bannerTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_bannerController.hasClients && _banners.isNotEmpty) {
        int nextPage = _bannerController.page!.round() + 1;
        if (nextPage >= _banners.length) {
          nextPage = 0;
        }
        _bannerController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 600),
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
        }).toList();
        _isLoadingBanners = false;
      });
    } catch (e) {
      print('Error loading banners: $e');
      setState(() => _isLoadingBanners = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .limit(8)
          .get();

      setState(() {
        _categories = snapshot.docs
            .map((doc) => Category.fromFirestore(doc.data(), doc.id))
            .toList();
        _isLoadingCategories = false;
      });
    } catch (e) {
      print('Error loading categories: $e');
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
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Directionality(
      textDirection: languageProvider.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: LuxuryColors.cream,
        endDrawer: _buildLuxuryDrawer(),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => _loadAllData(),
              color: LuxuryColors.gold,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Luxury Hero Section
                  SliverToBoxAdapter(
                    child: _buildLuxuryHero(isDesktop, isMobile),
                  ),

                  // Categories Section
                  SliverToBoxAdapter(
                    child: _buildLuxuryCategoriesSection(isDesktop, isMobile),
                  ),

                  // Featured Products
                  SliverToBoxAdapter(
                    child: _buildLuxuryProductSection(
                      title: 'مجموعة مميزة',
                      subtitle: 'اختيارات فاخرة لعملائنا',
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
                      child: _buildLuxuryProductSection(
                        title: 'وصل حديثاً',
                        subtitle: 'أحدث المنتجات الطبية',
                        products: _newArrivals,
                        isLoading: false,
                        isDesktop: isDesktop,
                        isMobile: isMobile,
                        isDark: true,
                      ),
                    ),

                  // Best Sellers
                  if (_bestSellers.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildLuxuryProductSection(
                        title: 'الأكثر طلباً',
                        subtitle: 'المنتجات المفضلة لدى عملائنا',
                        products: _bestSellers,
                        isLoading: false,
                        isDesktop: isDesktop,
                        isMobile: isMobile,
                      ),
                    ),

                  // Services Section
                  SliverToBoxAdapter(
                    child: _buildLuxuryServicesSection(isDesktop, isMobile),
                  ),

                  // Footer
                  SliverToBoxAdapter(
                    child: _buildLuxuryFooter(isDesktop, isMobile),
                  ),
                ],
              ),
            ),

            // Luxury Navigation Bar
            _buildLuxuryNavBar(isDesktop, isMobile, cartProvider),
          ],
        ),
      ),
    );
  }

  // LUXURY HERO SECTION
  Widget _buildLuxuryHero(bool isDesktop, bool isMobile) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Stack(
        children: [
          if (_isLoadingBanners)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [LuxuryColors.darkNavy, LuxuryColors.navy],
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: LuxuryColors.gold,
                  strokeWidth: 1,
                ),
              ),
            )
          else if (_banners.isEmpty)
            _buildDefaultLuxuryHero(isDesktop, isMobile)
          else
            PageView.builder(
              controller: _bannerController,
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return _buildBannerSlide(banner, isDesktop, isMobile);
              },
            ),

          // Page Indicators
          if (_banners.length > 1)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _banners.asMap().entries.map((entry) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: _bannerController.hasClients &&
                        _bannerController.page?.round() == entry.key
                        ? 30
                        : 8,
                    height: 3,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _bannerController.hasClients &&
                          _bannerController.page?.round() == entry.key
                          ? LuxuryColors.gold
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultLuxuryHero(bool isDesktop, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LuxuryColors.darkNavy, LuxuryColors.navy, LuxuryColors.charcoal],
        ),
      ),
      child: Stack(
        children: [
          // Subtle pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://www.transparenttextures.com/patterns/subtle-white-feathers.png',
                    ),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
              ),
            ),
          ),
          // Gold accent line
          Positioned(
            top: isDesktop ? 200 : 150,
            left: isDesktop ? 60 : 20,
            child: Container(
              width: 80,
              height: 2,
              color: LuxuryColors.gold,
            ),
          ),
          // Content
          Positioned(
            bottom: isDesktop ? 120 : 80,
            left: isDesktop ? 60 : 20,
            right: isDesktop ? 60 : 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أرض الطب',
                  style: TextStyle(
                    fontSize: isDesktop ? 64 : 40,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    letterSpacing: 6,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'التميز في المستلزمات الطبية',
                  style: TextStyle(
                    fontSize: isDesktop ? 22 : 16,
                    color: LuxuryColors.gold,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 40 : 30,
                    vertical: isDesktop ? 18 : 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: LuxuryColors.gold, width: 1),
                  ),
                  child: Text(
                    'استكشف المجموعة',
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      color: LuxuryColors.gold,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w400,
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

  Widget _buildBannerSlide(Banner banner, bool isDesktop, bool isMobile) {
    return GestureDetector(
      onTap: () => _handleBannerTap(banner),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            banner.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultLuxuryHero(isDesktop, isMobile);
            },
          ),
          // Elegant gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.6),
                ],
              ),
            ),
          ),
          // Gold accent line
          Positioned(
            bottom: isDesktop ? 160 : 120,
            left: isDesktop ? 60 : 20,
            child: Container(
              width: 60,
              height: 2,
              color: LuxuryColors.gold,
            ),
          ),
          // Banner text
          Positioned(
            bottom: isDesktop ? 80 : 60,
            left: isDesktop ? 60 : 20,
            right: isDesktop ? 60 : 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  banner.titleAr,
                  style: TextStyle(
                    fontSize: isDesktop ? 48 : 28,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                if (banner.subtitleAr != null) ...[
                  SizedBox(height: 12),
                  Text(
                    banner.subtitleAr!,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 14,
                      color: LuxuryColors.gold,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ],
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
      default:
        break;
    }
  }

  // LUXURY CATEGORIES SECTION
  Widget _buildLuxuryCategoriesSection(bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 100 : 60,
      ),
      color: Colors.white,
      child: Column(
        children: [
          // Section Header
          _buildLuxurySectionHeader(
            title: 'الأقسام',
            subtitle: 'اختر من مجموعتنا المتنوعة',
            onViewAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllCategoriesPage()),
              );
            },
          ),
          SizedBox(height: isDesktop ? 60 : 40),

          if (_isLoadingCategories)
            Center(
              child: CircularProgressIndicator(
                color: LuxuryColors.gold,
                strokeWidth: 1,
              ),
            )
          else if (_categories.isEmpty)
            _buildEmptyState('لا توجد أقسام متاحة حالياً', Icons.category_outlined)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 4 : 2,
                childAspectRatio: isDesktop ? 1.0 : 0.9,
                crossAxisSpacing: isDesktop ? 30 : 16,
                mainAxisSpacing: isDesktop ? 30 : 16,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildLuxuryCategoryCard(category, isDesktop);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLuxuryCategoryCard(Category category, bool isDesktop) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
        child: Container(
          decoration: BoxDecoration(
            color: LuxuryColors.cream,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Stack(
            children: [
              // Background image if available
              if (category.imageUrl != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.08,
                    child: Image.network(
                      category.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(),
                    ),
                  ),
                ),
              // Content
              Padding(
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon container with gold border
                    Container(
                      width: isDesktop ? 70 : 56,
                      height: isDesktop ? 70 : 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: LuxuryColors.gold.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          category.icon ?? '🏥',
                          style: TextStyle(fontSize: isDesktop ? 28 : 24),
                        ),
                      ),
                    ),
                    SizedBox(height: isDesktop ? 20 : 14),
                    Text(
                      category.nameAr,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: LuxuryColors.navy,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${category.itemCount} منتج',
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 11,
                        color: LuxuryColors.gold,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Hover line indicator
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  color: LuxuryColors.gold.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LUXURY PRODUCT SECTION
  Widget _buildLuxuryProductSection({
    required String title,
    required String subtitle,
    required List<EnhancedItem> products,
    required bool isLoading,
    required bool isDesktop,
    required bool isMobile,
    bool showAllLink = false,
    bool isDark = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 100 : 60,
      ),
      color: isDark ? LuxuryColors.navy : LuxuryColors.cream,
      child: Column(
        children: [
          _buildLuxurySectionHeader(
            title: title,
            subtitle: subtitle,
            isLight: isDark,
            onViewAll: showAllLink
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllProductsPage()),
              );
            }
                : null,
          ),
          SizedBox(height: isDesktop ? 60 : 40),

          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: LuxuryColors.gold,
                strokeWidth: 1,
              ),
            )
          else if (products.isEmpty)
            _buildEmptyState(
              'لا توجد منتجات متاحة',
              Icons.shopping_bag_outlined,
              isDark: isDark,
            )
          else
            Container(
              height: isDesktop ? 480 : 400,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    width: isDesktop ? 320 : 220,
                    margin: EdgeInsets.only(left: isDesktop ? 30 : 16),
                    child: _buildLuxuryProductCard(product, isDesktop, isDark),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // LUXURY PRODUCT CARD
  Widget _buildLuxuryProductCard(EnhancedItem product, bool isDesktop, bool isDark) {
    final hasDiscount = product.discount != null && product.discount! > 0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? LuxuryColors.charcoal : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade200,
            ),
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
                      color: isDark ? LuxuryColors.navy : LuxuryColors.cream,
                      child: product.thumbnail != null
                          ? Image.network(
                        product.thumbnail!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.medical_services_outlined,
                              size: 40,
                              color: LuxuryColors.silver,
                            ),
                          );
                        },
                      )
                          : Center(
                        child: Icon(
                          Icons.medical_services_outlined,
                          size: 40,
                          color: LuxuryColors.silver,
                        ),
                      ),
                    ),

                    // Badges
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (hasDiscount)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              color: LuxuryColors.gold,
                              child: Text(
                                '-${product.discount!.toInt()}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          if (product.isNewArrival && !hasDiscount) ...[
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              color: LuxuryColors.navy,
                              child: Text(
                                'جديد',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
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
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 20 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.brand != null)
                            Text(
                              product.brand!.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: LuxuryColors.gold,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.5,
                              ),
                            ),
                          SizedBox(height: 6),
                          Text(
                            product.nameAr ?? product.name,
                            style: TextStyle(
                              fontSize: isDesktop ? 15 : 14,
                              fontWeight: FontWeight.w400,
                              color: isDark ? Colors.white : LuxuryColors.navy,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
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
                                        color: isDark ? Colors.white38 : Colors.grey,
                                      ),
                                    ),
                                  Text(
                                    '${product.currencySymbol} ${hasDiscount ? product.discountedPrice.toStringAsFixed(0) : product.salePrice1.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: isDesktop ? 18 : 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? LuxuryColors.gold : LuxuryColors.navy,
                                    ),
                                  ),
                                ],
                              ),
                              if (product.inStock)
                                GestureDetector(
                                  onTap: () => _showQuantityDialog(product),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isDark ? LuxuryColors.gold : LuxuryColors.navy,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      size: 18,
                                      color: isDark ? LuxuryColors.gold : LuxuryColors.navy,
                                    ),
                                  ),
                                ),
                            ],
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

  Widget _buildLuxurySectionHeader({
    required String title,
    required String subtitle,
    bool isLight = false,
    VoidCallback? onViewAll,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 2,
                  color: LuxuryColors.gold,
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                    color: isLight ? Colors.white : LuxuryColors.navy,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isLight ? Colors.white60 : Colors.grey[600],
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: Row(
                  children: [
                    Text(
                      'عرض الكل',
                      style: TextStyle(
                        fontSize: 13,
                        color: LuxuryColors.gold,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: LuxuryColors.gold,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon, {bool isDark = false}) {
    return Center(
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: isDark ? Colors.white24 : Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(32),
            width: 380,
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
                  'إضافة إلى السلة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  product.nameAr ?? product.name,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (quantity > 1) setState(() => quantity--);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Icon(Icons.remove, size: 18),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade300),
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        '$quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (quantity < product.number) setState(() => quantity++);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Icon(Icons.add, size: 18),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Text(
                  '${(product.discountedPrice * quantity).toStringAsFixed(0)} ${product.currencySymbol}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: LuxuryColors.navy,
                  ),
                ),
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            color: Colors.grey[600],
                            letterSpacing: 0.5,
                          ),
                        ),
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
                              backgroundColor: LuxuryColors.navy,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
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
                          'إضافة',
                          style: TextStyle(letterSpacing: 1),
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
            ],
          ),
        ),
      ),
    );
  }

  // LUXURY NAVIGATION BAR
  Widget _buildLuxuryNavBar(bool isDesktop, bool isMobile, CartProvider cartProvider) {
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
              : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: _isScrolled ? LuxuryColors.platinum : Colors.transparent,
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
                  if (isMobile)
                    Builder(
                      builder: (context) => IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: _isScrolled ? LuxuryColors.navy : Colors.white,
                        ),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                    ),
                  // Logo
                  Text(
                    'أرض الطب',
                    style: TextStyle(
                      fontSize: isDesktop ? 26 : 20,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                      color: _isScrolled ? LuxuryColors.navy : Colors.white,
                    ),
                  ),
                  // Actions
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.search,
                          color: _isScrolled ? LuxuryColors.navy : Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/search'),
                      ),
                      SizedBox(width: 4),
                      IconButton(
                        icon: Icon(
                          Icons.person_outline,
                          color: _isScrolled ? LuxuryColors.navy : Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.pushNamed(context, '/account'),
                      ),
                      SizedBox(width: 4),
                      Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.shopping_bag_outlined,
                              color: _isScrolled ? LuxuryColors.navy : Colors.white,
                              size: 22,
                            ),
                            onPressed: () => Navigator.pushNamed(context, '/cart'),
                          ),
                          if (cartProvider.itemCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // LUXURY SERVICES SECTION
  Widget _buildLuxuryServicesSection(bool isDesktop, bool isMobile) {
    final services = [
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'توصيل فاخر',
        'subtitle': 'خدمة توصيل سريعة ومميزة'
      },
      {
        'icon': Icons.verified_outlined,
        'title': 'جودة مضمونة',
        'subtitle': 'منتجات أصلية 100%'
      },
      {
        'icon': Icons.support_agent_outlined,
        'title': 'دعم متميز',
        'subtitle': 'خدمة عملاء على مدار الساعة'
      },
      {
        'icon': Icons.card_giftcard_outlined,
        'title': 'عروض حصرية',
        'subtitle': 'خصومات خاصة لعملائنا'
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 100 : 60,
      ),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 2,
            color: LuxuryColors.gold,
          ),
          SizedBox(height: 16),
          Text(
            'لماذا نحن',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
              color: LuxuryColors.navy,
            ),
          ),
          SizedBox(height: isDesktop ? 60 : 40),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 2,
              childAspectRatio: isDesktop ? 1.2 : 1.0,
              crossAxisSpacing: isDesktop ? 40 : 20,
              mainAxisSpacing: isDesktop ? 40 : 20,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Container(
                padding: EdgeInsets.all(isDesktop ? 30 : 20),
                decoration: BoxDecoration(
                  color: LuxuryColors.cream,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: isDesktop ? 60 : 48,
                      height: isDesktop ? 60 : 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: LuxuryColors.gold.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        service['icon'] as IconData,
                        size: isDesktop ? 26 : 22,
                        color: LuxuryColors.gold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      service['title'] as String,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.w500,
                        color: LuxuryColors.navy,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      service['subtitle'] as String,
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // LUXURY FOOTER
  Widget _buildLuxuryFooter(bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 80 : 50,
      ),
      color: LuxuryColors.darkNavy,
      child: Column(
        children: [
          // Logo
          Text(
            'أرض الطب',
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: 60,
            height: 1,
            color: LuxuryColors.gold,
          ),
          SizedBox(height: 30),
          Text(
            'التميز في المستلزمات الطبية',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              color: LuxuryColors.gold,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 40),
          // Contact Info
          Text(
            'info@arthultib.com | +964 780 017 5770',
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Colors.white60,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 40),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
          SizedBox(height: 30),
          Text(
            '© 2024 أرض الطب - جميع الحقوق محفوظة',
            style: TextStyle(
              fontSize: isDesktop ? 12 : 11,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // LUXURY DRAWER
  Widget _buildLuxuryDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(40),
                color: LuxuryColors.navy,
                width: double.infinity,
                child: Column(
                  children: [
                    Text(
                      'أرض الطب',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.w200,
                        letterSpacing: 4,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 1,
                      color: LuxuryColors.gold,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  children: [
                    _buildDrawerItem(Icons.home_outlined, 'الرئيسية', () {
                      Navigator.pop(context);
                    }),
                    _buildDrawerItem(Icons.category_outlined, 'الأقسام', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AllCategoriesPage()),
                      );
                    }),
                    _buildDrawerItem(Icons.shopping_bag_outlined, 'السلة', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CartPage()),
                      );
                    }),
                    _buildDrawerItem(Icons.person_outline, 'حسابي', () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/account');
                    }),
                    _buildDrawerItem(Icons.favorite_outline, 'المفضلة', () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/saved-items');
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: LuxuryColors.navy, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
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

// Placeholder Pages
class AllCategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جميع الأقسام'),
        backgroundColor: LuxuryColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(child: Text('All Categories')),
    );
  }
}

class AllProductsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جميع المنتجات'),
        backgroundColor: LuxuryColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
    return {
      'name': stockItem['name'],
      'nameAr': stockItem['name'],
      'nameEn': null,
      'nameParts': stockItem['nameParts'] ?? [],
      'namePartsLower': stockItem['namePartsLower'] ?? [],
      'SalePrice1': stockItem['SalePrice1'] ?? 0,
      'SalePrice2': stockItem['SalePrice2'] ?? 0,
      'SalePrice3': stockItem['SalePrice3'] ?? 0,
      'SalePricePrivate': stockItem['SalePricePrivate'] ?? 0,
      'SalePriceWhole': stockItem['SalePriceWhole'] ?? 0,
      'Number': stockItem['Number'] ?? 0,
      'SaleCurrencyId': stockItem['SaleCurrencyId'] ?? 1,
      'BarcodeText': stockItem['BarcodeText'] ?? '',
      'categoryId': stockItem['categoryId'] ?? 'uncategorized',
      'categoryName': stockItem['categoryName'] ?? 'غير مصنف',
      'thumbnail': stockItem['thumbnail'],
      'images': stockItem['images'] ?? [],
      'isFeatured': stockItem['isFeatured'] ?? false,
      'featuredOrder': stockItem['featuredOrder'] ?? 999,
      'isNewArrival': stockItem['isNewArrival'] ?? false,
      'isBestSeller': stockItem['isBestSeller'] ?? false,
      'discount': stockItem['discount'] ?? 0,
      'description': stockItem['description'] ?? '',
      'brand': stockItem['brand'] ?? '',
      'tags': stockItem['tags'] ?? [],
      'isActive': stockItem['isActive'] ?? true,
      'lastUpdated': stockItem['lastUpdated'] ?? FieldValue.serverTimestamp(),
      'lastSoldAt': stockItem['lastSoldAt'],
      'createdAt': stockItem['createdAt'] ?? FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> updateFromStock(
      Map<String, dynamic> enhancedItem,
      Map<String, dynamic> stockUpdate) {
    enhancedItem['Number'] = stockUpdate['Number'] ?? enhancedItem['Number'];
    enhancedItem['SalePrice1'] = stockUpdate['SalePrice1'] ?? enhancedItem['SalePrice1'];
    enhancedItem['SalePrice2'] = stockUpdate['SalePrice2'] ?? enhancedItem['SalePrice2'];
    enhancedItem['SalePrice3'] = stockUpdate['SalePrice3'] ?? enhancedItem['SalePrice3'];
    enhancedItem['lastUpdated'] = FieldValue.serverTimestamp();
    return enhancedItem;
  }
}
