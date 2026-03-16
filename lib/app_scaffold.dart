import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/home_page.dart';
import 'pages/explore_page.dart';
import 'pages/me_page.dart';
import 'pages/plus_guide/plus_guide_page.dart';
import 'widgets/app_background.dart';
import 'theme/theme_controller.dart';
import 'theme/app_spacing.dart';
import 'theme/app_tokens.dart';
import 'providers/nav_providers.dart';
import 'providers/analytics_provider.dart';
import 'notifications/notification_bootstrapper.dart';
import 'localization/app_language_provider.dart';
import 'localization/app_strings.dart';
import 'widgets/floating_coffee_hint.dart';

final themeControllerProvider = Provider<ThemeController>((ref) {
  throw UnimplementedError('themeControllerProvider must be overridden');
});

const _stackScreenNames = ['home', 'plus', 'explore', 'me'];
const _coffeeSize = 180.0;
const _coffeeMargin = 0.0;
const _coffeeEdgeOverflow = 72.0;

class MainScaffold4Tabs extends ConsumerStatefulWidget {
  final ThemeController themeController;
  const MainScaffold4Tabs({super.key, required this.themeController});

  @override
  ConsumerState<MainScaffold4Tabs> createState() => _MainScaffold4TabsState();
}

class _MainScaffold4TabsState extends ConsumerState<MainScaffold4Tabs> {
  double? _coffeeLeft;
  double? _coffeeTop;
  bool _showCoffeeHint = false;
  int _coffeeHintStep = 0;

  @override
  Widget build(BuildContext context) {
    final stackIndex = ref.watch(bottomTabIndexProvider);
    final tokens = context.tokens;
    final lang = ref.watch(appLanguageProvider);
    final homeLabel = uiString(lang, 'home');
    final exploreLabel = uiString(lang, 'explore');
    final meLabel = uiString(lang, 'me');

    return NotificationBootstrapper(
      child: AppBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final mediaQuery = MediaQuery.of(context);
            final size = mediaQuery.size;
            final bottomInset =
                mediaQuery.padding.bottom + AppSpacing.navItemHeight + 24;
            final minLeft = -_coffeeEdgeOverflow;
            final maxLeft = size.width - _coffeeSize + _coffeeEdgeOverflow;
            final minTop = mediaQuery.padding.top - _coffeeEdgeOverflow;
            final maxTop =
                size.height - _coffeeSize - bottomInset + _coffeeEdgeOverflow;

            final cloudButtonLeft = (_coffeeLeft ??
                    size.width - _coffeeSize - _coffeeMargin)
                .clamp(minLeft, maxLeft);
            final cloudButtonTop = (_coffeeTop ??
                    size.height - _coffeeSize - bottomInset)
                .clamp(minTop, maxTop);

            return Stack(
              children: [
                Scaffold(
                  backgroundColor: Colors.transparent,
                  body: IndexedStack(
                    index: stackIndex,
                    children: const [
                      HomePage(),
                      PlusGuidePage(),
                      ExplorePage(),
                      MePage(),
                    ],
                  ),
                  bottomNavigationBar: _MainBottomBar(
                    currentIndex: stackIndex,
                    tokens: tokens,
                    homeLabel: homeLabel,
                    exploreLabel: exploreLabel,
                    meLabel: meLabel,
                    onItemSelected: (index) {
                      ref.read(bottomTabIndexProvider.notifier).state = index;
                      if (index >= 0 && index < _stackScreenNames.length) {
                        ref
                            .read(analyticsProvider)
                            .logScreenView(screenName: _stackScreenNames[index]);
                      }
                    },
                  ),
                ),
                FloatingCoffeeHint(
                  coffeeLeft: cloudButtonLeft,
                  coffeeTop: cloudButtonTop,
                  maxWidth: size.width,
                  showBubble: _showCoffeeHint,
                  message: uiString(
                    lang,
                    () {
                      switch (stackIndex) {
                        case 0:
                          return _coffeeHintStep == 0
                              ? 'coffee_hint_home_1'
                              : 'coffee_hint_double_tap';
                        case 1:
                          return 'coffee_hint_plus';
                        case 2:
                          return _coffeeHintStep == 0
                              ? 'coffee_hint_explore_1'
                              : 'coffee_hint_double_tap';
                        case 3:
                          return 'coffee_hint_me';
                        default:
                          return 'coffee_hint_home_1';
                      }
                    }(),
                  ),
                  onCoffeeTap: () => setState(() => _showCoffeeHint = true),
                  onBubbleTap: () => setState(() {
                    _showCoffeeHint = false;
                    if (stackIndex == 0 || stackIndex == 2) {
                      _coffeeHintStep = (_coffeeHintStep + 1) % 2;
                    }
                  }),
                  onPanUpdate: (delta) => setState(() {
                    _showCoffeeHint = false;
                    if (stackIndex == 0 || stackIndex == 2) {
                      _coffeeHintStep = (_coffeeHintStep + 1) % 2;
                    }
                    _coffeeLeft = (cloudButtonLeft + delta.dx)
                        .clamp(minLeft, maxLeft);
                    _coffeeTop =
                        (cloudButtonTop + delta.dy).clamp(minTop, maxTop);
                  }),
                  tokens: tokens,
                  onDoubleTap: () {
                    setState(() => _showCoffeeHint = false);
                    ref.read(bottomTabIndexProvider.notifier).state = 1;
                    ref
                        .read(analyticsProvider)
                        .logScreenView(screenName: _stackScreenNames[1]);
                  },
                  size: _coffeeSize,
                  margin: _coffeeMargin,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MainBottomBar extends StatelessWidget {
  const _MainBottomBar({
    required this.currentIndex,
    required this.tokens,
    required this.homeLabel,
    required this.exploreLabel,
    required this.meLabel,
    required this.onItemSelected,
  });

  final int currentIndex;
  final AppTokens tokens;
  final String homeLabel;
  final String exploreLabel;
  final String meLabel;
  final ValueChanged<int> onItemSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(AppSpacing.sm, 0, AppSpacing.sm, AppSpacing.sm),
      child: SizedBox(
        height: AppSpacing.navItemHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: AppSpacing.xxl,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [tokens.primary, tokens.primaryBright],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: tokens.primary.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItemButton(
                        index: 0,
                        currentIndex: currentIndex,
                        iconData: Icons.home_outlined,
                        selectedIconData: Icons.home,
                        label: homeLabel,
                        tokens: tokens,
                        onTap: () => onItemSelected(0),
                      ),
                      _NavItemButton(
                        index: 2,
                        currentIndex: currentIndex,
                        iconData: Icons.explore_outlined,
                        selectedIconData: Icons.explore,
                        label: exploreLabel,
                        tokens: tokens,
                        onTap: () => onItemSelected(2),
                      ),
                      _NavItemButton(
                        index: 3,
                        currentIndex: currentIndex,
                        iconData: Icons.person_outline,
                        selectedIconData: Icons.person,
                        label: meLabel,
                        tokens: tokens,
                        onTap: () => onItemSelected(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemButton extends StatelessWidget {
  const _NavItemButton({
    required this.index,
    required this.currentIndex,
    required this.iconData,
    required this.selectedIconData,
    required this.label,
    required this.tokens,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final IconData iconData;
  final IconData selectedIconData;
  final String label;
  final AppTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = index == currentIndex;
    final Color iconColor = selected
        ? tokens.textOnPrimary
        : tokens.textOnPrimary.withValues(alpha: 0.65);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected
              ? tokens.textOnPrimary.withValues(alpha: 0.12)
              : Colors.transparent,
          border: selected
              ? Border.all(
                  color: tokens.textOnPrimary.withValues(alpha: 0.16),
                  width: 1,
                )
              : null,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Icon(
              selected ? selectedIconData : iconData,
              color: iconColor,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: iconColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

