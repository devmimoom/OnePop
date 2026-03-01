import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'category_page.dart';

/// Full-page Explore tab: header, segment chips, topic grid, Netflix rails.
class ExplorePage extends ConsumerWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: const [
          ExploreSection(),
        ],
      ),
    );
  }
}
