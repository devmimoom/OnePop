import 'package:shared_preferences/shared_preferences.dart';

const String _keyHasSeenOnboarding = 'has_seen_onboarding';

/// Reads whether the user has completed onboarding (any path: skip or finish).
Future<bool> hasSeenOnboarding() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_keyHasSeenOnboarding) ?? false;
}

/// Marks onboarding as complete. Call when user finishes or skips onboarding.
Future<void> setOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyHasSeenOnboarding, true);
}
