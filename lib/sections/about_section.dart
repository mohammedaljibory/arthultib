import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height , // زيادة الطول ليشغل مساحة أكبر
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 100,
          ),
          SizedBox(height: 20),
          Text(
            'شريكك الموثوق في عالم المستلزمات الطبية!',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          Text(
            'تأسست شركة أرض الطب بهدف توفير حلول طبية متكاملة للأفراد والمستشفيات والعيادات الطبية.\n'
                'نسعى دائمًا لنكون من الشركات الموردة للمستلزمات الطبية من خلال تقديم أحدث التقنيات وأفضل المنتجات الطبية.',
            style: TextStyle(
              fontSize: 25,
              color: Colors.teal[800],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50),
          _buildSectionTitle('رؤيتنا'),
          SizedBox(height: 15),
          Text(
            'أن نكون المورد الأول للمستلزمات الطبية في المنطقة، بتقديم منتجات موثوقة تلبي احتياجات السوق الطبي المتنامي.',
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 50),
          _buildSectionTitle('رسالتنا'),
          SizedBox(height: 15),
          Text(
            'تقديم منتجات طبية معتمدة تساعد في تحسين جودة الرعاية الصحية، مع التركيز على خدمة العملاء والابتكار المستمر.',
            style: TextStyle(
              fontSize: 25,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.bold,
        color: Colors.blue[900],
      ),
      textAlign: TextAlign.center,
    );
  }
}
