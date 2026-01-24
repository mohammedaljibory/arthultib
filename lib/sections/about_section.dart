import 'package:flutter/material.dart';
import '../translations.dart';

class AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 900;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 80 : 120,
        horizontal: isMobile ? 24 : 48,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Section Header - Modern Minimalist
              Column(
                children: [
                  Text(
                    Translations.getText(context, 'aboutSectionTitle'),
                    style: TextStyle(
                      fontSize: isMobile ? 32 : isTablet ? 40 : 48,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
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

              SizedBox(height: isMobile ? 48 : 64),

              // About Content
              Container(
                constraints: BoxConstraints(maxWidth: 700),
                child: Text(
                  Translations.getText(context, 'aboutSectionDescription'),
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    color: Color(0xFF6B7280),
                    height: 1.9,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: isMobile ? 64 : 80),

              // Vision & Mission Cards - Modern Glassmorphism
              isMobile
                  ? Column(
                children: [
                  _buildInfoCard(
                    title: Translations.getText(context, 'aboutVisionTitle'),
                    description: Translations.getText(context, 'aboutVisionDescription'),
                    icon: Icons.visibility_outlined,
                    isMobile: isMobile,
                  ),
                  SizedBox(height: 24),
                  _buildInfoCard(
                    title: Translations.getText(context, 'aboutMissionTitle'),
                    description: Translations.getText(context, 'aboutMissionDescription'),
                    icon: Icons.flag_outlined,
                    isMobile: isMobile,
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      title: Translations.getText(context, 'aboutVisionTitle'),
                      description: Translations.getText(context, 'aboutVisionDescription'),
                      icon: Icons.visibility_outlined,
                      isMobile: isMobile,
                    ),
                  ),
                  SizedBox(width: 32),
                  Expanded(
                    child: _buildInfoCard(
                      title: Translations.getText(context, 'aboutMissionTitle'),
                      description: Translations.getText(context, 'aboutMissionDescription'),
                      icon: Icons.flag_outlined,
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 64 : 80),

              // Company Logo - Modern Container
              Container(
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
                child: Image.asset(
                  'assets/images/logo.png',
                  height: isMobile ? 80 : 100,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.medical_services,
                      size: isMobile ? 80 : 100,
                      color: Color(0xFF0066CC),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 32 : 40),
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
          SizedBox(height: 28),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 22 : 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: Color(0xFF6B7280),
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
