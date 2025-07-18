/*
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
*/
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'auth/simple_test_auth.dart';
import 'firebase_options.dart';
import 'language_provider.dart';
import 'providers/auth_provider.dart'; // ADD THIS
import 'translations.dart';
import 'sections/home_section.dart';
import 'sections/about_section.dart';
import 'sections/products_section.dart';
import 'sections/origins_section.dart';
import 'sections/gallery_section.dart';
import 'sections/contact_section.dart';
import 'sections/store.dart';
import 'screens/sign_in_screen.dart'; // ADD THIS
import 'screens/sign_up_screen.dart'; // ADD THIS
import 'utilis/upload_initial_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider( // CHANGE TO MULTIPROVIDER
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()), // ADD THIS
      ],
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
      initialRoute: '/store', // Start with store
      routes: {
        '/': (context) => MainPage(), // Main page with sections
        '/store': (context) => StorePage(),
        '/sign-in': (context) => SignInScreen(),
        '/sign-up': (context) => SignUpScreen(),

       // '/test-sign-in': (context) => TestSignInScreen(), // Add this

      },
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
    var authProvider = Provider.of<AuthProvider>(context); // ADD THIS

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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 50,
                  width: 50,
                  child: Center(
                    child: Text(
                      'أ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 10),
          ],
        ),
        actions: [
          if (isDesktop) ...[
            // Store Button
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/store');
              },
              icon: Icon(Icons.store, color: Colors.white),
              label: Text(
                languageProvider.languageCode == 'ar' ? 'المتجر' : 'Store',
                style: TextStyle(color: Colors.white),
              ),
            ),

            // Section buttons
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

            // User Menu or Login Button
            if (authProvider.isAuthenticated)
              PopupMenuButton<String>(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        authProvider.currentUser?.name ?? '',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                onSelected: (value) {
                  if (value == 'profile') {
                    // Navigate to profile
                  } else if (value == 'orders') {
                    // Navigate to orders
                  } else if (value == 'logout') {
                    authProvider.signOut();
                    Navigator.pushReplacementNamed(context, '/sign-in');
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outline),
                        SizedBox(width: 8),
                        Text(languageProvider.languageCode == 'ar' ? 'الملف الشخصي' : 'Profile'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'orders',
                    child: Row(
                      children: [
                        Icon(Icons.shopping_bag_outlined),
                        SizedBox(width: 8),
                        Text(languageProvider.languageCode == 'ar' ? 'طلباتي' : 'My Orders'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text(languageProvider.languageCode == 'ar' ? 'تسجيل الخروج' : 'Logout'),
                      ],
                    ),
                  ),
                ],
              )
            else
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/sign-in');
                },
                child: Text(
                  languageProvider.languageCode == 'ar' ? 'تسجيل الدخول' : 'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (authProvider.isAuthenticated) ...[
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        authProvider.currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          fontSize: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      authProvider.currentUser?.name ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    Text(
                      Translations.getText(context, 'appTitle'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Store Link
            ListTile(
              leading: Icon(Icons.store),
              title: Text(languageProvider.languageCode == 'ar' ? 'المتجر' : 'Store'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/store');
              },
            ),

            Divider(),

            // Section Links
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

            Divider(),

            // User Options
            if (authProvider.isAuthenticated) ...[
              ListTile(
                leading: Icon(Icons.person_outline),
                title: Text(languageProvider.languageCode == 'ar' ? 'الملف الشخصي' : 'Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_bag_outlined),
                title: Text(languageProvider.languageCode == 'ar' ? 'طلباتي' : 'My Orders'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to orders
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text(languageProvider.languageCode == 'ar' ? 'تسجيل الخروج' : 'Logout'),
                onTap: () {
                  Navigator.pop(context);
                  authProvider.signOut();
                  Navigator.pushReplacementNamed(context, '/sign-in');
                },
              ),
            ] else ...[
              ListTile(
                leading: Icon(Icons.login),
                title: Text(languageProvider.languageCode == 'ar' ? 'تسجيل الدخول' : 'Login'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/sign-in');
                },
              ),
            ],

            Divider(),

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