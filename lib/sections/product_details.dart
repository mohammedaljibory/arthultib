import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import '../models/item.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class ItemDetailsPage extends StatefulWidget {
  final Item item;
  final Function(Item, int) onAddToCart;

  const ItemDetailsPage({
    Key? key,
    required this.item,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  int _quantity = 1;
  bool _isFavorite = false;
  List<Item> _relatedProducts = [];
  final PageController _imageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
    _loadRelatedProducts();
  }

  void _checkIfFavorite() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      setState(() {
        _isFavorite = authProvider.isFavorite(widget.item.id);
      });
    }
  }

  Future<void> _loadRelatedProducts() async {
    try {
      final keywords = widget.item.name.toLowerCase().split(' ')
          .where((word) => word.length > 2).take(2).toList();

      if (keywords.isEmpty) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('items1')
          .where('namePartsLower', arrayContainsAny: keywords)
          .limit(5)
          .get();

      setState(() {
        _relatedProducts = snapshot.docs
            .map((doc) => Item.fromFirestore(doc.data(), doc.id))
            .where((item) => item.id != widget.item.id && item.number > 0)
            .take(4)
            .toList();
      });
    } catch (e) {
      print('Error loading related: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1024;
    final authProvider = Provider.of<AuthProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  // DESKTOP LAYOUT
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left: Image Gallery
        Expanded(
          flex: 5,
          child: _buildImageSection(true),
        ),
        // Right: Product Info
        Expanded(
          flex: 4,
          child: _buildInfoSection(true),
        ),
      ],
    );
  }

  // MOBILE LAYOUT
  Widget _buildMobileLayout() {
    return CustomScrollView(
      slivers: [
        // Image Section
        SliverToBoxAdapter(
          child: _buildImageSection(false),
        ),
        // Info Section
        SliverToBoxAdapter(
          child: _buildInfoSection(false),
        ),
      ],
    );
  }

  // IMAGE SECTION
  Widget _buildImageSection(bool isDesktop) {
    final images = [widget.item.thumbnail, widget.item.thumbnail, widget.item.thumbnail]
        .where((img) => img != null).toList();

    if (images.isEmpty) images.add(null);

    return Container(
      height: isDesktop ? MediaQuery.of(context).size.height : 450,
      color: Colors.grey[50],
      child: Stack(
        children: [
          // Main Image Viewer
          PageView.builder(
            controller: _imageController,
            onPageChanged: (index) => setState(() => _currentImageIndex = index),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(isDesktop ? 60 : 20),
                child: images[index] != null
                    ? Image.network(
                  images[index]!,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                )
                    : _buildImagePlaceholder(),
              );
            },
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Image Dots
          if (images.length > 1)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) =>
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: _currentImageIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentImageIndex == index ? Colors.black : Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ),
              ),
            ),

          // Thumbnail Strip (Desktop)
          if (isDesktop && images.length > 1)
            Positioned(
              bottom: 40,
              left: 40,
              child: Row(
                children: images.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _imageController.animateToPage(
                      entry.key,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    child: Container(
                      margin: EdgeInsets.only(right: 10),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentImageIndex == entry.key
                              ? Colors.black : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Image.network(
                        entry.value ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // INFO SECTION
  Widget _buildInfoSection(bool isDesktop) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      padding: EdgeInsets.all(isDesktop ? 60 : 24),
        child: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'طبي',
              style: TextStyle(color: Colors.white, fontSize: 12, letterSpacing: 1),
            ),
          ),
          SizedBox(height: 20),

          // Product Name
          Text(
            widget.item.name,
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
          SizedBox(height: 20),

          // Price
          Text(
            widget.item.formattedPrice,
            style: TextStyle(
              fontSize: isDesktop ? 32 : 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),

          // Stock Status
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: widget.item.inStock ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                widget.item.inStock
                    ? 'متوفر (${widget.item.number} قطعة)'
                    : 'غير متوفر',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.item.inStock ? Colors.green[700] : Colors.red[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 40),

          // Quantity Selector
          if (widget.item.inStock) ...[
            Text('الكمية', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.remove, size: 20),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Container(
                    constraints: BoxConstraints(minWidth: 60),
                    alignment: Alignment.center,
                    child: Text(
                      '$_quantity',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, size: 20),
                    onPressed: _quantity < widget.item.number
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.item.inStock ? () => _handleAddToCart() : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(

                    widget.item.inStock ? 'إضافة للسلة' : 'غير متوفر',
                    style: TextStyle(fontSize: 16, letterSpacing: 0.5),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.grey[600],
                  ),
                  onPressed: () => _toggleFavorite(),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),

          // Description
          Text(
            'الوصف',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12),
          Text(
            'منتج طبي عالي الجودة يلبي أعلى معايير السلامة والأمان. '
                'مصمم للاستخدام في المستشفيات والعيادات الطبية.',
            style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey[700]),
          ),

          // Related Products
          if (_relatedProducts.isNotEmpty) ...[
            SizedBox(height: 50),
            Text(
              'منتجات ذات صلة',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Container(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _relatedProducts.length,
                itemBuilder: (context, index) => _buildRelatedCard(_relatedProducts[index]),
              ),
            ),
          ],
        ],
      ), )
    );
  }

  Widget _buildRelatedCard(Item item) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ItemDetailsPage(item: item, onAddToCart: widget.onAddToCart),
        ),
      ),
      child: Container(
        width: 100,
        margin: EdgeInsets.only(left: 12),
        child: Column(
          children: [
            Container(
              height: 80,
              width: 80,
              color: Colors.grey[100],
              child: item.thumbnail != null
                  ? Image.network(item.thumbnail!, fit: BoxFit.cover)
                  : Icon(Icons.image_outlined, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              item.name,
              style: TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Icon(Icons.image_outlined, size: 80, color: Colors.grey[400]),
    );
  }

  void _handleAddToCart() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      _showAuthDialog();
    } else {
      // Store the quantity being added before resetting
      final quantityToAdd = _quantity;

      // Add item to cart
      cartProvider.addToCart(widget.item, quantity: quantityToAdd);

      // Show success dialog with the quantity that was added
      _showSuccessDialog(quantityToAdd);

      // Reset quantity for next addition
      setState(() {
        _quantity = 1;
      });
    }
  }
  void _toggleFavorite() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      _showAuthDialog();
    } else {
      setState(() => _isFavorite = !_isFavorite);
      if (_isFavorite) {
        authProvider.addToFavorites(widget.item.id);
      } else {
        authProvider.removeFromFavorites(widget.item.id);
      }
    }
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: Container(
          padding: EdgeInsets.all(32),
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تسجيل الدخول مطلوب',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              Text(
                'يجب عليك تسجيل الدخول للمتابعة',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pushNamed('/sign-up');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('إنشاء حساب'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pushNamed('/sign-in');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('تسجيل الدخول'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(int addedQuantity) {
    showDialog(
      context: context,
      barrierDismissible: true,  // Allow closing by tapping outside
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          padding: EdgeInsets.all(24),
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green, size: 48),
              ),
              SizedBox(height: 16),
              Text(
                'تمت الإضافة بنجاح',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                '${widget.item.name}',
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                'الكمية المضافة: $addedQuantity',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Text(
                'إجمالي في السلة: ${Provider.of<CartProvider>(context, listen: false).getItemQuantity(widget.item.id)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('متابعة التسوق'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/cart');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: Text('عرض السلة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}