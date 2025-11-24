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

class _HomeSectionState extends State<HomeSection> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // Sample banner data - can be replaced with Firebase data
  final List<Map<String, dynamic>> _banners = [
    {
      'title_ar': 'أحدث الأجهزة الطبية',
      'title_en': 'Latest Medical Equipment',
      'subtitle_ar': 'تقنيات متطورة لرعاية صحية أفضل',
      'subtitle_en': 'Advanced technology for better healthcare',
      'image': 'assets/images/homeBG.png',
      'color': Color(0xFF004080),
    },
    {
      'title_ar': 'شركاء النجاح',
      'title_en': 'Success Partners',
      'subtitle_ar': 'نتعاون مع أفضل الشركات العالمية',
      'subtitle_en': 'Collaborating with the world\'s best companies',
      'image': 'assets/images/products.png',
      'color': Color(0xFF0288D1),
    },
    {
      'title_ar': 'جودة معتمدة',
      'title_en': 'Certified Quality',
      'subtitle_ar': 'منتجات حاصلة على شهادات الجودة العالمية',
      'subtitle_en': 'Products with international quality certifications',
      'image': 'assets/images/homeBG.png',
      'color': Color(0xFF00695C),
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
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
          // Hero Banner Carousel
          Container(
            height: isMobile ? screenHeight * 0.6 : screenHeight * 0.75,
            child: Stack(
              children: [
                // Banner PageView
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

                // Page Indicators
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _banners.length,
                          (index) => AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 35 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),

                // Navigation Arrows (Desktop Only)
                if (!isMobile) ...[
                  Positioned(
                    left: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          if (_currentPage > 0) {
                            _pageController.previousPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        icon: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.chevron_left,  // or Icons.chevron_right for the second one
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          if (_currentPage < _banners.length - 1) {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOutCubic,
                            );
                          }
                        },
                        icon: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 30,
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

          // Welcome Section
          Container(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 60 : 100,
              horizontal: isMobile ? 20 : 40,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Text(
                  Translations.getText(context, 'homeSectionTitle'),
                  style: TextStyle(
                    fontSize: isMobile ? 24 : isTablet ? 28 : 36,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF004080),
                    letterSpacing: 1.2,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Container(
                  width: 60,
                  height: 2,
                  color: Color(0xFF0288D1),
                ),
                SizedBox(height: 30),
                Text(
                  Translations.getText(context, 'homeSectionDescription'),
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey[700],
                    height: 1.8,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  Translations.getText(context, 'homeSectionDetails'),
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 15,
                    color: Colors.grey[600],
                    height: 1.8,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),

                // CTA Buttons
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/store'),
                      icon: Icon(Icons.shopping_cart_outlined),
                      label: Text(
                        languageProvider.languageCode == 'ar'
                            ? 'تسوق الآن'
                            : 'Shop Now',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF004080),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Scroll to contact section
                      },
                      icon: Icon(Icons.phone_outlined),
                      label: Text(
                        languageProvider.languageCode == 'ar'
                            ? 'اتصل بنا'
                            : 'Contact Us',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF004080),
                        side: BorderSide(color: Color(0xFF004080), width: 2),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Features Section
          Container(
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 40 : 60,
              horizontal: isMobile ? 20 : 40,
            ),
            color: Colors.grey[50],
            child: Wrap(
              spacing: 30,
              runSpacing: 30,
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
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(banner['image']),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              banner['color'].withOpacity(0.7),
              banner['color'].withOpacity(0.9),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  languageProvider.languageCode == 'ar'
                      ? banner['title_ar']
                      : banner['title_en'],
                  style: TextStyle(
                    fontSize: isMobile ? 32 : isTablet ? 40 : 56,
                    fontWeight: FontWeight.w200,
                    color: Colors.white,
                    letterSpacing: 2,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  languageProvider.languageCode == 'ar'
                      ? banner['subtitle_ar']
                      : banner['subtitle_en'],
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.95),
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
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
      width: isMobile ? double.infinity : 300,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Color(0xFF004080).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              icon,
              size: 32,
              color: Color(0xFF004080),
            ),
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF004080),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}