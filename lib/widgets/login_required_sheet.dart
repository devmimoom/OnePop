import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/app_language_provider.dart';
import '../localization/app_strings.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../theme/app_spacing.dart';
import '../theme/app_tokens.dart';

Future<void> showLoginRequiredSheet(
  BuildContext context,
  WidgetRef ref, {
  String? message,
}) {
  final lang = ref.read(appLanguageProvider);
  final subtitle = message ?? uiString(lang, 'login_required_subtitle');

  Future<void> openLogin(BuildContext sheetContext) async {
    Navigator.of(sheetContext).pop();
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) return;
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }

  Future<void> openRegister(BuildContext sheetContext) async {
    Navigator.of(sheetContext).pop();
    await Future<void>.delayed(Duration.zero);
    if (!context.mounted) return;
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final tokens = sheetContext.tokens;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: tokens.cardBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: tokens.cardBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 40,
                    color: tokens.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    uiString(lang, 'login_required_title'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: tokens.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: tokens.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    onPressed: () => openLogin(sheetContext),
                    child: Text(uiString(lang, 'login_required_sign_in')),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  OutlinedButton(
                    onPressed: () => openRegister(sheetContext),
                    child: Text(uiString(lang, 'login_required_register')),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class LoginRequiredPlaceholder extends ConsumerWidget {
  const LoginRequiredPlaceholder({
    super.key,
    this.message,
    this.icon = Icons.lock_outline,
  });

  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final tokens = context.tokens;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: tokens.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              uiString(lang, 'login_required_title'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: tokens.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message ?? uiString(lang, 'login_required_subtitle'),
              style: TextStyle(
                fontSize: 14,
                height: 1.45,
                color: tokens.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => showLoginRequiredSheet(
                context,
                ref,
                message: message,
              ),
              child: Text(uiString(lang, 'login_required_cta')),
            ),
          ],
        ),
      ),
    );
  }
}
