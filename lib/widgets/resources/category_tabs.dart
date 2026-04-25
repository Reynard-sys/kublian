import 'package:flutter/material.dart';
import 'package:kublian/widgets/resources/resources_header.dart';

enum ResourcesCategory { exercises, hotlines, nearby }

class CategoryTabs extends StatelessWidget {
  final ResourcesCategory selected;
  final ValueChanged<ResourcesCategory> onChanged;

  const CategoryTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _tabs = [
    (
      category: ResourcesCategory.exercises,
      icon: Icons.self_improvement,
      label: 'Exercises and\nTechniques'
    ),
    (
      category: ResourcesCategory.hotlines,
      icon: Icons.phone_in_talk_outlined,
      label: 'LGU\nHotlines'
    ),
    (
      category: ResourcesCategory.nearby,
      icon: Icons.local_hospital_outlined,
      label: 'Nearby\nSupport'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kResBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tabs.map((tab) {
            final isSelected = selected == tab.category;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => onChanged(tab.category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? kResPrimary : kResSurface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.2)
                              : kResChipBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(tab.icon,
                            size: 20,
                            color: isSelected ? Colors.white : kResPrimary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        tab.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : kResTextDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
