import 'package:flutter/material.dart';

import '../core/app_constants.dart';
import '../core/app_theme.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.categories.length,
        itemBuilder: (context, index) {
          final category = AppConstants.categories[index];
          final isSelected = category == selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: FilterChip(
                selected: isSelected,
                showCheckmark: false,
                label: Text(
                  _capitalize(category),
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isDark
                            ? Colors.white70
                            : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
                backgroundColor:
                    isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                selectedColor: AppTheme.primaryColor,
                elevation: isSelected ? 4 : 0,
                shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.transparent,
                  width: 1.5,
                ),
                onSelected: (_) => onCategorySelected(category),
              ),
            ),
          );
        },
      ),
    );
  }

  String _capitalize(String s) =>
      s[0].toUpperCase() + s.substring(1);
}
