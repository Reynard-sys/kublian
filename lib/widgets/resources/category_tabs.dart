import 'package:flutter/material.dart';
import 'package:kublian/widgets/resources/resources_header.dart';

enum ResourcesCategory { exercises, hotlines, facilities, support }

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
      category: ResourcesCategory.support,
      icon: Icons.health_and_safety_outlined,
      label: 'Professional\nHotlines'
    ),
    (
      category: ResourcesCategory.facilities,
      icon: Icons.local_hospital_outlined,
      label: 'Nearby\nFacilities'
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
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => onChanged(tab.category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 152,
                  height: 142,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF006B5F) : kResSurface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFB5EDE7)
                              : kResChipBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(tab.icon,
                            size: 24,
                            color: isSelected ? const Color(0xFF006B5F) : const Color(0xFF904A3D)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tab.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : kResTextDark,
                          fontSize: 14,
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
