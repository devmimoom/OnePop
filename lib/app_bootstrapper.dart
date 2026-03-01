import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';

import 'theme/theme_controller.dart';
import 'theme/app_themes.dart';
import 'theme/app_theme_id.dart';
import 'pages/welcome/onboarding_store.dart';
import 'iap/credits_iap_service.dart';

/// Flutter 啟動後進行初始化（Firebase、主題、hasSeenOnboarding），完成後透過 [builder] 建立正式 app。
class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({
    super.key,
    required this.builder,
  });

  final Widget Function(ThemeController themeController, bool initialHasSeenOnboarding) builder;

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  bool _isReady = false;
  Object? _error;
  ThemeController? _themeController;
  bool _initialHasSeenOnboarding = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final auth = FirebaseAuth.instance;
      if (auth.currentUser == null) {
        try {
          await auth.signInAnonymously();
        } catch (e) {
          if (kDebugMode) debugPrint('Anonymous sign-in failed: $e');
        }
      }

      if (auth.currentUser != null) {
        await CreditsIAPService.configure(auth.currentUser!.uid);
        await FirebaseAnalytics.instance.setUserId(id: auth.currentUser!.uid);
      }

      final themeController = ThemeController();
      await themeController.init();

      final initialHasSeenOnboarding = await hasSeenOnboarding();

      if (!mounted) return;
      setState(() {
        _themeController = themeController;
        _initialHasSeenOnboarding = initialHasSeenOnboarding;
        _isReady = true;
        _error = null;
      });
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Bootstrap error: $e');
        debugPrint(stack.toString());
      }
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        title: 'OnePop',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.byId(AppThemeId.darkNeon),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Init failed',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_error',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      setState(() => _error = null);
                      _bootstrap();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (!_isReady) {
      return MaterialApp(
        title: 'OnePop',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.byId(AppThemeId.darkNeon),
        home: const Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A)],
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      );
    }

    return widget.builder(_themeController!, _initialHasSeenOnboarding);
  }
}
