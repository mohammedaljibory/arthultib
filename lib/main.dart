import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'language_provider.dart';
import 'translations.dart';
import 'sections/home_section.dart';
import 'sections/about_section.dart';
import 'sections/products_section.dart';
import 'sections/origins_section.dart';
import 'sections/gallery_section.dart';
import 'sections/contact_section.dart';
import 'sections/store.dart';
import 'utilis/upload_initial_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: Provider.of<LanguageProvider>(context).languageCode == 'ar' ? 'Tajawal' : 'Roboto',
        primaryColor: Color(0xFF004080),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: StorePage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> sectionWidgets = [
    HomeSection(),
    AboutSection(),
    ProductsSection(),
    OriginsSection(),
    GallerySection(),
    ContactSection(),
  ];

  void _onSectionTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth >= 600;
    var languageProvider = Provider.of<LanguageProvider>(context);
    final List<String> sections = languageProvider.languageCode == 'ar'
        ? [
      'الصفحة الرئيسية',
      'تعرف علينا',
      'المنتجات',
      'المناشئ',
      'المعرض',
      'التواصل',
    ]
        : [
      'Home',
      'About Us',
      'Products',
      'Origins',
      'Gallery',
      'Contact',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Row(
          children: [
            Image.asset(
              'assets/images/fullLogo.png',
              height: 50,
              color: Colors.white,
            ),
            SizedBox(width: 10),
          ],
        ),
        actions: [
          if (isDesktop) ...[
            ...sections.reversed.map((section) {
              int index = sections.indexOf(section);
              return TextButton(
                onPressed: () => _onSectionTapped(index),
                child: Text(
                  section,
                  style: TextStyle(
                    color: _selectedIndex == index ? Colors.yellow : Colors.white,
                    fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
            // Language Switcher
            IconButton(
              icon: Icon(Icons.language, color: Colors.white),
              tooltip: Translations.getText(context, 'changeLanguage'),
              onPressed: () {
                languageProvider.setLanguage(languageProvider.languageCode == 'ar' ? 'en' : 'ar');
              },
            ),
            SizedBox(width: 10),
          ],
        ],
      ),
      drawer: !isDesktop
          ? Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Center(
                child: Text(
                  Translations.getText(context, 'appTitle'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ...sections.map((section) {
              int index = sections.indexOf(section);
              return ListTile(
                title: Text(
                  section,
                  style: TextStyle(
                    color: _selectedIndex == index ? Theme.of(context).primaryColor : Colors.black,
                    fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  _onSectionTapped(index);
                  Navigator.pop(context);
                },
              );
            }).toList(),
            // Language Switcher in Drawer
            ListTile(
              leading: Icon(Icons.language),
              title: Text(Translations.getText(context, 'changeLanguage')),
              onTap: () {
                languageProvider.setLanguage(languageProvider.languageCode == 'ar' ? 'en' : 'ar');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      )
          : null,
      body: Directionality(
        textDirection: languageProvider.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: PageView(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: sectionWidgets,
        ),
      ),
    );
  }
}