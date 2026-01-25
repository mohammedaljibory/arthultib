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
        primaryColor: Color(0xFF0066CC),
        scaffoldBackgroundColor: Color(0xFFFFFFFF),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF0066CC),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFFFAFBFC),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF1A1A1A),
        ),
        // Enable Material 3 for better performance
        useMaterial3: true,
        // Modern text theme
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.5,
            color: Color(0xFF1A1A1A),
          ),
          displayMedium: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
            color: Color(0xFF1A1A1A),
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
            height: 1.7,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6B7280),
            height: 1.6,
          ),
        ),
        // Modern elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0066CC),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
        // Modern outlined button theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFF0066CC),
            side: BorderSide(color: Color(0xFF0066CC), width: 1.5),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
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
                color: Color(0xFF0066CC),
                strokeWidth: 2,
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
  int _activeSection = 0; // Track active section for highlighting
  int _lastActiveSection = 0; // Track last active to prevent flickering

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

    // Update scroll state immediately (no flickering here)
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

    // Detect active section with stability check
    final newActiveSection = _detectActiveSection();
    if (newActiveSection != _activeSection && newActiveSection == _lastActiveSection) {
      // Only update if the new section is stable (same as last detected)
      setState(() {
        _activeSection = newActiveSection;
      });
    }
    _lastActiveSection = newActiveSection;
  }

  int _detectActiveSection() {
    final keys = [_homeKey, _aboutKey, _productsKey, _originsKey, _galleryKey, _contactKey];
    final screenHeight = MediaQuery.of(context).size.height;
    final triggerPoint = screenHeight * 0.4; // 40% from top of screen for more stability

    for (int i = keys.length - 1; i >= 0; i--) {
      final key = keys[i];
      final ctx = key.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final position = box.localToGlobal(Offset.zero);
          // Add hysteresis: section must be well within view
          if (position.dy <= triggerPoint) {
            return i;
          }
        }
      }
    }
    return 0;
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
        preferredSize: Size.fromHeight(isDesktop ? 72 : 60),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: _isScrolled ? Colors.white : Colors.white.withOpacity(0.98),
            boxShadow: _isScrolled
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ]
                : null,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: isDesktop ? 72 : 60,
            title: Row(
              children: [
                // Logo with modern styling
                Hero(
                  tag: 'app_logo',
                  child: Image.asset(
                    'assets/images/fullLogo.png',
                    height: isDesktop ? 48 : 40,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        'ARTHULTIB',
                        style: TextStyle(
                          color: Color(0xFF0066CC),
                          fontSize: isDesktop ? 22 : 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              if (isDesktop) ...[
                // Navigation items with active section highlighting
                ...sections.asMap().entries.map((entry) {
                  final index = entry.key;
                  final section = entry.value;
                  return _buildNavItem(
                    text: section['name'],
                    onPressed: () => _scrollToSection(section['key']),
                    isActive: _activeSection == index,
                  );
                }).toList(),

                SizedBox(width: 24),

                // Store button with modern pill styling (at the end)
                Container(
                  margin: EdgeInsets.symmetric(vertical: 14),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/store'),
                    icon: Icon(Icons.store_outlined, size: 18),
                    label: Text(
                      languageProvider.languageCode == 'ar' ? 'المتجر' : 'Store',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0066CC),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),

                // User menu or login
                if (authProvider.isAuthenticated)
                  _buildUserMenu(authProvider, languageProvider)
                else
                  _buildLoginButton(languageProvider),

                // Language switcher with modern style
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.language,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                    ),
                    tooltip: Translations.getText(context, 'changeLanguage'),
                    onPressed: () {
                      languageProvider.setLanguage(
                          languageProvider.languageCode == 'ar' ? 'en' : 'ar'
                      );
                    },
                  ),
                ),
                SizedBox(width: 16),
              ] else ...[
                // Mobile menu button with modern style
                Builder(
                  builder: (context) => Container(
                    margin: EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.menu, color: Color(0xFF1A1A1A), size: 22),
                      ),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ),
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
                      color: Color(0xFFFAFBFC),
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
                      color: Color(0xFFFAFBFC),
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
                      color: Color(0xFFFAFBFC),
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
          backgroundColor: Color(0xFF0066CC),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.arrow_upward, color: Colors.white, size: 20),
          mini: true,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String text,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          backgroundColor: isActive ? Color(0xFF0066CC).withOpacity(0.1) : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Color(0xFF0066CC) : Color(0xFF1A1A1A),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildUserMenu(AuthProvider authProvider, LanguageProvider languageProvider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      child: PopupMenuButton<String>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        offset: Offset(0, 50),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Color(0xFF0066CC).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline, color: Color(0xFF0066CC), size: 18),
              ),
              SizedBox(width: 10),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 120),
                child: Text(
                  authProvider.currentUser?.name ?? '',
                  style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280), size: 20),
            ],
          ),
        ),
        onSelected: (value) {
          switch (value) {
            case 'profile':
              Navigator.pushNamed(context, '/account');
              break;
            case 'orders':
              Navigator.pushNamed(context, '/account');
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
                Icon(Icons.person_outline, color: Color(0xFF6B7280), size: 20),
                SizedBox(width: 12),
                Text(languageProvider.languageCode == 'ar' ? 'الملف الشخصي' : 'Profile'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'orders',
            child: Row(
              children: [
                Icon(Icons.shopping_bag_outlined, color: Color(0xFF6B7280), size: 20),
                SizedBox(width: 12),
                Text(languageProvider.languageCode == 'ar' ? 'طلباتي' : 'My Orders'),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                SizedBox(width: 12),
                Text(
                  languageProvider.languageCode == 'ar' ? 'تسجيل الخروج' : 'Logout',
                  style: TextStyle(color: Color(0xFFEF4444)),
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
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: OutlinedButton(
        onPressed: () => Navigator.pushNamed(context, '/sign-in'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          backgroundColor: Colors.transparent,
        ),
        child: Text(
          languageProvider.languageCode == 'ar' ? 'تسجيل الدخول' : 'Login',
          style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 14, fontWeight: FontWeight.w500),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: Container(
        color: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Modern minimal header
            Container(
              padding: EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (authProvider.isAuthenticated) ...[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Color(0xFF0066CC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          authProvider.currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF0066CC),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      authProvider.currentUser?.name ?? '',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      languageProvider.languageCode == 'ar' ? 'مرحباً بك' : 'Welcome back',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ] else ...[
                    Image.asset(
                      'assets/images/logo.png',
                      height: 48,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          'ARTHULTIB',
                          style: TextStyle(
                            color: Color(0xFF0066CC),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12),
                    Text(
                      languageProvider.languageCode == 'ar'
                          ? 'شركة أرض الطب'
                          : 'Medical Solutions',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 16),

            // Section links first
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                languageProvider.languageCode == 'ar' ? 'التنقل' : 'Navigation',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            SizedBox(height: 8),
            ...sections.asMap().entries.map((entry) {
              final index = entry.key;
              final section = entry.value;
              final isActive = _activeSection == index;
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: isActive ? Color(0xFF0066CC).withOpacity(0.1) : null,
                  leading: Icon(
                    section['icon'],
                    color: isActive ? Color(0xFF0066CC) : Color(0xFF6B7280),
                    size: 22,
                  ),
                  title: Text(
                    section['name'],
                    style: TextStyle(
                      color: isActive ? Color(0xFF0066CC) : Color(0xFF1A1A1A),
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _scrollToSection(section['key']);
                  },
                ),
              );
            }).toList(),

            SizedBox(height: 16),

            // Store link at the end
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFF0066CC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: Icon(Icons.store_outlined, color: Colors.white),
                title: Text(
                  languageProvider.languageCode == 'ar' ? 'المتجر' : 'Store',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/store');
                },
              ),
            ),

            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: Color(0xFFF3F4F6)),
            ),
            SizedBox(height: 8),

            // User options
            if (authProvider.isAuthenticated) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  languageProvider.languageCode == 'ar' ? 'الحساب' : 'Account',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(Icons.person_outline, color: Color(0xFF6B7280)),
                  title: Text(
                    languageProvider.languageCode == 'ar' ? 'الملف الشخصي' : 'Profile',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/account');
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(Icons.shopping_bag_outlined, color: Color(0xFF6B7280)),
                  title: Text(
                    languageProvider.languageCode == 'ar' ? 'طلباتي' : 'My Orders',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/account');
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(Icons.logout, color: Color(0xFFEF4444)),
                  title: Text(
                    languageProvider.languageCode == 'ar' ? 'تسجيل الخروج' : 'Logout',
                    style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    authProvider.signOut();
                    Navigator.pushReplacementNamed(context, '/sign-in');
                  },
                ),
              ),
            ] else ...[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.login, size: 20),
                  label: Text(
                    languageProvider.languageCode == 'ar' ? 'تسجيل الدخول' : 'Login',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/sign-in');
                  },
                ),
              ),
            ],

            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(color: Color(0xFFF3F4F6)),
            ),

            // Language switcher
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: Icon(Icons.language, color: Color(0xFF6B7280)),
                title: Text(
                  Translations.getText(context, 'changeLanguage'),
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    languageProvider.languageCode == 'ar' ? 'EN' : 'AR',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                      fontSize: 13,
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
            ),

            // Footer info
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '© 2024 ARTHULTIB',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
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