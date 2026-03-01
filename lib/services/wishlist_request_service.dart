import 'dart:io' show Platform;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class WishlistRequestService {
  static Future<void> submitWishlist({
    required String productName,
    String? description,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    final payload = <String, dynamic>{
      'productName': productName.trim(),
      'description': (description ?? '').trim(),
      'uid': user?.uid,
      'email': user?.email,
      'platform': _platform(),
      'appVersion': null, // 可視需要在未來補上版本資訊
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('submitWishlistRequest');
      await callable.call(payload);
    } on FirebaseFunctionsException catch (e) {
      throw Exception('wishlist_request_failed: ${e.code}');
    } catch (e) {
      throw Exception('wishlist_request_failed: $e');
    }
  }

  static String _platform() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'other';
  }
}

