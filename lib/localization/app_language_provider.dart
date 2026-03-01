import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_language.dart';

/// 全域 App 語言狀態（預設依系統語言推測）
final appLanguageProvider =
    StateProvider<AppLanguage>((ref) => detectSystemLanguage());

