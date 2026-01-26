// MEDICAL PROFESSIONAL STORE - CLEAN TRUSTED DESIGN

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

// ============= MEDICAL PROFESSIONAL COLORS =============
class MedicalColors {
  // Primary Medical Colors
  static const Color primary = Color(0xFF0891B2);       // Medical Teal
  static const Color primaryDark = Color(0xFF0E7490);   // Dark Teal
  static const Color primaryLight = Color(0xFF22D3EE);  // Light Cyan

  // Secondary Colors
  static const Color secondary = Color(0xFF059669);     // Medical Green
  static const Color secondaryLight = Color(0xFF10B981); // Emerald

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC);    // Light Gray
  static const Color surface = Color(0xFFFFFFFF);       // White
  static const Color cardBg = Color(0xFFFFFFFF);        // White

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);   // Slate 800
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textLight = Color(0xFF94A3B8);     // Slate 400

  // Accent Colors
  static const Color accent = Color(0xFF0EA5E9);        // Sky Blue
  static const Color success = Color(0xFF22C55E);       // Green
  static const Color warning = Color(0xFFF59E0B);       // Amber
  static const Color error = Color(0xFFEF4444);         // Red

  // Border
  static const Color border = Color(0xFFE2E8F0);        // Slate 200
  static const Color divider = Color(0xFFF1F5F9);       // Slate 100
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
        backgroundColor: MedicalColors.background,
        endDrawer: _buildMedicalDrawer(),
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => _loadAllData(),
              color: MedicalColors.primary,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Medical Hero Section
                  SliverToBoxAdapter(
                    child: _buildMedicalHero(isDesktop, isMobile),
                  ),

                  // Trust Badges Section
                  SliverToBoxAdapter(
                    child: _buildTrustBadges(isDesktop, isMobile),
                  ),

                  // Categories Section
                  SliverToBoxAdapter(
                    child: _buildMedicalCategoriesSection(isDesktop, isMobile),
                  ),

                  // Featured Products
                  SliverToBoxAdapter(
                    child: _buildMedicalProductSection(
                      title: 'المنتجات المميزة',
                      subtitle: 'منتجات طبية معتمدة وموثوقة',
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
                      child: _buildMedicalProductSection(
                        title: 'وصل حديثاً',
                        subtitle: 'أحدث المستلزمات الطبية',
                        products: _newArrivals,
                        isLoading: false,
                        isDesktop: isDesktop,
                        isMobile: isMobile,
                        accentColor: MedicalColors.secondary,
                      ),
                    ),

                  // Best Sellers
                  if (_bestSellers.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildMedicalProductSection(
                        title: 'الأكثر مبيعاً',
                        subtitle: 'المنتجات الأكثر طلباً من عملائنا',
                        products: _bestSellers,
                        isLoading: false,
                        isDesktop: isDesktop,
                        isMobile: isMobile,
                        accentColor: MedicalColors.accent,
                      ),
                    ),

                  // Why Choose Us Section
                  SliverToBoxAdapter(
                    child: _buildWhyChooseUsSection(isDesktop, isMobile),
                  ),

                  // Footer
                  SliverToBoxAdapter(
                    child: _buildMedicalFooter(isDesktop, isMobile),
                  ),
                ],
              ),
            ),

            // Medical Navigation Bar
            _buildMedicalNavBar(isDesktop, isMobile, cartProvider),
          ],
        ),
      ),
    );
  }

  // MEDICAL HERO SECTION
  Widget _buildMedicalHero(bool isDesktop, bool isMobile) {
    return Container(
      height: MediaQuery.of(context).size.height * (isMobile ? 0.55 : 0.65),
      child: Stack(
        children: [
          if (_isLoadingBanners)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [MedicalColors.primary, MedicalColors.primaryDark],
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_banners.isEmpty)
            _buildDefaultMedicalHero(isDesktop, isMobile)
          else
            PageView.builder(
              controller: _bannerController,
              itemCount: _banners.length,
              itemBuilder: (context, index) {
                final banner = _banners[index];
                return _buildMedicalBannerSlide(banner, isDesktop, isMobile);
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
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: _bannerController.hasClients &&
                        _bannerController.page?.round() == entry.key
                        ? 24
                        : 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _bannerController.hasClients &&
                          _bannerController.page?.round() == entry.key
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultMedicalHero(bool isDesktop, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MedicalColors.primary,
            MedicalColors.primaryDark,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Medical pattern overlay
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: MedicalPatternPainter(),
              ),
            ),
          ),
          // Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 60),
                  // Medical Icon
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_hospital_rounded,
                      size: isDesktop ? 60 : 48,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'أرض الطب',
                    style: TextStyle(
                      fontSize: isDesktop ? 52 : 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'مستلزمات طبية موثوقة ومعتمدة',
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 16,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      _scrollController.animateTo(
                        MediaQuery.of(context).size.height * 0.5,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: MedicalColors.primary,
                      padding: EdgeInsets.symmetric(
                        horizontal: isDesktop ? 48 : 36,
                        vertical: isDesktop ? 18 : 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'تصفح المنتجات',
                          style: TextStyle(
                            fontSize: isDesktop ? 16 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalBannerSlide(Banner banner, bool isDesktop, bool isMobile) {
    return GestureDetector(
      onTap: () => _handleBannerTap(banner),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            banner.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultMedicalHero(isDesktop, isMobile);
            },
          ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  MedicalColors.primary.withOpacity(0.3),
                  MedicalColors.primaryDark.withOpacity(0.8),
                ],
              ),
            ),
          ),
          // Banner text
          Positioned(
            bottom: isDesktop ? 80 : 60,
            left: isDesktop ? 80 : 24,
            right: isDesktop ? 80 : 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: MedicalColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'عرض خاص',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  banner.titleAr,
                  style: TextStyle(
                    fontSize: isDesktop ? 42 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (banner.subtitleAr != null) ...[
                  SizedBox(height: 12),
                  Text(
                    banner.subtitleAr!,
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 14,
                      color: Colors.white.withOpacity(0.9),
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

  // Trust Badges Section
  Widget _buildTrustBadges(bool isDesktop, bool isMobile) {
    final badges = [
      {'icon': Icons.verified_outlined, 'text': 'منتجات أصلية 100%'},
      {'icon': Icons.local_shipping_outlined, 'text': 'توصيل سريع'},
      {'icon': Icons.support_agent_outlined, 'text': 'دعم 24/7'},
      {'icon': Icons.security_outlined, 'text': 'دفع آمن'},
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      color: MedicalColors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 80 : 20),
        child: Row(
          children: badges.map((badge) {
            return Container(
              margin: EdgeInsets.only(left: isDesktop ? 60 : 24),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: MedicalColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      badge['icon'] as IconData,
                      color: MedicalColors.primary,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    badge['text'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: MedicalColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
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

  // MEDICAL CATEGORIES SECTION
  Widget _buildMedicalCategoriesSection(bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 60 : 40,
      ),
      color: MedicalColors.background,
      child: Column(
        children: [
          // Section Header
          _buildMedicalSectionHeader(
            title: 'الأقسام الطبية',
            subtitle: 'تصفح حسب التخصص',
            onViewAll: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllCategoriesPage()),
              );
            },
          ),
          SizedBox(height: isDesktop ? 40 : 24),

          if (_isLoadingCategories)
            Center(
              child: CircularProgressIndicator(
                color: MedicalColors.primary,
                strokeWidth: 2,
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
                childAspectRatio: isDesktop ? 1.1 : 1.0,
                crossAxisSpacing: isDesktop ? 24 : 12,
                mainAxisSpacing: isDesktop ? 24 : 12,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildMedicalCategoryCard(category, isDesktop);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMedicalCategoryCard(Category category, bool isDesktop) {
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
            color: MedicalColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: EdgeInsets.all(isDesktop ? 20 : 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon container
                    Container(
                      width: isDesktop ? 64 : 52,
                      height: isDesktop ? 64 : 52,
                      decoration: BoxDecoration(
                        color: MedicalColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          category.icon ?? '🏥',
                          style: TextStyle(fontSize: isDesktop ? 28 : 24),
                        ),
                      ),
                    ),
                    SizedBox(height: isDesktop ? 16 : 12),
                    Text(
                      category.nameAr,
                      style: TextStyle(
                        fontSize: isDesktop ? 15 : 13,
                        fontWeight: FontWeight.w600,
                        color: MedicalColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: MedicalColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${category.itemCount} منتج',
                        style: TextStyle(
                          fontSize: 11,
                          color: MedicalColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  // MEDICAL PRODUCT SECTION
  Widget _buildMedicalProductSection({
    required String title,
    required String subtitle,
    required List<EnhancedItem> products,
    required bool isLoading,
    required bool isDesktop,
    required bool isMobile,
    bool showAllLink = false,
    Color accentColor = MedicalColors.primary,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 60 : 40,
      ),
      color: MedicalColors.surface,
      child: Column(
        children: [
          _buildMedicalSectionHeader(
            title: title,
            subtitle: subtitle,
            accentColor: accentColor,
            onViewAll: showAllLink
                ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllProductsPage()),
              );
            }
                : null,
          ),
          SizedBox(height: isDesktop ? 40 : 24),

          if (isLoading)
            Center(
              child: CircularProgressIndicator(
                color: MedicalColors.primary,
                strokeWidth: 2,
              ),
            )
          else if (products.isEmpty)
            _buildEmptyState(
              'لا توجد منتجات متاحة',
              Icons.medical_services_outlined,
            )
          else
            Container(
              height: isDesktop ? 420 : 340,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    width: isDesktop ? 280 : 200,
                    margin: EdgeInsets.only(left: isDesktop ? 20 : 12),
                    child: _buildMedicalProductCard(product, isDesktop, accentColor),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  // MEDICAL PRODUCT CARD
  Widget _buildMedicalProductCard(EnhancedItem product, bool isDesktop, Color accentColor) {
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
            color: MedicalColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: Offset(0, 4),
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
                        color: MedicalColors.background,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
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
                                size: 48,
                                color: MedicalColors.textLight,
                              ),
                            );
                          },
                        )
                            : Center(
                          child: Icon(
                            Icons.medical_services_outlined,
                            size: 48,
                            color: MedicalColors.textLight,
                          ),
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
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: MedicalColors.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '-${product.discount!.toInt()}%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (product.isNewArrival && !hasDiscount)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: MedicalColors.secondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'جديد',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Stock indicator
                    if (!product.inStock)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: MedicalColors.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'نفد المخزون',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                  padding: EdgeInsets.all(isDesktop ? 16 : 12),
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
                                fontSize: 11,
                                color: accentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          SizedBox(height: 4),
                          Text(
                            product.nameAr ?? product.name,
                            style: TextStyle(
                              fontSize: isDesktop ? 14 : 13,
                              fontWeight: FontWeight.w600,
                              color: MedicalColors.textPrimary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasDiscount)
                                Text(
                                  product.formattedPrice,
                                  style: TextStyle(
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                    color: MedicalColors.textLight,
                                  ),
                                ),
                              Text(
                                '${hasDiscount ? product.discountedPrice.toStringAsFixed(0) : product.salePrice1.toStringAsFixed(0)} ${product.currencySymbol}',
                                style: TextStyle(
                                  fontSize: isDesktop ? 16 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: MedicalColors.primary,
                                ),
                              ),
                            ],
                          ),
                          if (product.inStock)
                            GestureDetector(
                              onTap: () => _showQuantityDialog(product),
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.add_shopping_cart_rounded,
                                  size: 18,
                                  color: Colors.white,
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

  Widget _buildMedicalSectionHeader({
    required String title,
    required String subtitle,
    Color accentColor = MedicalColors.primary,
    VoidCallback? onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: MedicalColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: MedicalColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              backgroundColor: accentColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 13,
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: accentColor,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon, {bool isDark = false}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: MedicalColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: MedicalColors.primary,
              ),
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: MedicalColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          child: Container(
            padding: EdgeInsets.all(24),
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: MedicalColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: product.thumbnail != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(product.thumbnail!, fit: BoxFit.cover),
                        )
                      : Icon(Icons.medical_services_outlined, size: 40, color: MedicalColors.textLight),
                ),
                SizedBox(height: 16),
                Text(
                  'إضافة إلى السلة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MedicalColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  product.nameAr ?? product.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: MedicalColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 24),
                // Quantity selector
                Container(
                  decoration: BoxDecoration(
                    color: MedicalColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) setState(() => quantity--);
                        },
                        icon: Icon(Icons.remove_rounded),
                        color: quantity > 1 ? MedicalColors.primary : MedicalColors.textLight,
                      ),
                      Container(
                        width: 60,
                        alignment: Alignment.center,
                        child: Text(
                          '$quantity',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: MedicalColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (quantity < product.number) setState(() => quantity++);
                        },
                        icon: Icon(Icons.add_rounded),
                        color: quantity < product.number ? MedicalColors.primary : MedicalColors.textLight,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  '${(product.discountedPrice * quantity).toStringAsFixed(0)} ${product.currencySymbol}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MedicalColors.primary,
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: MedicalColors.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            color: MedicalColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          cartProvider.addToCart(product, quantity: quantity);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('تمت الإضافة إلى السلة'),
                                ],
                              ),
                              backgroundColor: MedicalColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              action: SnackBarAction(
                                label: 'عرض السلة',
                                textColor: Colors.white,
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
                          backgroundColor: MedicalColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'إضافة',
                          style: TextStyle(fontWeight: FontWeight.w600),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: MedicalColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 40,
                  color: MedicalColors.primary,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'تسجيل الدخول مطلوب',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: MedicalColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'يجب تسجيل الدخول لإضافة المنتجات إلى السلة',
                style: TextStyle(
                  fontSize: 14,
                  color: MedicalColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/sign-in');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MedicalColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'تسجيل الدخول',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MEDICAL NAVIGATION BAR
  Widget _buildMedicalNavBar(bool isDesktop, bool isMobile, CartProvider cartProvider) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: isDesktop ? 80 : 70,
        decoration: BoxDecoration(
          color: _isScrolled
              ? Colors.white
              : Colors.transparent,
          boxShadow: _isScrolled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 80 : 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Menu button for mobile
              if (isMobile)
                Builder(
                  builder: (context) => Container(
                    decoration: BoxDecoration(
                      color: _isScrolled ? MedicalColors.background : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.menu_rounded,
                        color: _isScrolled ? MedicalColors.primary : Colors.white,
                      ),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
                  ),
                ),
              // Logo
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isScrolled ? MedicalColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.local_hospital_rounded,
                      color: _isScrolled ? Colors.white : MedicalColors.primary,
                      size: isDesktop ? 24 : 20,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'أرض الطب',
                    style: TextStyle(
                      fontSize: isDesktop ? 22 : 18,
                      fontWeight: FontWeight.bold,
                      color: _isScrolled ? MedicalColors.textPrimary : Colors.white,
                    ),
                  ),
                ],
              ),
              // Actions
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _isScrolled ? MedicalColors.background : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.search_rounded,
                        color: _isScrolled ? MedicalColors.textPrimary : Colors.white,
                        size: 22,
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/search'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _isScrolled ? MedicalColors.background : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.person_outline_rounded,
                        color: _isScrolled ? MedicalColors.textPrimary : Colors.white,
                        size: 22,
                      ),
                      onPressed: () => Navigator.pushNamed(context, '/account'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: _isScrolled ? MedicalColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.shopping_cart_outlined,
                            color: _isScrolled ? Colors.white : MedicalColors.primary,
                            size: 22,
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/cart'),
                        ),
                      ),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: MedicalColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${cartProvider.itemCount}',
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WHY CHOOSE US SECTION
  Widget _buildWhyChooseUsSection(bool isDesktop, bool isMobile) {
    final features = [
      {
        'icon': Icons.verified_user_outlined,
        'title': 'منتجات معتمدة',
        'subtitle': 'جميع منتجاتنا حاصلة على شهادات الجودة العالمية',
        'color': MedicalColors.primary,
      },
      {
        'icon': Icons.local_shipping_outlined,
        'title': 'توصيل سريع',
        'subtitle': 'نوصل طلبك بأسرع وقت ممكن لجميع المحافظات',
        'color': MedicalColors.secondary,
      },
      {
        'icon': Icons.support_agent_outlined,
        'title': 'دعم متخصص',
        'subtitle': 'فريق دعم فني متخصص متاح على مدار الساعة',
        'color': MedicalColors.accent,
      },
      {
        'icon': Icons.price_check_outlined,
        'title': 'أسعار تنافسية',
        'subtitle': 'أفضل الأسعار مع ضمان الجودة العالية',
        'color': MedicalColors.warning,
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 80 : 50,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MedicalColors.primary.withOpacity(0.03),
            MedicalColors.background,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            'لماذا تختارنا؟',
            style: TextStyle(
              fontSize: isDesktop ? 28 : 22,
              fontWeight: FontWeight.bold,
              color: MedicalColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'نقدم لك أفضل تجربة تسوق للمستلزمات الطبية',
            style: TextStyle(
              fontSize: 14,
              color: MedicalColors.textSecondary,
            ),
          ),
          SizedBox(height: isDesktop ? 50 : 30),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 2,
              childAspectRatio: isDesktop ? 1.0 : 0.85,
              crossAxisSpacing: isDesktop ? 24 : 12,
              mainAxisSpacing: isDesktop ? 24 : 12,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return Container(
                padding: EdgeInsets.all(isDesktop ? 24 : 16),
                decoration: BoxDecoration(
                  color: MedicalColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: isDesktop ? 64 : 52,
                      height: isDesktop ? 64 : 52,
                      decoration: BoxDecoration(
                        color: (feature['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        feature['icon'] as IconData,
                        size: isDesktop ? 30 : 26,
                        color: feature['color'] as Color,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      feature['title'] as String,
                      style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        fontWeight: FontWeight.bold,
                        color: MedicalColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      feature['subtitle'] as String,
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 11,
                        color: MedicalColors.textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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

  // MEDICAL FOOTER
  Widget _buildMedicalFooter(bool isDesktop, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: isDesktop ? 60 : 40,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MedicalColors.primaryDark,
            MedicalColors.primary,
          ],
        ),
      ),
      child: Column(
        children: [
          // Logo and tagline
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_hospital_rounded,
                  color: MedicalColors.primary,
                  size: 28,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'أرض الطب',
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'شريكك الموثوق في المستلزمات الطبية',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          SizedBox(height: 30),

          // Contact Info
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Wrap(
              spacing: 30,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.email_outlined, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'info@arthultib.com',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone_outlined, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '+964 780 017 5770',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 30),

          // Divider
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          SizedBox(height: 20),

          // Copyright
          Text(
            '© ${DateTime.now().year} أرض الطب - جميع الحقوق محفوظة',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  // MEDICAL DRAWER
  Widget _buildMedicalDrawer() {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [MedicalColors.primary, MedicalColors.primaryDark],
                  ),
                ),
                width: double.infinity,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_hospital_rounded,
                        color: MedicalColors.primary,
                        size: 32,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'أرض الطب',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'مستلزمات طبية موثوقة',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildMedicalDrawerItem(Icons.home_rounded, 'الرئيسية', () {
                      Navigator.pop(context);
                    }),
                    _buildMedicalDrawerItem(Icons.category_rounded, 'الأقسام', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AllCategoriesPage()),
                      );
                    }),
                    _buildMedicalDrawerItem(Icons.shopping_cart_rounded, 'السلة', () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CartPage()),
                      );
                    }),
                    _buildMedicalDrawerItem(Icons.person_rounded, 'حسابي', () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/account');
                    }),
                    _buildMedicalDrawerItem(Icons.favorite_rounded, 'المفضلة', () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/saved-items');
                    }),
                    Divider(height: 32),
                    _buildMedicalDrawerItem(Icons.headset_mic_rounded, 'تواصل معنا', () {
                      Navigator.pop(context);
                      // Navigate to contact
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

  Widget _buildMedicalDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: MedicalColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: MedicalColors.primary, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: MedicalColors.textPrimary,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      trailing: Icon(
        Icons.chevron_left_rounded,
        color: MedicalColors.textLight,
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

// Medical Pattern Painter for background
class MedicalPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw plus signs pattern
    const spacing = 60.0;
    const plusSize = 12.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Horizontal line of plus
        canvas.drawLine(
          Offset(x - plusSize / 2, y),
          Offset(x + plusSize / 2, y),
          paint,
        );
        // Vertical line of plus
        canvas.drawLine(
          Offset(x, y - plusSize / 2),
          Offset(x, y + plusSize / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Placeholder Pages
class AllCategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جميع الأقسام'),
        backgroundColor: MedicalColors.primary,
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
        backgroundColor: MedicalColors.primary,
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
      appBar: AppBar(
        title: Text(item.nameAr ?? item.name),
        backgroundColor: MedicalColors.primary,
        foregroundColor: Colors.white,
      ),
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
