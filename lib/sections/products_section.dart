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
        vertical: isMobile ? 60 : 100,
        horizontal: isMobile ? 20 : 40,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Section Header
              Column(
                children: [
                  Text(
                    Translations.getText(context, 'productsSectionTitle'),
                    style: TextStyle(
                      fontSize: isMobile ? 28 : isTablet ? 36 : 42,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF004080),
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text(
                    Translations.getText(context, 'productsSectionDescription'),
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 17,
                      color: Colors.grey[600],
                      letterSpacing: 0.3,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 80,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFF0288D1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 50 : 80),

              // Product Categories
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
                    color: Color(0xFF004080),
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
                    color: Color(0xFF0288D1),
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
                    color: Color(0xFF00695C),
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
                      color: Color(0xFF004080),
                      isMobile: isMobile,
                    ),
                  ),
                  SizedBox(width: 30),
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
                      color: Color(0xFF0288D1),
                      isMobile: isMobile,
                    ),
                  ),
                  SizedBox(width: 30),
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
                      color: Color(0xFF00695C),
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 60 : 80),

              // Statistics/Features Row
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 30 : 40,
                  horizontal: isMobile ? 20 : 40,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFF004080).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
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
                    SizedBox(height: 30),
                    _buildStatItem(
                      number: '100+',
                      label: languageProvider.languageCode == 'ar'
                          ? 'علامة تجارية'
                          : 'Trusted Brands',
                      icon: Icons.verified_outlined,
                    ),
                    SizedBox(height: 30),
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
                      color: Colors.grey[300],
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
                      color: Colors.grey[300],
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

              SizedBox(height: isMobile ? 60 : 80),

              // CTA Button
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/store'),
                icon: Icon(Icons.store_outlined, size: 20),
                label: Text(
                  Translations.getText(context, 'storeVisitButton'),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF004080),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 30 : 40,
                    vertical: isMobile ? 15 : 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
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
    required Color color,
    required bool isMobile,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => Navigator.pushNamed(context, '/store'),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 25 : 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: color.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
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
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: color,
                ),
              ),
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w500,
                  color: color,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                description,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Provider.of<LanguageProvider>(context).languageCode == 'ar'
                          ? 'استكشف'
                          : 'Explore',
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward,
                      color: color,
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
        Icon(
          icon,
          size: 32,
          color: Color(0xFF0288D1),
        ),
        SizedBox(height: 10),
        Text(
          number,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004080),
          ),
        ),
        SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}