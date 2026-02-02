import 'package:firebase_analytics/firebase_analytics.dart';

/// 封裝 Firebase Analytics，提供 screen_view 與自訂事件。
class AppAnalytics {
  AppAnalytics({FirebaseAnalytics? analytics})
      : _analytics = analytics ?? FirebaseAnalytics.instance;

  final FirebaseAnalytics _analytics;

  FirebaseAnalytics get instance => _analytics;

  /// 設定用戶 ID（登入後呼叫；登出可傳 null 或空字串）。
  Future<void> setUserId(String? uid) async {
    await _analytics.setUserId(id: uid ?? '');
  }

  /// 記錄畫面瀏覽。
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// 記錄自訂或建議事件。
  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    await _analytics.logEvent(name: name, parameters: params);
  }
}
