import 'package:flutter/material.dart';
import 'package:kublian/widgets/resources/resources_header.dart';
import 'package:kublian/widgets/resources/category_tabs.dart';
import 'package:kublian/widgets/resources/exercises_tab.dart';
import 'package:kublian/widgets/resources/hotlines_tab.dart';
import 'package:kublian/widgets/resources/nearby_tab.dart';

/// Resources screen — bottom nav label: "Library"
/// Entry point for the Resources feature.
/// All widgets live in package:kublian/widgets/resources/
class ResourcesScreen extends StatefulWidget {
  /// User's stored city from profile — passed to NearbyTab for map label.
  final String userCity;
  const ResourcesScreen({super.key, this.userCity = 'Metro Manila'});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  ResourcesCategory _category = ResourcesCategory.exercises;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kResBg,
      body: Column(
        children: [
          const ResourcesHeader(),
          CategoryTabs(
            selected: _category,
            onChanged: (c) => setState(() => _category = c),
          ),
          Container(height: 1, color: kResDivider),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: _buildTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab() {
    switch (_category) {
      case ResourcesCategory.exercises:
        return const ExercisesTab(key: ValueKey('exercises'));
      case ResourcesCategory.hotlines:
        return const HotlinesTab(key: ValueKey('hotlines'));
      case ResourcesCategory.nearby:
        return NearbyTab(
            key: const ValueKey('nearby'), city: widget.userCity);
    }
  }
}
