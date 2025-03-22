import 'package:flutter/material.dart';
import 'sections/home_section.dart';
import 'sections/contact_section.dart';
import 'sections/about_section.dart';
import 'sections/products_section.dart';
import 'sections/origins_section.dart';
import 'sections/gallery_section.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Tajawal',
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ScrollController _scrollController = ScrollController();
  String activeSection = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      double offset = _scrollController.offset;
      double screenHeight = MediaQuery.of(context).size.height;
      setState(() {
        if (offset < screenHeight * 0.8) {
          activeSection = '';
        } else if (offset < screenHeight * 1.8) {
          activeSection = 'تعرف علينا';
        } else if (offset < screenHeight * 2.8) {
          activeSection = 'المنتجات';
        } else if (offset < screenHeight * 3.8) {
          activeSection = 'المناشئ';
        } else {
          activeSection = 'التواصل';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                HomeSection(),
                AboutSection(),
                ProductsSection(),
                OriginsSection(),
                GallerySection(),
                ContactSection(),

              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: NavigationBar(selected: activeSection),
          ),
        ],
      ),
    );
  }
}

class NavigationBar extends StatelessWidget {
  final String selected;
  NavigationBar({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildNavButton('تعرف علينا', isHighlighted: selected == 'تعرف علينا'),
              _buildNavButton('المنتجات', isHighlighted: selected == 'المنتجات'),
              _buildNavButton('المناشئ', isHighlighted: selected == 'المناشئ'),
              _buildNavButton('المعرض', isHighlighted: selected == 'المعرض'),
              _buildNavButton('التواصل', isHighlighted: selected == 'التواصل'),
            ],
          ),
          Image.asset(
            'assets/images/fullLogo.png',
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String title, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: isHighlighted ? Colors.blue[900] : Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
        onPressed: () {},
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighlighted ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
