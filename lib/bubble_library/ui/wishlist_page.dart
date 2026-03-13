import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collections/wishlist_provider.dart';
import '../providers/providers.dart';
import '../models/product.dart';
import '../models/user_library.dart';
import '../../localization/app_language_provider.dart';
import '../../localization/app_strings.dart';
import 'product_library_page.dart';
import '../../theme/app_spacing.dart';
import '../../pages/product_page.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final productsAsync = ref.watch(productsMapProvider);
    final wishlistAsync = ref.watch(localWishlistProvider);
    final libraryAsync = ref.watch(libraryProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(uiString(lang, 'bookmarked_title')),
        actions: [
          IconButton(
            tooltip: uiString(lang, 'refresh'),
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(localWishlistNotifierProvider).refresh(),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (productsMap) {
          return libraryAsync.when(
            data: (libraryProducts) {
              final purchasedProductIds = libraryProducts
                  .where((lp) => !lp.isHidden)
                  .map((lp) => lp.productId)
                  .toSet();

              return wishlistAsync.when(
                data: (wishItems) {
                  final list = wishItems
                      .map((w) => {
                        'item': w,
                        'product': productsMap[w.productId],
                      })
                      .toList()
                    ..sort((a, b) => (b['item'] as WishlistItem).addedAt
                        .compareTo((a['item'] as WishlistItem).addedAt));

              if (list.isEmpty) {
                return Center(child: Text(uiString(lang, 'wishlist_empty')));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.sm),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, i) {
                  final w = list[i]['item'] as WishlistItem;
                  final p = list[i]['product'] as Product?;
                  final pid = w.productId;
                  final title = p?.displayTitle(lang) ?? pid;
                  final subtitle = p?.displayLevelGoal(lang) ?? '';
                  final isPurchased = purchasedProductIds.contains(pid);

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.w900)),
                              ),
                              if (isPurchased)
                                Padding(
                                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 20,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              IconButton(
                                tooltip: uiString(lang, 'favorite'),
                                icon: Icon(w.isFavorite
                                    ? Icons.star
                                    : Icons.star_border),
                                onPressed: () => ref
                                    .read(localWishlistNotifierProvider)
                                    .toggleFavorite(pid),
                              ),
                            ],
                          ),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xs),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (isPurchased)
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.menu_book, size: 16),
                                  label: Text(uiString(lang, 'open_library')),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProductLibraryPage(
                                          productId: pid,
                                          isWishlistPreview: false,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              else if (p != null) ...[
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.visibility),
                                  label: Text(uiString(lang, 'preview')),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProductLibraryPage(
                                          productId: pid,
                                          isWishlistPreview: true,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.shopping_bag_outlined),
                                  label: Text(uiString(lang, 'buy')),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ProductPage(productId: pid),
                                      ),
                                    );
                                  },
                                ),
                              ],
                              IconButton(
                                tooltip: uiString(lang, 'remove_from_wishlist'),
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => ref
                                    .read(localWishlistNotifierProvider)
                                    .remove(pid),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('${uiString(lang, 'wishlist_error')}$e')),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                uiString(lang, 'library_load_error'),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            uiString(lang, 'wishlist_load_error'),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
