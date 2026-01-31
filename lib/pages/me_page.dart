import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_scaffold.dart';
import '../theme/app_tokens.dart';
import '../widgets/rich_sections/sections/me_dashboard_section.dart';
import '../widgets/rich_sections/sections/me_interest_tags_section.dart';
import '../widgets/rich_sections/sections/me_achievements_section.dart';
import '../services/reset_service.dart';
import '../bubble_library/providers/providers.dart';
import '../bubble_library/ui/push_center_page.dart';

class MePage extends ConsumerWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final themeController = ref.watch(themeControllerProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Me',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: tokens.textPrimary,
                ),
          ),
          const SizedBox(height: 16),

          // 學習儀表板
          const MeDashboardSection(),
          const SizedBox(height: 14),

          // 興趣標籤
          const MeInterestTagsSection(),
          const SizedBox(height: 14),

          // 里程碑/成就
          const MeAchievementsSection(),
          const SizedBox(height: 18),

          // Notifications
          ListTile(
            leading: Icon(Icons.notifications_outlined, color: tokens.primary),
            title: Text('Notifications', style: TextStyle(color: tokens.textPrimary)),
            subtitle: Text(
              'Schedule, quiet hours, daily cap',
              style: TextStyle(color: tokens.textSecondary, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right, color: tokens.textSecondary),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PushCenterPage()),
            ),
          ),
          const Divider(),

          // Account
          _AccountSection(tokens: tokens),
          const Divider(),

          ListTile(
            leading: Icon(Icons.color_lens_outlined, color: tokens.primary),
            title: Text('Theme', style: TextStyle(color: tokens.textPrimary)),
            subtitle: Text(
              themeController.id.name == 'darkNeon' ? 'Dark Neon' : 'White Mint',
              style: TextStyle(color: tokens.textSecondary),
            ),
            trailing: Switch(
              value: themeController.id.name == 'whiteMint',
              onChanged: (_) => themeController.toggle(),
            ),
            onTap: () => themeController.toggle(),
          ),
          ListTile(
            leading: Icon(Icons.language, color: tokens.primary),
            title: Text('Language', style: TextStyle(color: tokens.textPrimary)),
            subtitle: Text(
              'English',
              style: TextStyle(color: tokens.textSecondary),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language options coming soon.')),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: tokens.primary),
            title: Text('About', style: TextStyle(color: tokens.textPrimary)),
            subtitle: Text(
              'Learning Bubbles 1.0.0',
              style: TextStyle(color: tokens.textSecondary),
            ),
            onTap: () => _showAboutDialog(context),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: tokens.primary),
            title: Text('Privacy policy', style: TextStyle(color: tokens.textPrimary)),
            trailing: Icon(Icons.open_in_new, size: 18, color: tokens.textSecondary),
            onTap: () => _launchUrl(context, 'https://example.com/privacy'),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined, color: tokens.primary),
            title: Text('Terms of use', style: TextStyle(color: tokens.textPrimary)),
            trailing: Icon(Icons.open_in_new, size: 18, color: tokens.textSecondary),
            onTap: () => _launchUrl(context, 'https://example.com/terms'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restore_outlined, color: Colors.red),
            title: const Text(
              'Reset all data',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: Text(
              'Clear all learning progress, settings, and local data. This cannot be undone.',
              style: TextStyle(color: tokens.textSecondary, fontSize: 12),
            ),
            onTap: () => _showResetDialog(context, ref),
          ),
          const SizedBox(height: 16),
          Text(
            'Subscription / Favorites / Settings (MVP placeholder)',
            style: TextStyle(color: tokens.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all data?'),
        content: const Text(
          'This will permanently remove:\n'
          '• All Firestore data (progress, settings, favorites, etc.)\n'
          '• All local data (notification schedule, cache, etc.)\n'
          '• All scheduled notifications\n\n'
          'This cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performReset(context, ref);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _performReset(BuildContext context, WidgetRef ref) async {
    // 显示详细的加载对话框
    final progressNotifier = ValueNotifier<String>('Preparing reset...');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ValueListenableBuilder<String>(
              valueListenable: progressNotifier,
              builder: (context, progress, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(progress),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      final resetService = ResetService();
      
      progressNotifier.value = 'Clearing cloud data...';
      await Future.delayed(const Duration(milliseconds: 100)); // 让 UI 更新
      
      await resetService.resetAll();
      
      progressNotifier.value = 'Refreshing...';

      // 关闭加载对话框
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // 显示成功消息
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset complete. App has been restored to default state.'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      // 刷新所有 provider
      ref.invalidate(libraryProductsProvider);
      ref.invalidate(wishlistProvider);
      ref.invalidate(savedItemsProvider);
      ref.invalidate(globalPushSettingsProvider);
    } catch (e) {
      // 关闭加载对话框
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // 显示错误消息
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset failed: $e'),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      if (kDebugMode) {
        debugPrint('重置失败: $e');
      }
    } finally {
      // 释放资源
      progressNotifier.dispose();
    }
  }

  static void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Learning Bubbles\nVersion 1.0.0',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $url')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $e')),
        );
      }
    }
  }
}

/// Account section: signed-in status and Sign out (re-sign anonymous to keep app working).
class _AccountSection extends ConsumerWidget {
  const _AccountSection({required this.tokens});

  final AppTokens tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final isAnonymous = user?.isAnonymous ?? true;

    return ListTile(
      leading: Icon(Icons.person_outline, color: tokens.primary),
      title: Text('Account', style: TextStyle(color: tokens.textPrimary)),
      subtitle: Text(
        user == null ? 'Not signed in' : (isAnonymous ? 'Signed in anonymously' : 'Signed in'),
        style: TextStyle(color: tokens.textSecondary, fontSize: 12),
      ),
      trailing: user != null
          ? TextButton(
              onPressed: () => _signOutAndResign(context, ref),
              child: Text('Sign out', style: TextStyle(color: tokens.primary)),
            )
          : null,
    );
  }

  Future<void> _signOutAndResign(BuildContext context, WidgetRef ref) async {
    await FirebaseAuth.instance.signOut();
    await FirebaseAuth.instance.signInAnonymously();
    ref.invalidate(uidProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out. You are now signed in as a new guest.')),
      );
    }
  }
}
