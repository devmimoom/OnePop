import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/home_page.dart';
import 'pages/category_page.dart';
import 'pages/search_page.dart';
import 'pages/me_page.dart';
import 'bubble_library/ui/bubble_library_page.dart';
import 'widgets/app_background.dart';
import 'theme/theme_controller.dart';
import 'theme/app_tokens.dart';
import 'providers/nav_providers.dart';
import 'providers/analytics_provider.dart';
import 'notifications/notification_bootstrapper.dart';

final themeControllerProvider = Provider<ThemeController>((ref) {
  throw UnimplementedError('themeControllerProvider must be overridden');
});

class MainScaffold4Tabs extends ConsumerWidget {
  final ThemeController themeController;
  const MainScaffold4Tabs({super.key, required this.themeController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(bottomTabIndexProvider);
    final tokens = context.tokens;

    return ProviderScope(
      overrides: [
        themeControllerProvider.overrideWithValue(themeController),
      ],
      child: NotificationBootstrapper(
        child: AppBackground(
          child: Scaffold(
          backgroundColor: Colors.transparent,
          body: IndexedStack(
            index: index,
            children: const [
              HomePage(),
              CategoryPage(),
              SearchPage(),
              BubbleLibraryPage(),
              MePage(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              gradient: tokens.navGradient,
              color: tokens.navGradient == null ? tokens.navBg : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: index,
              onDestinationSelected: (i) {
                ref.read(bottomTabIndexProvider.notifier).state = i;
                final names = ['home', 'category', 'search', 'library', 'me'];
                if (i >= 0 && i < names.length) {
                  ref.read(analyticsProvider).logScreenView(screenName: names[i]);
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              indicatorColor: tokens.primary.withValues(alpha: 0.2),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: tokens.textSecondary),
                  selectedIcon: Icon(Icons.home, color: tokens.primary),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined,
                      color: tokens.textSecondary),
                  selectedIcon: Icon(Icons.grid_view, color: tokens.primary),
                  label: 'Categories',
                ),
                NavigationDestination(
                  icon:
                      Icon(Icons.search_outlined, color: tokens.textSecondary),
                  selectedIcon: Icon(Icons.search, color: tokens.primary),
                  label: 'Search',
                ),
                NavigationDestination(
                  icon: Icon(Icons.library_books_outlined,
                      color: tokens.textSecondary),
                  selectedIcon:
                      Icon(Icons.library_books, color: tokens.primary),
                  label: 'Library',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline, color: tokens.textSecondary),
                  selectedIcon: Icon(Icons.person, color: tokens.primary),
                  label: 'Me',
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
