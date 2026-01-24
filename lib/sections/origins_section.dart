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
        vertical: isMobile ? 80 : 120,
        horizontal: isMobile ? 24 : 48,
      ),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Section Header - Modern Minimalist
              Column(
                children: [
                  Text(
                    Translations.getText(context, 'originsSectionTitle'),
                    style: TextStyle(
                      fontSize: isMobile ? 32 : isTablet ? 40 : 48,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 48,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Color(0xFF0066CC),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),

              SizedBox(height: isMobile ? 56 : 80),

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
      padding: EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Color(0xFF0066CC).withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.handshake_outlined,
              size: 48,
              color: Color(0xFF0066CC),
            ),
          ),
          SizedBox(height: 24),
          Text(
            Translations.getText(context, 'originsNoData'),
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid(bool isMobile, bool isTablet) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: List.generate(5, (index) {
        return Shimmer.fromColors(
          baseColor: Color(0xFFF3F4F6),
          highlightColor: Colors.white,
          child: Container(
            width: isMobile ? double.infinity : 260,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: EdgeInsets.all(36),
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Color(0xFF0066CC).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    Icons.handshake_outlined,
                    size: 40,
                    color: Color(0xFF0066CC),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  partnerName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  Translations.getText(
                    context,
                    'brandInfoComingSoon',
                    params: {'brandName': partnerName},
                  ),
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    Translations.getText(context, 'close'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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
              width: widget.isMobile ? double.infinity : 260,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
                    blurRadius: _isHovered ? 32 : 24,
                    offset: Offset(0, _isHovered ? 12 : 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => _showPartnerInfo(context, name),
                  child: Padding(
                    padding: EdgeInsets.all(24),
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
                                baseColor: Color(0xFFF3F4F6),
                                highlightColor: Colors.white,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.business,
                                size: 40,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.business,
                            size: 40,
                            color: Color(0xFF9CA3AF),
                          ),
                        SizedBox(height: 16),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
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