import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:io';

import '../../bubble_library/notifications/notification_service.dart';
import '../ios_notification_guide_page.dart';
import 'onboarding_store.dart';

// Onboarding State Provider
final onboardingStateProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  return OnboardingNotifier();
});

class OnboardingState {
  final int currentPage;

  OnboardingState({required this.currentPage});

  OnboardingState copyWith({int? currentPage}) {
    return OnboardingState(currentPage: currentPage ?? this.currentPage);
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(OnboardingState(currentPage: 0));

  void setCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  void nextPage() {
    if (state.currentPage < 3) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  final VoidCallback onComplete;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    ref.read(onboardingStateProvider.notifier).setCurrentPage(page);
  }

  void _nextPage() {
    final currentPage = ref.read(onboardingStateProvider).currentPage;
    if (currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    final currentPage = ref.read(onboardingStateProvider).currentPage;
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _skipOnboarding() async {
    await setOnboardingComplete();
    if (mounted) widget.onComplete();
  }

  Future<void> _enableNotifications() async {
    await NotificationService().requestPermissionOnly();
    if (!mounted) return;
    if (Platform.isIOS) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => IosNotificationGuidePage(
            onComplete: () {
              setOnboardingComplete().then((_) => widget.onComplete());
            },
          ),
        ),
      );
    } else {
      await setOnboardingComplete();
      if (mounted) widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 圓角與分層：外層漸層為「下方」、Padding 留白、內層圓角+陰影+裁切
    const double inset = 16;
    const double radius = 28;
    const Color layerBg = Color(0xFF0A0E27);
    return Scaffold(
      backgroundColor: layerBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E27), Color(0xFF1A1F3A)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(inset),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: SafeArea(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    _Slide1(
                      onNext: _nextPage,
                      onSkip: _skipOnboarding,
                    ),
                    _Slide2(
                      onNext: _nextPage,
                      onPrevious: _previousPage,
                    ),
                    _Slide3(
                      onNext: _nextPage,
                      onPrevious: _previousPage,
                    ),
                    _Slide4(
                      onEnableNotifications: _enableNotifications,
                      onSkip: _skipOnboarding,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Slide1 extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _Slide1({
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0E27), Color(0xFF1A2642)],
        ),
      ),
      child: Column(
        children: [
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LogoWidget(),
                  SizedBox(height: 40),
                  Text(
                    'Welcome to\nOnePop',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Useful stuff delivered\nright when you need it',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xCCFFFFFF),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _NavigationWidget(
            currentPage: 0,
            isDarkBg: true,
            onNext: onNext,
            onSkip: onSkip,
          ),
        ],
      ),
    );
  }
}

class _Slide2 extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _Slide2({
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(32, 60, 32, 40),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  _NotificationDemo(),
                  SizedBox(height: 40),
                  Text(
                    'Info comes to you',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0E27),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No need to remember to open an app. We send you bite-sized insights at just the right moments throughout your day.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _NavigationWidget(
            currentPage: 1,
            isDarkBg: false,
            onNext: onNext,
            onPrevious: onPrevious,
          ),
        ],
      ),
    );
  }
}

class _Slide3 extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const _Slide3({
    required this.onNext,
    required this.onPrevious,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: const Color(0xFFFAFBFC),
      child: Column(
        children: [
          const Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(32, 60, 32, 40),
              child: Column(
                children: [
                  Text(
                    'Made for busy people',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0E27),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Built on what actually works',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: 32),
                  _FeatureCard(
                    icon: '🎯',
                    title: 'Quick reads',
                    description:
                        '60-80 words. Get the key idea in under a minute',
                  ),
                  SizedBox(height: 16),
                  _FeatureCard(
                    icon: '⏰',
                    title: 'Smart timing',
                    description:
                        'Sent when you\'re most likely to remember and use it',
                  ),
                  SizedBox(height: 16),
                  _FeatureCard(
                    icon: '📚',
                    title: 'Real topics',
                    description:
                        'Sleep, stress, focus, AI—stuff you can actually use',
                  ),
                ],
              ),
            ),
          ),
          _NavigationWidget(
            currentPage: 2,
            isDarkBg: false,
            onNext: onNext,
            onPrevious: onPrevious,
          ),
        ],
      ),
    );
  }
}

class _Slide4 extends ConsumerWidget {
  final VoidCallback onEnableNotifications;
  final VoidCallback onSkip;

  const _Slide4({
    required this.onEnableNotifications,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 60, 32, 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '🔔',
                        style: TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Turn on notifications',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0E27),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Let OnePop send you helpful stuff throughout the day',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF666666),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _BenefitItem(text: 'Get 3-5 quick tips daily'),
                  const SizedBox(height: 16),
                  const _BenefitItem(
                      text: 'We won\'t bug you during work or sleep'),
                  const SizedBox(height: 16),
                  const _BenefitItem(text: 'Change settings anytime you want'),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          _NavigationWidget(
            currentPage: 3,
            isDarkBg: false,
            isLastPage: true,
            onEnableNotifications: onEnableNotifications,
            onSkip: onSkip,
          ),
        ],
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
            child: const Center(
              child: Text(
                'OP',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
          const Positioned(
              top: 8, left: 8, child: _CornerAccent(position: 0)),
          const Positioned(
              top: 8, right: 8, child: _CornerAccent(position: 1)),
          const Positioned(
              bottom: 8, left: 8, child: _CornerAccent(position: 2)),
          const Positioned(
              bottom: 8, right: 8, child: _CornerAccent(position: 3)),
        ],
      ),
    );
  }
}

class _CornerAccent extends StatelessWidget {
  final int position;

  const _CornerAccent({required this.position});

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: Color(0x99FFFFFF), width: 3);
    Border border;
    switch (position) {
      case 0:
        border = const Border(top: side, left: side);
        break;
      case 1:
        border = const Border(top: side, right: side);
        break;
      case 2:
        border = const Border(bottom: side, left: side);
        break;
      case 3:
        border = const Border(bottom: side, right: side);
        break;
      default:
        border = Border.all(color: Colors.transparent);
    }

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: border,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _NotificationDemo extends StatelessWidget {
  const _NotificationDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: const _NotificationCard(
            appName: 'OnePop',
            time: 'now',
            content: '💡 Quick Stress Relief\n'
                'Breathe in for 4 seconds, hold for 7, breathe out for 8. '
                'This simple trick activates your body\'s natural calm response.',
          ),
        ),
        const SizedBox(height: 12),
        Opacity(
          opacity: 0.6,
          child: Transform.scale(
            scale: 0.95,
            child: const _NotificationCard(
              appName: 'OnePop',
              time: '2h ago',
              content: '🧠 Better Focus\n'
                  'Work in 25-minute blocks, then take a 5-minute break...',
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String appName;
  final String time;
  final String content;

  const _NotificationCard({
    required this.appName,
    required this.time,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                appName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0A0E27),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final String text;

  const _BenefitItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF667EEA),
          ),
          child: const Center(
            child: Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF333333),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavigationWidget extends ConsumerWidget {
  final int currentPage;
  final bool isDarkBg;
  final bool isLastPage;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onSkip;
  final VoidCallback? onEnableNotifications;

  const _NavigationWidget({
    required this.currentPage,
    required this.isDarkBg,
    this.isLastPage = false,
    this.onNext,
    this.onPrevious,
    this.onSkip,
    this.onEnableNotifications,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(32),
      color: isDarkBg ? Colors.transparent : Colors.white,
      child: Column(
        children: [
          _PageIndicator(currentPage: currentPage, isDarkBg: isDarkBg),
          const SizedBox(height: 20),
          if (currentPage == 0)
            Column(
              children: [
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkBg
                          ? const Color(0xB3FFFFFF)
                          : const Color(0xFF999999),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _GradientButton(
                  onPressed: onNext ?? () {},
                  text: 'Get Started',
                ),
              ],
            )
          else if (isLastPage)
            Column(
              children: [
                _GradientButton(
                  onPressed: onEnableNotifications ?? () {},
                  text: 'Turn On & Start',
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Maybe later',
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkBg
                          ? const Color(0xB3FFFFFF)
                          : const Color(0xFF999999),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPrevious,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: isDarkBg
                            ? const Color(0x4DFFFFFF)
                            : const Color(0xFFDDDDDD),
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkBg
                            ? const Color(0xB3FFFFFF)
                            : const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GradientButton(
                    onPressed: onNext ?? () {},
                    text: 'Next',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int currentPage;
  final bool isDarkBg;

  const _PageIndicator({
    required this.currentPage,
    required this.isDarkBg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isActive
                ? (isDarkBg ? Colors.white : const Color(0xFF667EEA))
                : (isDarkBg
                    ? const Color(0x4DFFFFFF)
                    : const Color(0xFFDDDDDD)),
          ),
        );
      }),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const _GradientButton({
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
