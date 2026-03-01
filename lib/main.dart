import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_bootstrapper.dart';
import 'app_scaffold.dart';
import 'bubble_library/bootstrapper.dart';
import 'theme/theme_controller.dart';
import 'theme/app_themes.dart';
import 'navigation/app_nav.dart';
import 'pages/welcome/bubble_welcome_page.dart';
import 'pages/welcome/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 禁止 Google Fonts 在運行時下載字型（避免審核或離線時的問題）
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(AppBootstrapper(
    builder: (themeController, initialHasSeenOnboarding) => ProviderScope(
      overrides: [themeControllerProvider.overrideWithValue(themeController)],
      child: MyApp(
        themeController: themeController,
        initialHasSeenOnboarding: initialHasSeenOnboarding,
      ),
    ),
  ));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;
  final bool initialHasSeenOnboarding;
  const MyApp({
    super.key,
    required this.themeController,
    required this.initialHasSeenOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return _AppRoot(
      themeController: themeController,
      initialHasSeenOnboarding: initialHasSeenOnboarding,
    );
  }
}

/// Root gate: shows onboarding when not seen, then Welcome or Main based on flow B.
class _AppRoot extends StatefulWidget {
  final ThemeController themeController;
  final bool initialHasSeenOnboarding;

  const _AppRoot({
    required this.themeController,
    required this.initialHasSeenOnboarding,
  });

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  late bool _hasSeenOnboarding;
  late bool _showWelcomePage;

  @override
  void initState() {
    super.initState();
    _hasSeenOnboarding = widget.initialHasSeenOnboarding;
    // 每次啟動都先顯示 Welcome，點擊後才進入 Main
    _showWelcomePage = widget.initialHasSeenOnboarding;
  }

  void _onOnboardingComplete() {
    setState(() {
      _hasSeenOnboarding = true;
      _showWelcomePage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = widget.themeController;

    if (_hasSeenOnboarding == false) {
      return AnimatedBuilder(
        animation: themeController,
        builder: (_, __) {
          return MaterialApp(
            title: 'OnePop',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.byId(themeController.id),
            home: OnboardingScreen(onComplete: _onOnboardingComplete),
          );
        },
      );
    }

    // _hasSeenOnboarding == true: show Welcome once after onboarding, then Main on later launches
    return BubbleBootstrapper(
      child: AnimatedBuilder(
        animation: themeController,
        builder: (_, __) {
          return MaterialApp(
            navigatorKey: rootNavKey,
            title: 'OnePop',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.byId(themeController.id),
            home: _showWelcomePage
                ? BubbleWelcomePage(
                    onFinished: () {
                      setState(() => _showWelcomePage = false);
                      rootNavKey.currentState?.pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => MainScaffold4Tabs(
                              themeController: themeController),
                        ),
                      );
                    },
                  )
                : MainScaffold4Tabs(themeController: themeController),
          );
        },
      ),
    );
  }
}
