import 'package:flutter/material.dart';
import 'package:sam_gig/core/config/app_config.dart';
import 'package:sam_gig/core/utils/formatters.dart';



class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key, required this.selected, required this.onSelected});

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConfig.categories.length + 1, 
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final String? category = index == 0 ? null : AppConfig.categories[index - 1];
          return ChoiceChip(
            label: Text(category == null ? 'All' : capitalize(category)),
            selected: selected == category,
            onSelected: (_) => onSelected(category),
          );
        },
      ),
    );
  }
}