import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../translations.dart';
import '../language_provider.dart';
import 'package:provider/provider.dart';

class OriginsSection extends StatefulWidget {
  @override
  _OriginsSectionState createState() => _OriginsSectionState();
}

class _OriginsSectionState extends State<OriginsSection>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  // Cache the brands data
  List<Map<String, String>>? _cachedBrands;

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
                    Translations.getText(context, 'originsSectionTitle'),
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

              // Partners/Brands Grid with optimization
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerGrid(isMobile, isTablet);
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  var languageProvider = Provider.of<LanguageProvider>(context);

                  // Cache brands data to prevent recreation
                  if (_cachedBrands == null || snapshot.data!.docChanges.isNotEmpty) {
                    _cachedBrands = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return {
                        'name': languageProvider.languageCode == 'ar'
                            ? (data['title_ar'] as String? ?? '')
                            : (data['title_en'] as String? ?? ''),
                        'image': (data['url'] as String? ?? ''),
                      };
                    }).toList();
                  }

                  if (isMobile) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _cachedBrands!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: OptimizedPartnerCard(
                            brand: _cachedBrands![index],
                            isMobile: isMobile,
                          ),
                        );
                      },
                    );
                  } else {
                    return Wrap(
                      spacing: 30,
                      runSpacing: 30,
                      alignment: WrapAlignment.center,
                      children: _cachedBrands!.map((brand) {
                        return OptimizedPartnerCard(
                          brand: brand,
                          isMobile: isMobile,
                        );
                      }).toList(),
                    );
                  }
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
            Icons.handshake_outlined,
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            Translations.getText(context, 'originsNoData'),
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
    return Wrap(
      spacing: 30,
      runSpacing: 30,
      alignment: WrapAlignment.center,
      children: List.generate(5, (index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: isMobile ? double.infinity : 250,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        );
      }),
    );
  }
}

// Optimized Partner Card Widget
class OptimizedPartnerCard extends StatefulWidget {
  final Map<String, String> brand;
  final bool isMobile;

  const OptimizedPartnerCard({
    Key? key,
    required this.brand,
    required this.isMobile,
  }) : super(key: key);

  @override
  _OptimizedPartnerCardState createState() => _OptimizedPartnerCardState();
}

class _OptimizedPartnerCardState extends State<OptimizedPartnerCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showPartnerInfo(BuildContext context, String partnerName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(30),
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.handshake_outlined,
                  size: 48,
                  color: Color(0xFF004080),
                ),
                SizedBox(height: 20),
                Text(
                  partnerName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF004080),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  Translations.getText(
                    context,
                    'brandInfoComingSoon',
                    params: {'brandName': partnerName},
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF004080),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    Translations.getText(context, 'close'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    String name = widget.brand['name'] ?? '';
    String image = widget.brand['image'] ?? '';

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.isMobile ? double.infinity : 250,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(_isHovered ? 0.2 : 0.1),
                    blurRadius: _isHovered ? 10 : 5,
                    offset: Offset(0, _isHovered ? 4 : 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () => _showPartnerInfo(context, name),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (image.isNotEmpty)
                          Expanded(
                            child: CachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.contain,
                              memCacheWidth: 300, // Optimize memory
                              memCacheHeight: 150,
                              fadeInDuration: Duration(milliseconds: 200),
                              fadeOutDuration: Duration(milliseconds: 200),
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.business,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.business,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        SizedBox(height: 15),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF004080),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}