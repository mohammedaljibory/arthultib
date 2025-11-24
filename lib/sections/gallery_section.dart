import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../translations.dart';
import '../language_provider.dart';
import 'package:provider/provider.dart';

class GallerySection extends StatefulWidget {
  @override
  _GallerySectionState createState() => _GallerySectionState();
}

class _GallerySectionState extends State<GallerySection> with AutomaticKeepAliveClientMixin {
  // Keep the widget alive in memory to prevent rebuilds
  @override
  bool get wantKeepAlive => true;

  // Cache the gallery items
  List<Map<String, String>>? _cachedGalleryItems;

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
    super.build(context);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;
    bool isTablet = screenWidth >= 600 && screenWidth < 900;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: isMobile ? 20 : 40,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Section Header
              Column(
                children: [
                  Text(
                    Translations.getText(context, 'gallerySectionTitle'),
                    style: TextStyle(
                      fontSize: isMobile ? 28 : isTablet ? 36 : 42,
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF004080),
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 80,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFF0288D1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 40 : 60),

              // Optimized Gallery Grid
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('gallery')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerGrid(isMobile, isTablet);
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  var languageProvider = Provider.of<LanguageProvider>(context);

                  // Cache gallery items to prevent recreation
                  if (_cachedGalleryItems == null || snapshot.data!.docChanges.isNotEmpty) {
                    _cachedGalleryItems = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return {
                        'title': languageProvider.languageCode == 'ar'
                            ? (data['title_ar'] as String? ?? '')
                            : (data['title_en'] as String? ?? ''),
                        'url': (data['url'] as String? ?? ''),
                      };
                    }).toList();
                  }

                  int crossAxisCount = isMobile ? 2 : isTablet ? 3 : 4;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1,
                    ),
                    itemCount: _cachedGalleryItems!.length,
                    // Add cacheExtent for smoother scrolling
                    cacheExtent: 500,
                    itemBuilder: (context, index) {
                      return OptimizedGalleryItem(
                        index: index,
                        galleryItems: _cachedGalleryItems!,
                        onTap: () => _openImageGallery(context, index, _cachedGalleryItems!),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            Translations.getText(context, 'galleryNoImages'),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid(bool isMobile, bool isTablet) {
    int crossAxisCount = isMobile ? 2 : isTablet ? 3 : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      },
    );
  }
}

// Separate stateful widget for each gallery item to prevent unnecessary rebuilds
class OptimizedGalleryItem extends StatefulWidget {
  final int index;
  final List<Map<String, String>> galleryItems;
  final VoidCallback onTap;

  const OptimizedGalleryItem({
    Key? key,
    required this.index,
    required this.galleryItems,
    required this.onTap,
  }) : super(key: key);

  @override
  _OptimizedGalleryItemState createState() => _OptimizedGalleryItemState();
}

class _OptimizedGalleryItemState extends State<OptimizedGalleryItem>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    String title = widget.galleryItems[widget.index]['title'] ?? '';
    String url = widget.galleryItems[widget.index]['url'] ?? '';

    return GestureDetector(
      onTap: widget.onTap,
      child: Hero(
        tag: 'gallery_image_${widget.index}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 5,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Use CachedNetworkImage for better performance
                if (url.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    memCacheWidth: 400, // Optimize memory usage
                    memCacheHeight: 400,
                    fadeInDuration: Duration(milliseconds: 200),
                    fadeOutDuration: Duration(milliseconds: 200),
                    placeholder: (context, url) => Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF0288D1),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                      stops: [0.6, 1.0],
                    ),
                  ),
                ),

                // Title
                if (title.isNotEmpty)
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                // Hover effect with Material ripple
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: widget.onTap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Optimized Photo Viewer
class GalleryPhotoViewWrapper extends StatelessWidget {
  final List<Map<String, String>> galleryItems;
  final int initialIndex;

  const GalleryPhotoViewWrapper({
    required this.galleryItems,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: initialIndex);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            itemCount: galleryItems.length,
            pageController: pageController,
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(
                value: event == null
                    ? null
                    : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                color: Colors.white,
              ),
            ),
            builder: (context, index) {
              String itemUrl = galleryItems[index]['url'] ?? '';
              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(itemUrl),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
                heroAttributes: PhotoViewHeroAttributes(tag: 'gallery_image_$index'),
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
            backgroundDecoration: BoxDecoration(color: Colors.black),
          ),

          // Close button
          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(Icons.close, color: Colors.white, size: 24),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // Title display at bottom
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ValueListenableBuilder<double?>(
                valueListenable: pageController.hasClients
                    ? ValueNotifier(pageController.page)
                    : ValueNotifier(initialIndex.toDouble()),
                builder: (context, currentPage, child) {
                  int index = (currentPage ?? initialIndex).round();
                  return Text(
                    galleryItems[index]['title'] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
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