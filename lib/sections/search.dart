// pages/search_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';
import 'product_details.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Item> searchResults = [];
  bool isLoading = false;

  // Popular searches
  final List<String> popularSearches = [
    'طبي',
    'جهاز',
    'قياس',
    'ضغط',
    'سكر',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus on search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Search using nameParts array
      final queryWords = query.toLowerCase().split(' ');

      final snapshot = await _firestore
          .collection('items1')
          .where('namePartsLower', arrayContainsAny: queryWords)
          .limit(20)
          .get();

      setState(() {
        searchResults = snapshot.docs
            .map((doc) => Item.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id))
            .where((item) => item.number > 0) // Only show items in stock
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Search error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isMobile = screenWidth < 600;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Search Header
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    // Close Button
                    IconButton(
                      icon: Icon(Icons.close, size: 28),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                    SizedBox(width: 16),
                    // Search Field
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن منتج...',
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 18,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: _performSearch,
                      ),
                    ),
                    // Clear Button
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            searchResults = [];
                          });
                        },
                      ),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: _buildContent(isDesktop, isMobile),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDesktop, bool isMobile) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_searchController.text.isEmpty) {
      return _buildEmptyState(isMobile);
    }

    if (searchResults.isEmpty) {
      return _buildNoResultsState();
    }

    return _buildSearchResults(isDesktop, isMobile);
  }

  Widget _buildEmptyState(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عمليات البحث الشائعة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: popularSearches.map((search) {
              return InkWell(
                onTap: () {
                  _searchController.text = search;
                  _performSearch(search);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    search,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[300],
            ),
            SizedBox(height: 24),
            Text(
              'لم نتمكن من العثور على نتائج',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'جرب البحث بكلمات مختلفة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(bool isDesktop, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Count
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Text(
            '${searchResults.length} نتيجة',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),

        // Results Grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 24,
              vertical: 8,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : (isMobile ? 2 : 3),
              childAspectRatio: 0.65,
              crossAxisSpacing: isMobile ? 12 : 20,
              mainAxisSpacing: isMobile ? 16 : 24,
            ),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final item = searchResults[index];
              return _buildProductCard(item, isMobile);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Item item, bool isMobile) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailsPage(
              item: item,
              onAddToCart: (_, __) {}, // Handle in the details page
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.thumbnail != null && item.thumbnail!.isNotEmpty
                    ? Image.network(
                  item.thumbnail!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                )
                    : Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          // Product Name
          Text(
            item.name,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          // Price
          Text(
            item.formattedPrice,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}