import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../translations.dart';
import '../language_provider.dart';

class ProductsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 900;
    var languageProvider = Provider.of<LanguageProvider>(context);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 80 : 120,
        horizontal: isMobile ? 24 : 48,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Section Header - Modern Minimalist
              Column(
                children: [
                  Text(
                    Translations.getText(context, 'productsSectionTitle'),
                    style: TextStyle(
                      fontSize: isMobile ? 32 : isTablet ? 40 : 48,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Container(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Text(
                      Translations.getText(context, 'productsSectionDescription'),
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 17,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.2,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 48,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Color(0xFF0066CC),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 56 : 80),

              // Product Categories - Modern Cards
              isMobile
                  ? Column(
                children: [
                  _buildProductCard(
                    context: context,
                    icon: Icons.medical_services_outlined,
                    title: languageProvider.languageCode == 'ar'
                        ? 'أجهزة طبية'
                        : 'Medical Devices',
                    description: languageProvider.languageCode == 'ar'
                        ? 'أحدث الأجهزة الطبية المتطورة'
                        : 'Latest advanced medical devices',
                    isMobile: isMobile,
                  ),
                  SizedBox(height: 20),
                  _buildProductCard(
                    context: context,
                    icon: Icons.healing_outlined,
                    title: languageProvider.languageCode == 'ar'
                        ? 'مستلزمات طبية'
                        : 'Medical Supplies',
                    description: languageProvider.languageCode == 'ar'
                        ? 'جميع المستلزمات الطبية الضرورية'
                        : 'All essential medical supplies',
                    isMobile: isMobile,
                  ),
                  SizedBox(height: 20),
                  _buildProductCard(
                    context: context,
                    icon: Icons.biotech_outlined,
                    title: languageProvider.languageCode == 'ar'
                        ? 'معدات المختبرات'
                        : 'Lab Equipment',
                    description: languageProvider.languageCode == 'ar'
                        ? 'معدات مختبرية عالية الدقة'
                        : 'High precision laboratory equipment',
                    isMobile: isMobile,
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildProductCard(
                      context: context,
                      icon: Icons.medical_services_outlined,
                      title: languageProvider.languageCode == 'ar'
                          ? 'أجهزة طبية'
                          : 'Medical Devices',
                      description: languageProvider.languageCode == 'ar'
                          ? 'أحدث الأجهزة الطبية المتطورة'
                          : 'Latest advanced medical devices',
                      isMobile: isMobile,
                    ),
                  ),
                  SizedBox(width: 28),
                  Expanded(
                    child: _buildProductCard(
                      context: context,
                      icon: Icons.healing_outlined,
                      title: languageProvider.languageCode == 'ar'
                          ? 'مستلزمات طبية'
                          : 'Medical Supplies',
                      description: languageProvider.languageCode == 'ar'
                          ? 'جميع المستلزمات الطبية الضرورية'
                          : 'All essential medical supplies',
                      isMobile: isMobile,
                    ),
                  ),
                  SizedBox(width: 28),
                  Expanded(
                    child: _buildProductCard(
                      context: context,
                      icon: Icons.biotech_outlined,
                      title: languageProvider.languageCode == 'ar'
                          ? 'معدات المختبرات'
                          : 'Lab Equipment',
                      description: languageProvider.languageCode == 'ar'
                          ? 'معدات مختبرية عالية الدقة'
                          : 'High precision laboratory equipment',
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 64 : 80),

              // Statistics Row - Modern Design
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 40 : 48,
                  horizontal: isMobile ? 24 : 48,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFFAFBFC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Color(0xFFF3F4F6),
                    width: 1,
                  ),
                ),
                child: isMobile
                    ? Column(
                  children: [
                    _buildStatItem(
                      number: '500+',
                      label: languageProvider.languageCode == 'ar'
                          ? 'منتج متوفر'
                          : 'Products Available',
                      icon: Icons.inventory_2_outlined,
                    ),
                    SizedBox(height: 32),
                    _buildStatItem(
                      number: '100+',
                      label: languageProvider.languageCode == 'ar'
                          ? 'علامة تجارية'
                          : 'Trusted Brands',
                      icon: Icons.verified_outlined,
                    ),
                    SizedBox(height: 32),
                    _buildStatItem(
                      number: '24/7',
                      label: languageProvider.languageCode == 'ar'
                          ? 'خدمة العملاء'
                          : 'Customer Service',
                      icon: Icons.support_agent_outlined,
                    ),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      number: '500+',
                      label: languageProvider.languageCode == 'ar'
                          ? 'منتج متوفر'
                          : 'Products Available',
                      icon: Icons.inventory_2_outlined,
                    ),
                    Container(
                      height: 60,
                      width: 1,
                      color: Color(0xFFE5E7EB),
                    ),
                    _buildStatItem(
                      number: '100+',
                      label: languageProvider.languageCode == 'ar'
                          ? 'علامة تجارية'
                          : 'Trusted Brands',
                      icon: Icons.verified_outlined,
                    ),
                    Container(
                      height: 60,
                      width: 1,
                      color: Color(0xFFE5E7EB),
                    ),
                    _buildStatItem(
                      number: '24/7',
                      label: languageProvider.languageCode == 'ar'
                          ? 'خدمة العملاء'
                          : 'Customer Service',
                      icon: Icons.support_agent_outlined,
                    ),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 48 : 64),

              // CTA Button - Modern Pill Style
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/store'),
                icon: Icon(Icons.store_outlined, size: 20),
                label: Text(
                  Translations.getText(context, 'storeVisitButton'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0066CC),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 32 : 40,
                    vertical: isMobile ? 16 : 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required bool isMobile,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.pushNamed(context, '/store'),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 28 : 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Color(0xFFF3F4F6),
              width: 1,
            ),
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
                padding: EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Color(0xFF0066CC).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: Color(0xFF0066CC),
                ),
              ),
              SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 20 : 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  color: Color(0xFF6B7280),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Provider.of<LanguageProvider>(context).languageCode == 'ar'
                          ? 'استكشف'
                          : 'Explore',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF1A1A1A),
                      size: 16,
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

  Widget _buildStatItem({
    required String number,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF0066CC).withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            size: 28,
            color: Color(0xFF0066CC),
          ),
        ),
        SizedBox(height: 16),
        Text(
          number,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
