import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../translations.dart';
import '../language_provider.dart';
import 'package:provider/provider.dart';

class ContactSection extends StatelessWidget {
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
          constraints: BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              // Section Header - Modern Minimalist
              Column(
                children: [
                  Text(
                    Translations.getText(context, 'contactSectionTitle'),
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
                    constraints: BoxConstraints(maxWidth: 400),
                    child: Text(
                      Translations.getText(context, 'contactSectionSubtitle'),
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 17,
                        color: Color(0xFF6B7280),
                        letterSpacing: 0.2,
                        height: 1.5,
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

              // Contact Information Cards
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('website_content').doc('main').get(),
                builder: (context, snapshot) {
                  var languageProvider = Provider.of<LanguageProvider>(context);

                  // Default values
                  String companyName = languageProvider.languageCode == 'ar'
                      ? 'شركة أرض الطب'
                      : 'Arthultib Company';
                  String mobileNumbers = '+964 xxx xxxx xxx';
                  String email = 'info@arthultib.com';

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    companyName = languageProvider.languageCode == 'ar'
                        ? data['company_name_ar'] ?? companyName
                        : data['company_name_en'] ?? companyName;
                    mobileNumbers = languageProvider.languageCode == 'ar'
                        ? data['mobile_numbers_ar'] ?? mobileNumbers
                        : data['mobile_numbers_en'] ?? mobileNumbers;
                    email = languageProvider.languageCode == 'ar'
                        ? data['email_ar'] ?? email
                        : data['email_en'] ?? email;
                  }

                  if (isMobile) {
                    return Column(
                      children: [
                        _buildContactCard(
                          icon: Icons.location_on_outlined,
                          title: Translations.getText(context, 'companyAddress'),
                          content: companyName,
                          isMobile: isMobile,
                        ),
                        SizedBox(height: 20),
                        _buildContactCard(
                          icon: Icons.phone_outlined,
                          title: Translations.getText(context, 'callUs'),
                          content: mobileNumbers,
                          isMobile: isMobile,
                        ),
                        SizedBox(height: 20),
                        _buildContactCard(
                          icon: Icons.email_outlined,
                          title: Translations.getText(context, 'emailUs'),
                          content: email,
                          isMobile: isMobile,
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildContactCard(
                            icon: Icons.location_on_outlined,
                            title: Translations.getText(context, 'companyAddress'),
                            content: companyName,
                            isMobile: isMobile,
                          ),
                        ),
                        SizedBox(width: 28),
                        Expanded(
                          child: _buildContactCard(
                            icon: Icons.phone_outlined,
                            title: Translations.getText(context, 'callUs'),
                            content: mobileNumbers,
                            isMobile: isMobile,
                          ),
                        ),
                        SizedBox(width: 28),
                        Expanded(
                          child: _buildContactCard(
                            icon: Icons.email_outlined,
                            title: Translations.getText(context, 'emailUs'),
                            content: email,
                            isMobile: isMobile,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),

              SizedBox(height: isMobile ? 64 : 80),

              // Call to Action - Modern Style
              Container(
                padding: EdgeInsets.all(isMobile ? 36 : 56),
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
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Color(0xFF0066CC).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.headset_mic_outlined,
                        size: 40,
                        color: Color(0xFF0066CC),
                      ),
                    ),
                    SizedBox(height: 28),
                    Text(
                      languageProvider.languageCode == 'ar'
                          ? 'نحن هنا لمساعدتك'
                          : 'We\'re Here to Help',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      languageProvider.languageCode == 'ar'
                          ? 'فريقنا متاح للإجابة على جميع استفساراتك'
                          : 'Our team is available to answer all your inquiries',
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 17,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Handle contact action
                      },
                      icon: Icon(Icons.chat_outlined, size: 20),
                      label: Text(
                        languageProvider.languageCode == 'ar'
                            ? 'تواصل معنا'
                            : 'Get in Touch',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0066CC),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
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

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 28 : 36),
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
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color(0xFF0066CC).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 28,
              color: Color(0xFF0066CC),
            ),
          ),
          SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.5,
              textBaseline: TextBaseline.alphabetic,
            ),
          ),
          SizedBox(height: 10),
          SelectableText(
            content,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
