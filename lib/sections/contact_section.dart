import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class ContactSection extends StatefulWidget {
  @override
  _ContactSectionState createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _titleAnimation;
  late Animation<double> _subtitleAnimation;
  late Animation<double> _infoAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    // أنيميشن لكل جزء مع تأخير طفيف
    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _subtitleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.2, 0.6, curve: Curves.easeInOut),
      ),
    );

    _infoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // الجزء العلوي مع الصورة الخلفية والنصوص في المنتصف
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.7, // تغطية جزء كبير من الشاشة
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/contact_background.jpg'),
              fit: BoxFit.cover,
              colorFilter: ui.ColorFilter.mode(
                Colors.black.withOpacity(0.2), // شفافية خفيفة للصورة
                BlendMode.dstATop,
              ),
            ),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF1A7A74).withOpacity(0.9), // أخضر من اليسار
                Color(0xFF0288D1).withOpacity(0.9), // أزرق من اليمين
              ],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _titleAnimation.value,
                  duration: Duration(milliseconds: 1000),
                  child: Text(
                    'اتصل بنا',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 40,
                    ) ??
                        TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                AnimatedOpacity(
                  opacity: _subtitleAnimation.value,
                  duration: Duration(milliseconds: 1000),
                  child: Text(
                    'هل تبحث عن معلومات إضافية؟',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ) ??
                        TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        // الجزء السفلي مع معلومات الاتصال
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          color: Colors.white, // خلفية بيضاء لمعلومات الاتصال
          child: AnimatedOpacity(
            opacity: _infoAnimation.value,
            duration: Duration(milliseconds: 1000),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'عنوان',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Color(0xFF0288D1),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ) ??
                          TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0288D1),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'شارع الغدير - مجاور المخبز الفرنسي',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontSize: 16,
                      ) ??
                          TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'اتصل بي',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Color(0xFF0288D1),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ) ??
                          TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0288D1),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      '00964-780-0175-770',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontSize: 16,
                      ) ??
                          TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5),
                    Text(
                      '00964-780-0000-000',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontSize: 16,
                      ) ??
                          TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'ارسل لي',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Color(0xFF0288D1),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ) ??
                          TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0288D1),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'm.aziz@gmail.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontSize: 16,
                      ) ??
                          TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
