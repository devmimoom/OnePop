import 'package:purchases_flutter/purchases_flutter.dart';

/// 額度包 IAP：RevenueCat 購買 credits_1 / credits_3 / credits_10，成功後由 caller 呼叫 CreditsRepo.addCredits
/// 在 RevenueCat Dashboard 建立對應 Product ID；替換下方 API Key
const String _revenueCatAppleApiKey = 'test_MOJmstWlfeEGrSagJgwqDexImaa'; // 填 RevenueCat Public API Key (Apple)

const Map<String, int> _productIdToCredits = {
  'credits_1': 1,
  'credits_3': 3,
  'credits_10': 10,
};

int creditsForProductId(String productId) =>
    _productIdToCredits[productId] ?? 0;

class CreditsIAPService {
  static bool _configured = false;

  static Future<void> configure(String? appUserId) async {
    if (_revenueCatAppleApiKey.isEmpty) return;
    if (_configured) return;
    await Purchases.setLogLevel(LogLevel.warn);
    final config = PurchasesConfiguration(_revenueCatAppleApiKey);
    if (appUserId != null && appUserId.isNotEmpty) {
      config.appUserID = appUserId;
    }
    await Purchases.configure(config);
    _configured = true;
  }

  static Future<void> logIn(String appUserId) async {
    if (!_configured) return;
    await Purchases.logIn(appUserId);
  }

  /// 取得額度包產品列表（用於商店 UI）
  static Future<List<StoreProduct>> getCreditProducts() async {
    if (!_configured) return [];
    try {
      final ids = _productIdToCredits.keys.toList();
      final products = await Purchases.getProducts(ids);
      return products;
    } catch (_) {
      return [];
    }
  }

  /// 購買指定產品，成功回傳獲得額度數；失敗拋錯
  static Future<int> purchase(StoreProduct product) async {
    try {
      await Purchases.purchaseStoreProduct(product);
      final credits = creditsForProductId(product.identifier);
      return credits;
    } catch (e) {
      rethrow;
    }
  }
}
