import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../core/app_theme.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.categories.length,
        itemBuilder: (context, index) {
          final category = AppConstants.categories[index];
          final selected = category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: selected,
              showCheckmark: false,
              label: Text(
                category[0].toUpperCase() + category.substring(1),
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : isDark
                          ? Colors.white70
                          : Colors.black87,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                ),
              ),
              backgroundColor:
                  isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              selectedColor: AppTheme.primaryColor,
              elevation: selected ? 2 : 0,
              side: BorderSide(
                color: selected ? AppTheme.primaryColor : Colors.transparent,
              ),
              onSelected: (_) => onCategorySelected(category),
            ),
          );
        },
      ),
    );
  }
}
