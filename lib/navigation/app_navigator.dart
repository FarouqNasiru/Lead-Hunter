import 'package:flutter/material.dart';
import '../screens/search/search_screen.dart';
import '../screens/results/results_screen.dart';
import '../models/lead.dart';

/// Top-level navigator for the main app (post-auth).
/// Handles the Search → Results flow.
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  SearchFilters? _activeFilters;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: _activeFilters == null
          ? SearchScreen(
              key: const ValueKey('search'),
              onSearch: (filters) => setState(() => _activeFilters = filters),
            )
          : ResultsScreen(
              key: ValueKey('results_${_activeFilters.hashCode}'),
              filters: _activeFilters!,
              onBack: () => setState(() => _activeFilters = null),
            ),
    );
  }
}
