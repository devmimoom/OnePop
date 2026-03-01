import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_learning_store.dart';
import 'user/me_prefs_store.dart';

/// 全域：過去 7 天（含今天）完成天數
final globalWeeklyCountProvider = FutureProvider<int>((ref) async {
  return UserLearningStore().globalWeeklyCount();
});

/// 全域：連續天數 streak
final globalStreakProvider = FutureProvider<int>((ref) async {
  return UserLearningStore().globalStreak();
});

/// Me 頁興趣標籤（依 uid 或 'local'），編輯後需 invalidate 此 provider
final meInterestTagsProvider =
    FutureProvider.family<List<String>, String>((ref, uidOrLocal) async {
  return MePrefsStore.getInterestTags(uidOrLocal);
});
