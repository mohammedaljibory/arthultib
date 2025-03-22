import 'package:flutter/material.dart';

class ProductsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 1.2,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: Text(
              'المنتجات',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0288D1),
              ) ??
                  TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0288D1),
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            top: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProductCategory(
                  context,
                  'القفازات',
                  'assets/images/products.png',
                  Color(0xFF00A8E8),
                  width: 200,
                ),
                SizedBox(width: 20),
                _buildProductCategory(
                  context,
                  'الأدوات واللوازم الطبية',
                  'assets/images/P2.png',
                  Color(0xFF00C4B4),
                  width: 200,
                ),
              ],
            ),
          ),
          Positioned(
            top: 340,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProductCategory(
                  context,
                  'المستلزمات الطبية المتخصصة',
                  'assets/images/P3.png',
                  Color(0xFF0077B6),
                  width: 200,
                ),
                SizedBox(width: 20),
                _buildProductCategory(
                  context,
                  'الأجهزة الطبية',
                  'assets/images/P1.png',
                  Color(0xFF009B77),
                  width: 200,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCategory(
      BuildContext context, String title, String imagePath, Color color,
      {double width = 200}) {
    return GestureDetector(
      onTap: () {
        _showComingSoonDialog(context);
      },
      child: Container(
        width: width,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(color.withOpacity(0.7), BlendMode.srcOver),
            onError: (exception, stackTrace) {
              print('Error loading image $imagePath: $exception');
            },
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ) ??
                TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'قريبًا',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0288D1),
            ) ??
                TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0288D1),
                ),
          ),
          content: Text(
            'قريبًا سوف يتم افتتاح قسم المتجر',
            style: Theme.of(context).textTheme.bodyLarge ??
                TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: Text(
                'إغلاق',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Color(0xFF0288D1),
                ) ??
                    TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0288D1),
                    ),
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
