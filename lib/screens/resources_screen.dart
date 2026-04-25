import 'package:flutter/material.dart';
import 'package:kublian/widgets/resources/resources_header.dart';
import 'package:kublian/widgets/resources/category_tabs.dart';
import 'package:kublian/widgets/resources/exercises_tab.dart';
import 'package:kublian/widgets/resources/hotlines_tab.dart';
import 'package:kublian/widgets/resources/nearby_tab.dart';
import 'package:kublian/widgets/resources/nearby_support_tab.dart';

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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    'Pahinga Muna.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Newsreader',
                        color: kResTextDark,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        height: 1.2),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "This is your safe space. Let us know how you're feeling so we "
                      "can find the right companion for your heart.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          color: kResTextMid, fontSize: 13.5, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CategoryTabs(
                    selected: _category,
                    onChanged: (c) => setState(() => _category = c),
                  ),
                  const SizedBox(height: 24),
                  // Removed the fixed height constraints so the tab content can determine its height
                  // We'll wrap the Tab content in a Container with fixed height or let it expand.
                  // Since we are in a SingleChildScrollView, the tab content needs a defined height or should be flexible inside.
                  // ExercisesTab will have its own height.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    child: _buildTab(),
                  ),
                ],
              ),
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
      case ResourcesCategory.facilities:
        return NearbyTab(
            key: const ValueKey('facilities'), city: widget.userCity);
      case ResourcesCategory.support:
        return NearbySupportTab(
            key: const ValueKey('support'), city: widget.userCity);
    }
  }
}
