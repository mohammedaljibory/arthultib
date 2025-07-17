import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../translations.dart';
import '../language_provider.dart';
import 'package:provider/provider.dart';

class GallerySection extends StatefulWidget {
  @override
  _GallerySectionState createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection> {
  void _openImageGallery(BuildContext context, int initialIndex, List<Map<String, String>> galleryItems) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryPhotoViewWrapper(
          galleryItems: galleryItems,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    int crossAxisCount = isMobile ? 2 : 4;
    double imageSize = isMobile ? screenWidth * 0.45 : 200;

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 10 : 20),
        child: Column(
          children: [
            Text(
              Translations.getText(context, 'gallerySectionTitle'),
              style: TextStyle(
                fontSize: isMobile ? 24 : 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0288D1),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('gallery').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  print('Error fetching gallery data: ${snapshot.error}');
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      Translations.getText(context, 'galleryNoImages'),
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      Translations.getText(context, 'galleryNoImages'),
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                var languageProvider = Provider.of<LanguageProvider>(context);
                List<Map<String, String>> galleryItems = snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return {
                    'title': languageProvider.languageCode == 'ar'
                        ? (data['title_ar'] as String? ?? Translations.getText(context, 'notAvailable'))
                        : (data['title_en'] as String? ?? Translations.getText(context, 'notAvailable')),
                    'url': (data['url'] as String? ?? ''),
                  };
                }).toList();

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: galleryItems.length,
                  itemBuilder: (context, index) {
                    String title = galleryItems[index]['title'] ?? Translations.getText(context, 'notAvailable');
                    String url = galleryItems[index]['url'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        _openImageGallery(context, index, galleryItems);
                      },
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: url.isNotEmpty
                                  ? Image.network(
                                url,
                                fit: BoxFit.cover,
                                width: imageSize,
                                height: imageSize,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading gallery image: $url, Error: $error');
                                  return Container(
                                    color: Colors.grey,
                                    child: Center(child: Text(Translations.getText(context, 'galleryImageLoadError'))),
                                  );
                                },
                              )
                                  : Container(
                                color: Colors.grey,
                                child: Center(child: Text(Translations.getText(context, 'galleryImageLoadError'))),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            title,
                            style: TextStyle(fontSize: 12, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryPhotoViewWrapper extends StatelessWidget {
  final List<Map<String, String>> galleryItems;
  final int initialIndex;

  const GalleryPhotoViewWrapper({
    required this.galleryItems,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    String title = galleryItems[initialIndex]['title'] ?? Translations.getText(context, 'notAvailable');
    String url = galleryItems[initialIndex]['url'] ?? '';

    return Scaffold(
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            itemCount: galleryItems.length,
            builder: (context, index) {
              String itemUrl = galleryItems[index]['url'] ?? '';
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(itemUrl),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: itemUrl),
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        Translations.getText(context, 'galleryImageLoadError'),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              );
            },
            pageController: PageController(initialPage: initialIndex),
            backgroundDecoration: BoxDecoration(color: Colors.black),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}