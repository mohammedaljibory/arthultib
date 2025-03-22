import 'package:flutter/material.dart';

class HomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
                  'ارض الطب',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'وجهتك الأولى للمستلزمات الطبية عالية الجودة',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          child: Column(
            children: [
              Text(
                'نحن في شركة أرض الطب نوفر لك كل ما تحتاجه من مستلزمات طبية بأعلى معايير الجودة العالمية.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'سواء كنت تبحث عن أجهزة طبية، مستلزمات المستشفيات، أو الأدوات الطبية الشخصية، نحن هنا لنلبي احتياجاتك بأفضل الأسعار وأعلى مستوى من الخدمة.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
