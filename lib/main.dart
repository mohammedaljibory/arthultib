import 'dart:ui';
import 'package:company_website/providers/cart_provider.dart';
import 'package:company_website/screens/acountPage_m.dart';
import 'package:company_website/screens/cartPage_m.dart';
import 'package:company_website/screens/saved_items_page.dart';
import 'package:company_website/screens/search.dart';
import 'package:company_website/sections/store_m.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'language_provider.dart';
import 'providers/auth_provider.dart';
import 'translations.dart';
import 'sections/home_section.dart';
import 'sections/about_section.dart';
import 'sections/products_section.dart';
import 'sections/origins_section.dart';
import 'sections/gallery_section.dart';
import 'sections/contact_section.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/address_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable performance optimizations for web
  if (kIsWeb) {
    // Optimize image cache for better performance
    PaintingBinding.instance.imageCache.maximumSizeBytes = 250 << 20; // 250MB
    PaintingBinding.instance.imageCache.maximumSize = 200; // 200 images
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kIsWeb) {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: Provider.of<LanguageProvider>(context).languageCode == 'ar' ? 'Tajawal' : 'Roboto',
        primaryColor: Color(0xFF004080),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF004080),
          secondary: Color(0xFF0288D1),
        ),
        // Enable Material 3 for better performance
        useMaterial3: true,
      ),
      home: AuthStateHandler(),
    );
  }
}

class AuthStateHandler extends StatefulWidget {
  @override
  _AuthStateHandlerState createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuthState();
    });
  }

  Future<void> _initializeAuthState() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.initializeAuth();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF004080),
              ),
            ),
          );
        }
        return Navigator(
          initialRoute: '/',
          onGenerateRoute: (settings) {

            switch (settings.name) {
              case '/':
                return MaterialPageRoute(builder: (_) => MainPage());
              case '/store':
                return MaterialPageRoute(builder: (_) => MedicalStorePage());
              case '/sign-in':
                return MaterialPageRoute(builder: (_) => SignInScreen());
              case '/sign-up':
                return MaterialPageRoute(builder: (_) => SignUpScreen());
              case '/saved-items':
                return MaterialPageRoute(builder: (_) => SavedItemsPage());
              case '/cart':
                return MaterialPageRoute(builder: (_) => CartPage());
            case '/search':
            return MaterialPageRoute(builder: (_) => SearchPage());
            case '/account':
            return MaterialPageRoute(builder: (_) => AccountPage());
              default:
                return MaterialPageRoute(builder: (_) => MedicalStorePage());
            }
          },
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  bool _isScrolled = false;
  double _scrollPosition = 0;
  bool _showScrollToTop = false;

  // Section keys for scroll navigation
  final GlobalKey _homeKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _productsKey = GlobalKey();
  final GlobalKey _originsKey = GlobalKey();
  final GlobalKey _galleryKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Initialize FAB animation
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    // Optimized scroll listener
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final offset = _scrollController.offset;
    final newIsScrolled = offset > 50;
    final newShowScrollToTop = offset > 300;

    // Only update state if values actually changed
    if (newIsScrolled != _isScrolled || newShowScrollToTop != _showScrollToTop) {
      setState(() {
        _isScrolled = newIsScrolled;
        _showScrollToTop = newShowScrollToTop;
        _scrollPosition = offset;
      });

      // Animate FAB
      if (_showScrollToTop) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 800),
        curve: Curves.easeInOutQuad,
      );
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOutQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isDesktop = screenWidth >= 900;
    bool isTablet = screenWidth >= 600 && screenWidth < 900;
    var languageProvider = Provider.of<LanguageProvider>(context);
    var authProvider = Provider.of<AuthProvider>(context);

    final List<Map<String, dynamic>> sections = [
      {
        'name': languageProvider.languageCode == 'ar' ? 'الصفحة الرئيسية' : 'Home',
        'key': _homeKey,
        'icon': Icons.home_outlined
      },
      {
        'name': languageProvider.languageCode == 'ar' ? 'تعرف علينا' : 'About Us',
        'key': _aboutKey,
        'icon': Icons.info_outlined
      },
      {
        'name': languageProvider.languageCode == 'ar' ? 'المنتجات' : 'Products',
        'key': _productsKey,
        'icon': Icons.medical_services_outlined
      },
      {
        'name': languageProvider.languageCode == 'ar' ? 'الشركاء' : 'Partners',
        'key': _originsKey,
        'icon': Icons.handshake_outlined
      },
      {
        'name': languageProvider.languageCode == 'ar' ? 'المعرض' : 'Gallery',
        'key': _galleryKey,
        'icon': Icons.photo_library_outlined
      },
      {
        'name': languageProvider.languageCode == 'ar' ? 'التواصل' : 'Contact',
        'key': _contactKey,
        'icon': Icons.contact_mail_outlined
      },
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isDesktop ? 80 : 65),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isScrolled ? Colors.white : Colors.white.withOpacity(0.95),
            boxShadow: _isScrolled
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: isDesktop ? 80 : 65,
            title: Row(
              children: [
                // Logo with hero animation potential
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/images/fullLogo.png',
                    height: isDesktop ? 60 : 45,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'ARTHULTIB',
                        style: TextStyle(
                          color: Color(0xFF004080),
                          fontSize: isDesktop ? 24 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              if (isDesktop) ...[
                // Navigation items with hover effects
                ...sections.map((section) {
                  return _buildNavItem(
                    text: section['name'],
                    onPressed: () => _scrollToSection(section['key']),
                  );
                }).toList(),

                SizedBox(width: 20),

                // Store button with premium styling
                Container(
                  margin: EdgeInsets.symmetric(vertical: 15),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/store'),
                    icon: Icon(Icons.store_outlined, size: 18),
                    label: Text(
                      languageProvider.languageCode == 'ar' ? 'المتجر' : 'Store',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF004080),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),

                // User menu or login
                if (authProvider.isAuthenticated)
                  _buildUserMenu(authProvider, languageProvider)
                else
                  _buildLoginButton(languageProvider),

                // Language switcher
                IconButton(
                  icon: Icon(
                    Icons.language,
                    color: Color(0xFF004080),
                    size: 22,
                  ),
                  tooltip: Translations.getText(context, 'changeLanguage'),
                  onPressed: () {
                    languageProvider.setLanguage(
                        languageProvider.languageCode == 'ar' ? 'en' : 'ar'
                    );
                  },
                ),
                SizedBox(width: 20),
              ] else ...[
                // Mobile menu button
                Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu, color: Color(0xFF004080)),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      endDrawer: !isDesktop ? _buildMobileDrawer(context, authProvider, languageProvider, sections) : null,
      body: Directionality(
        textDirection: languageProvider.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: Scrollbar(
          controller: _scrollController,
          thickness: 8,
          radius: Radius.circular(4),
          thumbVisibility: isDesktop,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: ClampingScrollPhysics(),
            child: Column(
              children: [
                // Home Section with RepaintBoundary for performance
                RepaintBoundary(
                  child: Container(
                    key: _homeKey,
                    child: HomeSection(),
                  ),
                ),

                // About Section
                RepaintBoundary(
                  child: Container(
                    key: _aboutKey,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                    ),
                    child: AboutSection(),
                  ),
                ),

                // Products Section
                RepaintBoundary(
                  child: Container(
                    key: _productsKey,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: ProductsSection(),
                  ),
                ),

                // Partners Section
                RepaintBoundary(
                  child: Container(
                    key: _originsKey,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.grey[50]!, Colors.white],
                      ),
                    ),
                    child: OriginsSection(),
                  ),
                ),

                // Gallery Section
                RepaintBoundary(
                  child: Container(
                    key: _galleryKey,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: GallerySection(),
                  ),
                ),

                // Contact Section
                RepaintBoundary(
                  child: Container(
                    key: _contactKey,
                    decoration: BoxDecoration(
                      color: Color(0xFF004080).withOpacity(0.03),
                    ),
                    child: ContactSection(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: _showScrollToTop ? _scrollToTop : null,
          backgroundColor: Color(0xFF004080),
          elevation: 4,
          child: Icon(Icons.arrow_upward, color: Colors.white),
          mini: true,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String text,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Color(0xFF004080),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUserMenu(AuthProvider authProvider, LanguageProvider languageProvider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: PopupMenuButton<String>(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xFF004080).withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.person_outline, color: Color(0xFF004080), size: 20),
              SizedBox(width: 8),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 150),
                child: Text(
                  authProvider.currentUser?.name ?? '',
                  style: TextStyle(color: Color(0xFF004080), fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Color(0xFF004080)),
            ],
          ),
        ),
        onSelected: (value) {
          switch (value) {
            case 'profile':
            // Handle profile navigation
              break;
            case 'orders':
            // Handle orders navigation
              break;
            case 'logout':
              authProvider.signOut();
              Navigator.pushReplacementNamed(context, '/sign-in');
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person_outline, color: Color(0xFF004080)),
                SizedBox(width: 8),
                Text(languageProvider.languageCode == 'ar' ? 'الملف الشخصي' : 'Profile'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'orders',
            child: Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: Color(0xFF004080)),
                SizedBox(width: 8),
                Text(languageProvider.languageCode == 'ar' ? 'طلباتي' : 'My Orders'),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  languageProvider.languageCode == 'ar' ? 'تسجيل الخروج' : 'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(LanguageProvider languageProvider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, '/sign-in'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Color(0xFF004080)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(
          languageProvider.languageCode == 'ar' ? 'تسجيل الدخول' : 'Login',
          style: TextStyle(color: Color(0xFF004080), fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildMobileDrawer(
      BuildContext context,
      AuthProvider authProvider,
      LanguageProvider languageProvider,
      List<Map<String, dynamic>> sections,
      ) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF004080),
                    Color(0xFF0288D1),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (authProvider.isAuthenticated) ...[
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Text(
                        authProvider.currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          fontSize: 28,
                          color: Color(0xFF004080),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      authProvider.currentUser?.name ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    Image.asset(
                      'assets/images/logo.png',
                      height: 60,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'ARTHULTIB',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      languageProvider.languageCode == 'ar'
                          ? 'شركة أرض الطب'
                          : 'Medical Solutions',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Store link with highlight
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF004080).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(Icons.store_outlined, color: Color(0xFF004080)),
                title: Text(
                  languageProvider.languageCode == 'ar' ? 'المتجر' : 'Store',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/store');
                },
              ),
            ),

            Divider(height: 1, indent: 16, endIndent: 16),

            // Section links
            ...sections.map((section) {
              return ListTile(
                leading: Icon(section['icon'], color: Color(0xFF004080), size: 22),
                title: Text(section['name']),
                onTap: () {
                  Navigator.pop(context);
                  _scrollToSection(section['key']);
                },
              );
            }).toList(),

            Divider(height: 1, indent: 16, endIndent: 16),

            // User options
            if (authProvider.isAuthenticated) ...[
              ListTile(
                leading: Icon(Icons.person_outline, color: Color(0xFF004080)),
                title: Text(languageProvider.languageCode == 'ar' ? 'الملف الشخصي' : 'Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_bag_outlined, color: Color(0xFF004080)),
                title: Text(languageProvider.languageCode == 'ar' ? 'طلباتي' : 'My Orders'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to orders
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text(
                  languageProvider.languageCode == 'ar' ? 'تسجيل الخروج' : 'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  authProvider.signOut();
                  Navigator.pushReplacementNamed(context, '/sign-in');
                },
              ),
            ] else ...[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.login),
                  label: Text(
                    languageProvider.languageCode == 'ar' ? 'تسجيل الدخول' : 'Login',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF004080),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/sign-in');
                  },
                ),
              ),
            ],

            Divider(height: 1, indent: 16, endIndent: 16),

            // Language switcher
            ListTile(
              leading: Icon(Icons.language, color: Color(0xFF004080)),
              title: Text(Translations.getText(context, 'changeLanguage')),
              trailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF004080).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  languageProvider.languageCode == 'ar' ? 'EN' : 'AR',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004080),
                  ),
                ),
              ),
              onTap: () {
                languageProvider.setLanguage(
                    languageProvider.languageCode == 'ar' ? 'en' : 'ar'
                );
                Navigator.pop(context);
              },
            ),

            // Footer info
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '© 2024 ARTHULTIB',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}