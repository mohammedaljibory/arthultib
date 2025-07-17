import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../translations.dart';
import '../language_provider.dart';
import 'package:provider/provider.dart';

class OriginsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
        child: Column(
          children: [
            Text(
              Translations.getText(context, 'originsSectionTitle'),
              style: TextStyle(
                fontSize: isMobile ? 24 : 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0288D1),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('posts').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Error fetching data: ${snapshot.error}');
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      Translations.getText(context, 'originsNoData'),
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      Translations.getText(context, 'originsNoData'),
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                var languageProvider = Provider.of<LanguageProvider>(context);
                List<Map<String, String>> brands = snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return {
                    'name': languageProvider.languageCode == 'ar'
                        ? (data['title_ar'] as String? ?? Translations.getText(context, 'notAvailable'))
                        : (data['title_en'] as String? ?? Translations.getText(context, 'notAvailable')),
                    'image': (data['url'] as String? ?? ''),
                  };
                }).toList();

                return isMobile
                    ? Column(
                  children: brands
                      .asMap()
                      .entries
                      .map((entry) {
                    int index = entry.key;
                    Map<String, String> brand = entry.value;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: _buildBrandCard(context, brand, screenWidth, index),
                    );
                  })
                      .toList(),
                )
                    : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (brands.length > 0) _buildBrandCard(context, brands[0], screenWidth, 0),
                        if (brands.length > 0) SizedBox(width: 20),
                        if (brands.length > 1) _buildBrandCard(context, brands[1], screenWidth, 1),
                        if (brands.length > 1) SizedBox(width: 20),
                        if (brands.length > 2) _buildBrandCard(context, brands[2], screenWidth, 2),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (brands.length > 3) _buildBrandCard(context, brands[3], screenWidth, 3),
                        if (brands.length > 3) SizedBox(width: 20),
                        if (brands.length > 4) _buildBrandCard(context, brands[4], screenWidth, 4),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandCard(BuildContext context, Map<String, String> brand, double screenWidth, int index) {
    String name = brand['name'] ?? Translations.getText(context, 'notAvailable');
    String image = brand['image'] ?? '';

    return GestureDetector(
      key: ValueKey(index), // Add a unique key to avoid widget rebuilding issues
      onTap: () {
        _showBrandInfoDialog(context, name);
      },
      child: Container(
        width: screenWidth < 600 ? screenWidth * 0.8 : 300,
        height: screenWidth < 600 ? 100 : 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            image.isNotEmpty
                ? Image.network(
              image,
              fit: BoxFit.cover,
              color: Color(0xFF00A8E8).withOpacity(0.7),
              colorBlendMode: BlendMode.srcOver,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: $image, Error: $error');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 50, color: Colors.red),
                      SizedBox(height: 10),
                      Text(
                        Translations.getText(context, 'originsImageLoadError'),
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    Translations.getText(context, 'originsImageNotAvailable'),
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            Center(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: screenWidth < 600 ? 18 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBrandInfoDialog(BuildContext context, String brandName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            brandName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0288D1),
            ),
          ),
          content: Text(
            Translations.getText(context, 'brandInfoComingSoon', params: {'brandName': brandName}),
            style: TextStyle(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: Text(
                Translations.getText(context, 'close'),
                style: TextStyle(fontSize: 16, color: Color(0xFF0288D1)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}