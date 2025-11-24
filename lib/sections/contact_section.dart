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
                    Translations.getText(context, 'contactSectionTitle'),
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
                    Translations.getText(context, 'contactSectionSubtitle'),
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 17,
                      color: Colors.grey[600],
                      letterSpacing: 0.3,
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

              // Contact Information
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
                          color: Color(0xFF004080),
                          isMobile: isMobile,
                        ),
                        SizedBox(height: 25),
                        _buildContactCard(
                          icon: Icons.phone_outlined,
                          title: Translations.getText(context, 'callUs'),
                          content: mobileNumbers,
                          color: Color(0xFF0288D1),
                          isMobile: isMobile,
                        ),
                        SizedBox(height: 25),
                        _buildContactCard(
                          icon: Icons.email_outlined,
                          title: Translations.getText(context, 'emailUs'),
                          content: email,
                          color: Color(0xFF00695C),
                          isMobile: isMobile,
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildContactCard(
                            icon: Icons.location_on_outlined,
                            title: Translations.getText(context, 'companyAddress'),
                            content: companyName,
                            color: Color(0xFF004080),
                            isMobile: isMobile,
                          ),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                          child: _buildContactCard(
                            icon: Icons.phone_outlined,
                            title: Translations.getText(context, 'callUs'),
                            content: mobileNumbers,
                            color: Color(0xFF0288D1),
                            isMobile: isMobile,
                          ),
                        ),
                        SizedBox(width: 30),
                        Expanded(
                          child: _buildContactCard(
                            icon: Icons.email_outlined,
                            title: Translations.getText(context, 'emailUs'),
                            content: email,
                            color: Color(0xFF00695C),
                            isMobile: isMobile,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),

              SizedBox(height: isMobile ? 60 : 80),

              // Call to Action
              Container(
                padding: EdgeInsets.all(isMobile ? 30 : 50),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF004080).withOpacity(0.05),
                      Color(0xFF0288D1).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.headset_mic_outlined,
                      size: 48,
                      color: Color(0xFF004080),
                    ),
                    SizedBox(height: 20),
                    Text(
                      languageProvider.languageCode == 'ar'
                          ? 'نحن هنا لمساعدتك'
                          : 'We\'re Here to Help',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 24,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF004080),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      languageProvider.languageCode == 'ar'
                          ? 'فريقنا متاح للإجابة على جميع استفساراتك'
                          : 'Our team is available to answer all your inquiries',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
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
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 25 : 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 5,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 10),
          SelectableText(
            content,
            style: TextStyle(
              fontSize: isMobile ? 15 : 17,
              fontWeight: FontWeight.w400,
              color: Color(0xFF004080),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}