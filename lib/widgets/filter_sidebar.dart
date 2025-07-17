import 'package:flutter/material.dart';

class FilterSidebar extends StatelessWidget {
  final String selectedCategory;
  final String selectedGender;
  final Function(String) onCategoryChanged;
  final Function(String) onGenderChanged;

  const FilterSidebar({
    required this.selectedCategory,
    required this.selectedGender,
    required this.onCategoryChanged,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التصنيفات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildCategoryList(),
            SizedBox(height: 24),
            Text(
              'النوع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildGenderList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    final categories = ['الكل', 'سكريات', 'فيتامينات', 'مكملات غذائية'];
    return Column(
      children: categories.map((category) {
        return _buildFilterOption(
          text: category,
          isSelected: selectedCategory == category,
          onTap: () => onCategoryChanged(category),
        );
      }).toList(),
    );
  }

  Widget _buildGenderList() {
    final genders = ['الكل', 'رجال', 'نساء', 'أطفال'];
    return Column(
      children: genders.map((gender) {
        return _buildFilterOption(
          text: gender,
          isSelected: selectedGender == gender,
          onTap: () => onGenderChanged(gender),
        );
      }).toList(),
    );
  }

  Widget _buildFilterOption({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0288D1).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (isSelected)
              Icon(
                Icons.check,
                size: 20,
                color: Color(0xFF0288D1),
              ),
            SizedBox(width: isSelected ? 8 : 0),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Color(0xFF0288D1) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}