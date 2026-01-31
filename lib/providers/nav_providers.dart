import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 0:Home 1:Categories 2:Search 3:Library 4:Me
final bottomTabIndexProvider = StateProvider<int>((ref) => 0);
