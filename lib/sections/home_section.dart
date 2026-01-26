import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
import '../translations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../language_provider.dart';

class HomeSection extends StatefulWidget {
  @override
  _HomeSectionState createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> with WidgetsBindingObserver {
  PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  bool _isVisible = true;

  // Banners will be loaded from Firestore
  List<Map<String, dynamic>> _banners = [];
  bool _isLoadingBanners = true;

  // Fallback banners if Firestore is empty
  final List<Map<String, dynamic>> _fallbackBanners = [
    {
      'title_ar': 'أحدث الأجهزة الطبية',
      'title_en': 'Latest Medical Equipment',
      'subtitle_ar': 'تقنيات متطورة لرعاية صحية أفضل',
      'subtitle_en': 'Advanced technology for better healthcare',
      'image': 'assets/images/homeBG.png',
      'color': Color(0xFF0066CC),
      'isLocal': true,
    },
    {
      'title_ar': 'شركاء النجاح',
      'title_en': 'Success Partners',
      'subtitle_ar': 'نتعاون مع أفضل الشركات العالمية',
      'subtitle_en': 'Collaborating with the world\'s best companies',
      'image': 'assets/images/products.png',
      'color': Color(0xFF3B82F6),
      'isLocal': true,
    },
    {
      'title_ar': 'جودة معتمدة',
      'title_en': 'Certified Quality',
      'subtitle_ar': 'منتجات حاصلة على شهادات الجودة العالمية',
      'subtitle_en': 'Products with international quality certifications',
      'image': 'assets/images/homeBG.png',
      'color': Color(0xFF0066CC),
      'isLocal': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBannersFromFirestore();
    _startAutoSlide();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause timer when app is backgrounded/paused to save resources
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _stopAutoSlide();
    } else if (state == AppLifecycleState.resumed && _isVisible) {
      _startAutoSlide();
    }
  }

  Future<void> _loadBannersFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('banners')
          .where('isActive', isEqualTo: true)
          .orderBy('order')
          .get();

      if (snapshot.docs.isNotEmpty) {
        final now = DateTime.now();
        setState(() {
          _banners = snapshot.docs
              .map((doc) {
                final data = doc.data();
                return {
                  'id': doc.id,
                  'title_ar': data['titleAr'] ?? '',
                  'title_en': data['titleEn'] ?? data['titleAr'] ?? '',
                  'subtitle_ar': data['subtitleAr'] ?? '',
                  'subtitle_en': data['subtitleEn'] ?? data['subtitleAr'] ?? '',
                  'imageUrl': data['imageUrl'],
                  'actionType': data['actionType'] ?? 'none',
                  'actionValue': data['actionValue'],
                  'startDate': data['startDate']?.toDate(),
                  'endDate': data['endDate']?.toDate(),
                  'color': Color(0xFF0066CC),
                  'isLocal': false,
                };
              })
              .where((banner) {
                // Filter by date range
                final startDate = banner['startDate'] as DateTime?;
                final endDate = banner['endDate'] as DateTime?;
                if (startDate != null && now.isBefore(startDate)) return false;
                if (endDate != null && now.isAfter(endDate)) return false;
                return true;
              })
              .toList();
          _isLoadingBanners = false;
        });

        // If no valid banners after filtering, use fallback
        if (_banners.isEmpty) {
          setState(() {
            _banners = _fallbackBanners;
          });
        }
      } else {
        // No banners in Firestore, use fallback
        setState(() {
          _banners = _fallbackBanners;
          _isLoadingBanners = false;
        });
      }
    } catch (e) {
      print('Error loading home banners: $e');
      // On error, use fallback banners
      setState(() {
        _banners = _fallbackBanners;
        _isLoadingBanners = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopAutoSlide();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    // Don't create multiple timers
    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && _banners.isNotEmpty && _isVisible) {
        int nextPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _stopAutoSlide() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 900;
    var languageProvider = Provider.of<LanguageProvider>(context);

    return Container(
      width: screenWidth,
      child: Column(
        children: [
          // Hero Banner Carousel - Modern Minimalist Style
          Container(
            height: isMobile ? screenHeight * 0.65 : screenHeight * 0.8,
            child: Stack(
              children: [
                // Loading state
                if (_isLoadingBanners)
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF0066CC).withOpacity(0.75),
                          Color(0xFF0066CC).withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                // Banner PageView
                else
                  PageView.builder(
                  controller: _pageController,
                  itemCount: _banners.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final banner = _banners[index];
                    return _buildBannerItem(
                      banner: banner,
                      isMobile: isMobile,
                      isTablet: isTablet,
                      languageProvider: languageProvider,
                    );
                  },
                ),

                // Modern Page Indicators
                Positioned(
                  bottom: isMobile ? 40 : 60,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _banners.length,
                          (index) => AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: _currentPage == index ? 32 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                // Navigation Arrows (Desktop Only) - Glassmorphism style
                if (!isMobile) ...[
                  Positioned(
                    left: 40,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if (_currentPage > 0) {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOutCubic,
                              );
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            if (_currentPage < _banners.length - 1) {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.easeInOutCubic,
                              );
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Welcome Section - More Whitespace, Cleaner Typography
          Container(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 80 : 120,
              horizontal: isMobile ? 24 : 48,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Text(
                      Translations.getText(context, 'homeSectionTitle'),
                      style: TextStyle(
                        fontSize: isMobile ? 28 : isTablet ? 36 : 48,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Container(
                      width: 48,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Color(0xFF0066CC),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(height: 32),
                    Text(
                      Translations.getText(context, 'homeSectionDescription'),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: Color(0xFF6B7280),
                        height: 1.8,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      Translations.getText(context, 'homeSectionDetails'),
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Color(0xFF9CA3AF),
                        height: 1.8,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48),

                    // Modern CTA Buttons
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/store'),
                          icon: Icon(Icons.shopping_cart_outlined, size: 20),
                          label: Text(
                            languageProvider.languageCode == 'ar'
                                ? 'تسوق الآن'
                                : 'Shop Now',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0066CC),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 0,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            // Scroll to contact section
                          },
                          icon: Icon(Icons.phone_outlined, size: 20),
                          label: Text(
                            languageProvider.languageCode == 'ar'
                                ? 'اتصل بنا'
                                : 'Contact Us',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xFF1A1A1A),
                            side: BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
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

          // Features Section - Glassmorphism Cards
          Container(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 60 : 80,
              horizontal: isMobile ? 20 : 48,
            ),
            color: Color(0xFFFAFBFC),
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 1200),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.verified_outlined,
                      title: languageProvider.languageCode == 'ar'
                          ? 'جودة مضمونة'
                          : 'Guaranteed Quality',
                      subtitle: languageProvider.languageCode == 'ar'
                          ? 'منتجات معتمدة دولياً'
                          : 'Internationally certified products',
                      isMobile: isMobile,
                    ),
                    _buildFeatureCard(
                      icon: Icons.local_shipping_outlined,
                      title: languageProvider.languageCode == 'ar'
                          ? 'توصيل سريع'
                          : 'Fast Delivery',
                      subtitle: languageProvider.languageCode == 'ar'
                          ? 'خدمة توصيل موثوقة'
                          : 'Reliable delivery service',
                      isMobile: isMobile,
                    ),
                    _buildFeatureCard(
                      icon: Icons.support_agent_outlined,
                      title: languageProvider.languageCode == 'ar'
                          ? 'دعم متواصل'
                          : '24/7 Support',
                      subtitle: languageProvider.languageCode == 'ar'
                          ? 'فريق دعم متخصص'
                          : 'Specialized support team',
                      isMobile: isMobile,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem({
    required Map<String, dynamic> banner,
    required bool isMobile,
    required bool isTablet,
    required LanguageProvider languageProvider,
  }) {
    final bool isLocal = banner['isLocal'] == true;
    final Color bannerColor = banner['color'] as Color? ?? Color(0xFF0066CC);

    return Container(
      decoration: BoxDecoration(
        color: bannerColor,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          if (isLocal)
            Image.asset(
              banner['image'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: bannerColor);
              },
            )
          else
            Image.network(
              banner['imageUrl'] ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: bannerColor);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: bannerColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.white.withOpacity(0.5),
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  bannerColor.withOpacity(0.75),
                  bannerColor.withOpacity(0.9),
                ],
              ),
            ),
          ),
          // Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    languageProvider.languageCode == 'ar'
                        ? (banner['title_ar'] ?? '')
                        : (banner['title_en'] ?? ''),
                    style: TextStyle(
                      fontSize: isMobile ? 36 : isTablet ? 48 : 64,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Text(
                    languageProvider.languageCode == 'ar'
                        ? (banner['subtitle_ar'] ?? '')
                        : (banner['subtitle_en'] ?? ''),
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 0.3,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  // CTA Button on Banner
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/store'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: bannerColor,
                      padding: EdgeInsets.symmetric(horizontal: 36, vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      languageProvider.languageCode == 'ar'
                          ? 'استكشف المنتجات'
                          : 'Explore Products',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isMobile,
  }) {
    return Container(
      width: isMobile ? double.infinity : 340,
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF0066CC).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 32,
              color: Color(0xFF0066CC),
            ),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
