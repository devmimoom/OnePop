import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 0:Home 1:Plus 2:Explore 3:Me (IndexedStack index)
final bottomTabIndexProvider = StateProvider<int>((ref) => 0);
