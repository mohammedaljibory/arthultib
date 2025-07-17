import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui' as ui;
import '../translations.dart';
import '../language_provider.dart';
import 'package:provider/provider.dart';

class ContactSection extends StatefulWidget {
  @override
  _ContactSectionState createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _infoAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.0, 0.4, curve: Curves.easeInOut)),
    );
    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.2, 0.6, curve: Curves.easeInOut)),
    );
    _infoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.4, 0.8, curve: Curves.easeInOut)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: isMobile ? screenWidth * 0.8 : MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/contact_background.jpg'),
                fit: BoxFit.cover,
                colorFilter: ui.ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
              ),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF1A7A74).withOpacity(0.9), Color(0xFF0288D1).withOpacity(0.9)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _titleAnimation,
                    child: Text(
                      Translations.getText(context, 'contactSectionTitle'),
                      style: TextStyle(
                        fontSize: isMobile ? 30 : 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 10),
                  FadeTransition(
                    opacity: _subtitleAnimation,
                    child: Text(
                      Translations.getText(context, 'contactSectionSubtitle'),
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 20,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            color: Colors.white,
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('website_content').doc('main').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Text('No data available');
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;
                var languageProvider = Provider.of<LanguageProvider>(context);
                String companyName = languageProvider.languageCode == 'ar'
                    ? data['company_name_ar'] ?? 'غير متوفر'
                    : data['company_name_en'] ?? 'Not available';
                String mobileNumbers = languageProvider.languageCode == 'ar'
                    ? data['mobile_numbers_ar'] ?? 'غير متوفر'
                    : data['mobile_numbers_en'] ?? 'Not available';
                String email = languageProvider.languageCode == 'ar'
                    ? data['email_ar'] ?? 'غير متوفر'
                    : data['email_en'] ?? 'Not available';

                return FadeTransition(
                  opacity: _infoAnimation,
                  child: isMobile
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildContactItem(context, Translations.getText(context, 'companyAddress'), companyName, isMobile),
                      _buildContactItem(context, Translations.getText(context, 'callUs'), mobileNumbers, isMobile),
                      _buildContactItem(context, Translations.getText(context, 'emailUs'), email, isMobile),
                    ],
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildContactItem(context, Translations.getText(context, 'companyAddress'), companyName, isMobile),
                      _buildContactItem(context, Translations.getText(context, 'callUs'), mobileNumbers, isMobile),
                      _buildContactItem(context, Translations.getText(context, 'emailUs'), email, isMobile),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, String title, String content, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0288D1),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}