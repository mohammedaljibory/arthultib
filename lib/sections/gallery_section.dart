import 'package:flutter/material.dart';

class GallerySection extends StatefulWidget {
  @override
  _GallerySectionState createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection> {
  final List<String> images = [
    'assets/images/gallery1.jpg',
    'assets/images/gallery2.jpg',
    'assets/images/gallery3.jpg',
    'assets/images/gallery4.jpg',
    'assets/images/gallery5.jpg',
    'assets/images/gallery6.jpg',
  ];
  int _currentIndex = 0;
  late PageController _thumbnailController;

  @override
  void initState() {
    super.initState();
    _thumbnailController = PageController(viewportFraction: 0.3);
  }

  @override
  void dispose() {
    _thumbnailController.dispose();
    super.dispose();
  }

  void _previousImage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _thumbnailController.animateToPage(
          _currentIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _nextImage() {
    if (_currentIndex < images.length - 1) {
      setState(() {
        _currentIndex++;
        _thumbnailController.animateToPage(
          _currentIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height , // تقليل الارتفاع ليتناسب مع الصفحة
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: Text(
              'معرض الصور',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Color(0xFF0288D1),
              ) ??
                  TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0288D1),
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            top: 50,
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              height: 600, // ارتفاع الصورة الكبيرة
              child: Stack(
                children: [
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 500),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: Card(
                      key: ValueKey<int>(_currentIndex),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          images[_currentIndex],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: Center(
                                child: Text(
                                  'Error loading image',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_left,
                        color: _currentIndex > 0 ? Colors.white : Colors.grey,
                        size: 40,
                      ),
                      onPressed: _currentIndex > 0 ? _previousImage : null,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_right,
                        color: _currentIndex < images.length - 1 ? Colors.white : Colors.grey,
                        size: 40,
                      ),
                      onPressed: _currentIndex < images.length - 1 ? _nextImage : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              height: 80,
              width: MediaQuery.of(context).size.width - 40,
              child: PageView.builder(
                controller: _thumbnailController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                        _thumbnailController.animateToPage(
                          index,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentIndex == index ? Color(0xFF0288D1) : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          images[index],
                          fit: BoxFit.cover,
                          width: 40,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: Center(
                                child: Text(
                                  'Error',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}