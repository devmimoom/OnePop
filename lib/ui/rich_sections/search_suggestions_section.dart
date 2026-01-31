import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/v2_providers.dart';

class SearchSuggestionsSection extends ConsumerWidget {
  final void Function(String) onTap;
  const SearchSuggestionsSection({super.key, required this.onTap});

  static const _fallbackSuggested = [
    'flutter UI design',
    'flashcards app',
    'notification habits',
  ];
  static const _fallbackTrending = [
    'AI',
    'Space',
    'Aesthetics',
    'Health',
    'Finance',
    'Mindset',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(searchSuggestionsProvider);

    return async.when(
      data: (data) => _buildContent(
        suggested: data.suggested,
        trending: data.trending,
      ),
      loading: () => _buildContent(
        suggested: _fallbackSuggested,
        trending: _fallbackTrending,
      ),
      error: (_, __) => _buildContent(
        suggested: _fallbackSuggested,
        trending: _fallbackTrending,
      ),
    );
  }

  Widget _buildContent({
    required List<String> suggested,
    required List<String> trending,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Suggested', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        ...suggested.map((e) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(e),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onTap(e),
            )),
        const SizedBox(height: 10),
        const Text('Trending', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: trending
              .map((t) => ActionChip(
                    label: Text(t),
                    onPressed: () => onTap(t),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
