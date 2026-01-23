import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
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
                  String whatsappNumber = '+9647800175770';
                  String address = languageProvider.languageCode == 'ar'
                      ? 'العراق - بغداد'
                      : 'Iraq - Baghdad';

                  if (snapshot.hasData && snapshot.data!.exists) {
                    var data = snapshot.data!.data() as Map<String, dynamic>;
                    companyName = languageProvider.languageCode == 'ar'
                        ? data['company_name_ar'] ?? companyName
                        : data['company_name_en'] ?? companyName;
                    mobileNumbers = languageProvider.languageCode == 'ar'
                        ? data['mobile_numbers_ar'] ?? data['mobile_numbers'] ?? mobileNumbers
                        : data['mobile_numbers_en'] ?? data['mobile_numbers'] ?? mobileNumbers;
                    email = languageProvider.languageCode == 'ar'
                        ? data['email_ar'] ?? data['email'] ?? email
                        : data['email_en'] ?? data['email'] ?? email;
                    whatsappNumber = data['whatsapp_number'] ?? whatsappNumber;
                    address = languageProvider.languageCode == 'ar'
                        ? data['address_ar'] ?? address
                        : data['address_en'] ?? address;
                  }

                  if (isMobile) {
                    return Column(
                      children: [
                        _buildContactCard(
                          icon: Icons.location_on_outlined,
                          title: Translations.getText(context, 'companyAddress'),
                          content: address,
                          isMobile: isMobile,
                          onTap: () => _openMaps(address),
                        ),
                        SizedBox(height: 20),
                        _buildContactCard(
                          icon: Icons.phone_outlined,
                          title: Translations.getText(context, 'callUs'),
                          content: mobileNumbers,
                          isMobile: isMobile,
                          onTap: () => _makePhoneCall(mobileNumbers),
                        ),
                        SizedBox(height: 20),
                        _buildContactCard(
                          icon: Icons.email_outlined,
                          title: Translations.getText(context, 'emailUs'),
                          content: email,
                          isMobile: isMobile,
                          onTap: () => _sendEmail(email),
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
                            content: address,
                            isMobile: isMobile,
                            onTap: () => _openMaps(address),
                          ),
                        ),
                        SizedBox(width: 28),
                        Expanded(
                          child: _buildContactCard(
                            icon: Icons.phone_outlined,
                            title: Translations.getText(context, 'callUs'),
                            content: mobileNumbers,
                            isMobile: isMobile,
                            onTap: () => _makePhoneCall(mobileNumbers),
                          ),
                        ),
                        SizedBox(width: 28),
                        Expanded(
                          child: _buildContactCard(
                            icon: Icons.email_outlined,
                            title: Translations.getText(context, 'emailUs'),
                            content: email,
                            isMobile: isMobile,
                            onTap: () => _sendEmail(email),
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
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('website_content').doc('main').get(),
                      builder: (context, snapshot) {
                        String whatsappNumber = '+9647800175770';
                        if (snapshot.hasData && snapshot.data!.exists) {
                          var data = snapshot.data!.data() as Map<String, dynamic>;
                          whatsappNumber = data['whatsapp_number'] ?? whatsappNumber;
                        }

                        return ElevatedButton.icon(
                          onPressed: () => _openWhatsApp(whatsappNumber, languageProvider.languageCode == 'ar'
                              ? 'مرحباً، أود الاستفسار عن منتجاتكم'
                              : 'Hello, I would like to inquire about your products'),
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
                        );
                      },
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
    VoidCallback? onTap,
  }) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
        ),
      ),
    );
  }

  // Helper methods for contact actions
  static Future<void> _openWhatsApp(String phoneNumber, String message) async {
    // Clean the phone number - remove spaces and special characters
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/$cleanNumber?text=$encodedMessage';

    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to regular WhatsApp URL
        final fallbackUri = Uri.parse('whatsapp://send?phone=$cleanNumber&text=$encodedMessage');
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Could not open WhatsApp: $e');
    }
  }

  static Future<void> _makePhoneCall(String phoneNumber) async {
    // Extract the first phone number if there are multiple
    final firstNumber = phoneNumber.split(RegExp(r'[,/]')).first.trim();
    final cleanNumber = firstNumber.replaceAll(RegExp(r'[^\d+]'), '');

    try {
      final uri = Uri.parse('tel:$cleanNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Could not make phone call: $e');
    }
  }

  static Future<void> _sendEmail(String email) async {
    try {
      final uri = Uri.parse('mailto:$email');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      print('Could not open email: $e');
    }
  }

  static Future<void> _openMaps(String address) async {
    final encodedAddress = Uri.encodeComponent(address);

    try {
      // Try Google Maps first
      final googleMapsUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Could not open maps: $e');
    }
  }
}
