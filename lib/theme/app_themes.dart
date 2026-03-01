import 'package:flutter/material.dart';
import 'app_theme_id.dart';
import 'app_tokens.dart';

// Apply this color migration across the entire project.
// OnePop Color Migration — Dual Theme Spec: Amber Night (dark) + Warm Amber (light).

class AppThemes {
  static ThemeData byId(AppThemeId id) {
    switch (id) {
      case AppThemeId.darkNeon:
        return _darkNeon();
      case AppThemeId.whiteMint:
        return _whiteMint();
    }
  }

  /// Amber Night (dark): amber IS headline/accent. Section titles = amber.
  static ThemeData _darkNeon() {
    const bg = Color(0xFF0C0F1A);
    const primary = Color(0xFFE8A838);
    const primaryLight = Color(0xFFF5C04A);
    const textOnPrimary = Color(0xFF0C0F1A);

    const tokens = AppTokens(
      bg: bg,
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF0C0F1A),
          Color(0xFF1A1F35),
          Color(0xFF0C0F1A),
        ],
      ),
      primary: primary,
      primaryBright: primary,
      primaryPale: Color.fromRGBO(232, 168, 56, 0.15),
      sectionTitleColor: primary,
      textPrimary: Color(0xFFEDE8DD),
      textSecondary: Color(0xFF9A9484),
      textMuted: Color(0xFF6B6558),
      textOnPrimary: textOnPrimary,
      cardBg: Color(0xFF151929),
      cardBorder: Color.fromRGBO(232, 168, 56, 0.12),
      cardRadius: 24,
      cardShadow: [
        BoxShadow(
          color: Color.fromRGBO(232, 168, 56, 0.06),
          blurRadius: 80,
          offset: Offset(0, 12),
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.35),
          blurRadius: 28,
          offset: Offset(0, 12),
        ),
      ],
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(255, 255, 255, 0.12),
          Color.fromRGBO(232, 168, 56, 0.08),
          Color.fromRGBO(255, 255, 255, 0.08),
        ],
      ),
      chipBg: Color(0xFF1C2139),
      chipGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(232, 168, 56, 0.15),
          Color.fromRGBO(255, 255, 255, 0.08),
        ],
      ),
      navBg: Color.fromRGBO(20, 24, 44, 0.72),
      navGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(20, 24, 44, 0.85),
          Color.fromRGBO(11, 14, 26, 0.95),
        ],
      ),
      buttonGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryLight],
      ),
      searchBarGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromRGBO(255, 255, 255, 0.12),
          Color.fromRGBO(255, 255, 255, 0.08),
        ],
      ),
      glassBlurSigma: 18,
    );

    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ).copyWith(
        primary: primary,
        surface: tokens.cardBg,
        // ✅ 修復深色主題下拉選單：確保 surfaceContainerHighest 使用不透明背景
        surfaceContainerHighest: const Color(0xFF14182E),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(fontSize: 15, height: 1.35),
        bodySmall: TextStyle(fontSize: 13, height: 1.35),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color.fromRGBO(255, 255, 255, 0.10),
        hintStyle: const TextStyle(color: Color.fromRGBO(255, 255, 255, 0.60)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              const BorderSide(color: Color.fromRGBO(255, 255, 255, 0.14)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide:
              const BorderSide(color: Color.fromRGBO(255, 255, 255, 0.14)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      // ✅ 修復深色主題下拉選單透明背景重疊問題
      // DropdownButton 使用 Menu widget，需要配置 menuTheme
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            const Color(0xFF14182E), // 使用不透明的深色背景，避免透明重疊
          ),
          elevation: WidgetStateProperty.all(8),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // DropdownMenu widget 的主題配置
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            const Color(0xFF14182E), // 使用不透明的深色背景，避免透明重疊
          ),
          elevation: WidgetStateProperty.all(8),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );

    return base.copyWith(extensions: [tokens]);
  }

  /// Warm Amber (light): section titles = near-black. Amber only for buttons/links/accent bar.
  static ThemeData _whiteMint() {
    const bg = Color(0xFFFAF8F4);
    const primary = Color(0xFFC8850A);
    const primaryBright = Color(0xFFE8A838);
    const primaryPale = Color(0xFFFFF3DC);

    const tokens = AppTokens(
      bg: bg,
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFAF8F4),
          Color(0xFFF5F2EC),
          Color(0xFFFAF8F4),
        ],
      ),
      primary: primary,
      primaryBright: primaryBright,
      primaryPale: primaryPale,
      sectionTitleColor: Color(0xFF1A1710),
      textPrimary: Color(0xFF1A1710),
      textSecondary: Color(0xFF6B6152),
      textMuted: Color(0xFF9A9080),
      textOnPrimary: Color(0xFFFFFFFF),
      cardBg: Color(0xFFFFFFFF),
      cardBorder: Color.fromRGBO(26, 23, 16, 0.08),
      cardRadius: 22,
      cardShadow: [
        BoxShadow(
          color: Color.fromRGBO(26, 23, 16, 0.06),
          blurRadius: 12,
          offset: Offset(0, 2),
        ),
      ],
      cardGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFFAF8F4),
        ],
      ),
      chipBg: Color(0xFFF0EDE6),
      chipGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF0EDE6),
          Color(0xFFFFF8EC),
        ],
      ),
      navBg: Color(0xFFFFFFFF),
      navGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFFFFFFF),
        ],
      ),
      buttonGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryBright, primaryBright],
      ),
      searchBarGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF5F2EC),
          Color(0xFFF0EDE6),
        ],
      ),
      glassBlurSigma: 10,
    );

    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(
        primary: primary,
        surface: tokens.cardBg,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        bodyMedium: TextStyle(fontSize: 15, height: 1.35),
        bodySmall: TextStyle(fontSize: 13, height: 1.35),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF6F7FB),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFEEF1F6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFEEF1F6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),
      // ✅ 淺色主題下拉選單主題配置
      // DropdownButton 使用 Menu widget，需要配置 menuTheme
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            Colors.white, // 淺色主題使用白色背景
          ),
          elevation: WidgetStateProperty.all(8),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // DropdownMenu widget 的主題配置
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(
            Colors.white, // 淺色主題使用白色背景
          ),
          elevation: WidgetStateProperty.all(8),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );

    return base.copyWith(extensions: [tokens]);
  }
}
