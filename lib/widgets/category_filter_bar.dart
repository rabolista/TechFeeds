import 'package:flutter/material.dart';

import '../models/story_category.dart';
import '../theme/category_style.dart';

/// Horizontal scrolling row of category filter chips, styled the same way
/// as Global Climate News's category filter bar.
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
  });

  final StoryCategory selectedCategory;
  final ValueChanged<StoryCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: StoryCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = StoryCategory.values[index];
          final selected = category == selectedCategory;
          final color = CategoryStyle.colorFor(category);
          return ChoiceChip(
            selected: selected,
            onSelected: (_) => onSelected(category),
            avatar: Icon(
              CategoryStyle.iconFor(category),
              size: 18,
              color: selected ? color : null,
            ),
            label: Text(category.label),
            selectedColor: color.withValues(alpha: 0.18),
            side: selected
                ? BorderSide(color: color)
                : BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          );
        },
      ),
    );
  }
}
