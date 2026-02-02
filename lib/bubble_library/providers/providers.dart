import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/product_repo.dart';
import '../data/content_repo.dart';
import '../data/library_repo.dart';
import '../data/push_settings_repo.dart';
import '../data/credits_repo.dart';

import '../models/product.dart';
import '../models/content_item.dart';
import '../models/user_library.dart';
import '../models/global_push_settings.dart';
import '../../notifications/favorite_sentences_store.dart';
import '../../services/learning_progress_service.dart';
import '../../services/auth_service.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authServiceProvider =
    Provider<AuthService>((ref) => AuthService(auth: ref.watch(firebaseAuthProvider)));

/// 聆聽 auth 狀態變化，供「是否為匿名」「是否已連結」等 UI 使用。
/// 使用 userChanges() 以便 profile（email）更新時也會發送，Account 副標能即時顯示 email。
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).userChanges();
});

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final uidProvider = Provider<String>((ref) {
  final u = ref.watch(firebaseAuthProvider).currentUser;
  if (u == null) throw StateError('User not logged in');
  return u.uid;
});

/// 審查／全開帳號：登入此 email 時所有產品視為免費（不扣額度）。
const _fullAccessEmails = ['dev.mimoom@gmail.com'];

/// 當前登入使用者的 email（未登入或匿名為 null）。
final currentUserEmailProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.email;
});

/// 是否為「全產品免付費」帳號（用於 App 審查等）。
final isFullAccessUserProvider = Provider<bool>((ref) {
  final email = ref.watch(currentUserEmailProvider);
  return email != null &&
      email.isNotEmpty &&
      _fullAccessEmails.contains(email);
});

final productRepoProvider =
    Provider<ProductRepo>((ref) => ProductRepo(ref.watch(firestoreProvider)));
final contentRepoProvider =
    Provider<ContentRepo>((ref) => ContentRepo(ref.watch(firestoreProvider)));
final libraryRepoProvider =
    Provider<LibraryRepo>((ref) => LibraryRepo(ref.watch(firestoreProvider)));
final pushSettingsRepoProvider = Provider<PushSettingsRepo>(
    (ref) => PushSettingsRepo(ref.watch(firestoreProvider)));
final creditsRepoProvider =
    Provider<CreditsRepo>((ref) => CreditsRepo(ref.watch(firestoreProvider)));

// ✅ LearningProgressService 透過 Provider 管理，統一使用 firestoreProvider 和 firebaseAuthProvider
final learningProgressServiceProvider = Provider<LearningProgressService>((ref) {
  return LearningProgressService(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

final productsMapProvider = FutureProvider<Map<String, Product>>((ref) async {
  return ref.read(productRepoProvider).getAll();
});

final libraryProductsProvider = StreamProvider<List<UserLibraryProduct>>((ref) {
  final uid = ref.watch(uidProvider);
  return ref.read(libraryRepoProvider).watchLibrary(uid);
});

final wishlistProvider = StreamProvider<List<WishlistItem>>((ref) {
  final uid = ref.watch(uidProvider);
  return ref.read(libraryRepoProvider).watchWishlist(uid);
});

final savedItemsProvider = StreamProvider<Map<String, SavedContent>>((ref) {
  final uid = ref.watch(uidProvider);
  return ref.read(libraryRepoProvider).watchSaved(uid);
});

final globalPushSettingsProvider = StreamProvider<GlobalPushSettings>((ref) {
  final uid = ref.watch(uidProvider);
  return ref.read(pushSettingsRepoProvider).watchGlobal(uid);
});

/// 當前用戶額度餘額（未登入時為 0）
/// 先 emit getBalance 再訂閱 watchBalance，讓 Me 頁盡快顯示餘額。
final creditsBalanceProvider = StreamProvider<int>((ref) {
  try {
    final uid = ref.watch(uidProvider);
    final repo = ref.read(creditsRepoProvider);
    Stream<int> stream() async* {
      yield await repo.getBalance(uid);
      yield* repo.watchBalance(uid);
    }
    return stream();
  } catch (_) {
    return Stream.value(0);
  }
});

/// 當前用戶額度交易紀錄（未登入時為空列表）
final creditTransactionsProvider =
    StreamProvider<List<CreditTransaction>>((ref) {
  try {
    final uid = ref.watch(uidProvider);
    return ref.read(creditsRepoProvider).watchTransactions(uid);
  } catch (_) {
    return Stream.value([]);
  }
});

final contentByProductProvider =
    FutureProvider.family<List<ContentItem>, String>((ref, productId) async {
  return ref.read(contentRepoProvider).getByProduct(productId);
});

final contentItemProvider =
    FutureProvider.family<ContentItem, String>((ref, contentItemId) async {
  return ref.read(contentRepoProvider).getOne(contentItemId);
});

final favoriteSentencesProvider =
    FutureProvider.family<List<FavoriteSentence>, String>((ref, uid) async {
  return FavoriteSentencesStore.loadAll(uid);
});
