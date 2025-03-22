import 'package:flutter/material.dart';

class OriginsSection extends StatelessWidget {
  final List<Map<String, String>> brands = [
    {'name': 'Medtronic', 'image': 'assets/images/medtronic.png'},
    {'name': 'Philips', 'image': 'assets/images/philips.png'},
    {'name': 'Siemens Healthineers', 'image': 'assets/images/siemens.png'},
    {'name': 'GE Healthcare', 'image': 'assets/images/gehealthcare.png'},
    {'name': 'Boston Scientific', 'image': 'assets/images/bostonscientific.png'},
  ];

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
              'المناشئ',
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
                _buildBrandCard(context, brands[0]),
                SizedBox(width: 20),
                _buildBrandCard(context, brands[1]),
                SizedBox(width: 20),
                _buildBrandCard(context, brands[2]),
              ],
            ),
          ),
          Positioned(
            top: 350, // مسافة كافية لصف جديد مع ثلاث بطاقات
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBrandCard(context, brands[3]),
                SizedBox(width: 20),
                _buildBrandCard(context, brands[4]),
                SizedBox(width: 20), // مساحة لعلامة تجارية إضافية إذا لزم الأمر
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandCard(BuildContext context, Map<String, String> brand) {
    return GestureDetector(
      onTap: () {
        _showBrandInfoDialog(context, brand['name']!);
      },
      child: Container(
        width: 300, // عرض أكبر لنمط Landscape
        height: 150, // ارتفاع أقل لنمط Landscape
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage(brand['image']!),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Color(0xFF00A8E8).withOpacity(0.7),
              BlendMode.srcOver,
            ),
            onError: (exception, stackTrace) {
              print('Error loading image ${brand['image']}: $exception');
            },
          ),
        ),
        child: Center(
          child: Text(
            brand['name']!,
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

  void _showBrandInfoDialog(BuildContext context, String brandName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            brandName,
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
            'معلومات إضافية عن $brandName قريبًا!',
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