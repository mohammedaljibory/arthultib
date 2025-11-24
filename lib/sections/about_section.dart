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
                    Translations.getText(context, 'aboutSectionTitle'),
                    style: TextStyle(
                      fontSize: isMobile ? 28 : isTablet ? 36 : 42,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF004080),
                      letterSpacing: 1.5,
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

              SizedBox(height: isMobile ? 40 : 60),

              // About Content
              Text(
                Translations.getText(context, 'aboutSectionDescription'),
                style: TextStyle(
                  fontSize: isMobile ? 15 : 17,
                  color: Colors.grey[700],
                  height: 1.8,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isMobile ? 60 : 80),

              // Vision & Mission Cards
              isMobile
                  ? Column(
                children: [
                  _buildInfoCard(
                    title: Translations.getText(context, 'aboutVisionTitle'),
                    description: Translations.getText(context, 'aboutVisionDescription'),
                    icon: Icons.visibility_outlined,
                    color: Color(0xFF004080),
                    isMobile: isMobile,
                  ),
                  SizedBox(height: 30),
                  _buildInfoCard(
                    title: Translations.getText(context, 'aboutMissionTitle'),
                    description: Translations.getText(context, 'aboutMissionDescription'),
                    icon: Icons.flag_outlined,
                    color: Color(0xFF0288D1),
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
                      color: Color(0xFF004080),
                      isMobile: isMobile,
                    ),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: _buildInfoCard(
                      title: Translations.getText(context, 'aboutMissionTitle'),
                      description: Translations.getText(context, 'aboutMissionDescription'),
                      icon: Icons.flag_outlined,
                      color: Color(0xFF0288D1),
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 60 : 80),

              // Company Logo
              Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: isMobile ? 80 : 120,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.medical_services,
                      size: isMobile ? 80 : 120,
                      color: Color(0xFF004080),
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
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 30 : 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          SizedBox(height: 25),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.w500,
              color: color,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          Text(
            description,
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: Colors.grey[600],
              height: 1.7,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}