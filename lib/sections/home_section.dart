import 'package:flutter/material.dart';
import '../translations.dart';

class HomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            height: isMobile ? screenWidth * 0.7 : MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/homeBG.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Translations.getText(context, 'appTitle'),
                    style: TextStyle(
                      fontSize: isMobile ? 30 : 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 5 : 10),
                  Text(
                    Translations.getText(context, 'homeSectionTitle'),
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 20,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 15 : 30,
              vertical: isMobile ? 15 : 30,
            ),
            child: Column(
              children: [
                Text(
                  Translations.getText(context, 'homeSectionDescription'),
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 18,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 5 : 10),
                Text(
                  Translations.getText(context, 'homeSectionDetails'),
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}