import 'package:flutter/material.dart';
import '../translations.dart';

class AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 15 : 30,
          vertical: isMobile ? 20 : 50,
        ),
        child: Column(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: isMobile ? 60 : 100,
            ),
            SizedBox(height: isMobile ? 10 : 20),
            Text(
              Translations.getText(context, 'aboutSectionTitle'),
              style: TextStyle(
                fontSize: isMobile ? 24 : 40,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 10 : 15),
            Text(
              Translations.getText(context, 'aboutSectionDescription'),
              style: TextStyle(
                fontSize: isMobile ? 16 : 25,
                color: Colors.teal[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 20 : 50),
            _buildSectionTitle(Translations.getText(context, 'aboutVisionTitle'), isMobile),
            SizedBox(height: isMobile ? 10 : 15),
            Text(
              Translations.getText(context, 'aboutVisionDescription'),
              style: TextStyle(
                fontSize: isMobile ? 16 : 25,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 20 : 50),
            _buildSectionTitle(Translations.getText(context, 'aboutMissionTitle'), isMobile),
            SizedBox(height: isMobile ? 10 : 15),
            Text(
              Translations.getText(context, 'aboutMissionDescription'),
              style: TextStyle(
                fontSize: isMobile ? 16 : 25,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isMobile) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isMobile ? 30 : 50,
        fontWeight: FontWeight.bold,
        color: Colors.blue[900],
      ),
      textAlign: TextAlign.center,
    );
  }
}