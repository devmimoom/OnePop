class FirestorePaths {
  static String products() => 'products';
  static String contentItems() => 'content_items';

  static String userDoc(String uid) => 'users/$uid';
  /// 額度餘額文件：users/{uid}/wallet/balance
  static String userWallet(String uid) => 'users/$uid/wallet/balance';
  /// 額度交易紀錄子集合：users/{uid}/credit_transactions
  static String userCreditTransactions(String uid) =>
      'users/$uid/credit_transactions';
  static String userLibraryProducts(String uid) =>
      'users/$uid/library_products';
  static String userWishlist(String uid) => 'users/$uid/wishlist';
  static String userSavedItems(String uid) => 'users/$uid/saved_items';
  static String userGlobalPush(String uid) => 'users/$uid/push_settings/global';
}
