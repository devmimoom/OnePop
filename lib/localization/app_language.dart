/// App 支援的顯示語言
enum AppLanguage {
  zhTw,
  en,
}

/// 依系統 Locale 推測預設語言（目前預設為英文）
AppLanguage detectSystemLanguage() {
  return AppLanguage.en;
}

/// 回傳標準化語言代碼字串（可供日後記錄到 Firestore 或偏好設定）
String appLanguageCode(AppLanguage lang) {
  switch (lang) {
    case AppLanguage.zhTw:
      return 'zh-TW';
    case AppLanguage.en:
      return 'en';
  }
}

/// 回傳設定頁／選單顯示用的語言名稱
String appLanguageDisplayName(AppLanguage lang) {
  switch (lang) {
    case AppLanguage.zhTw:
      return '繁體中文';
    case AppLanguage.en:
      return 'English';
  }
}

