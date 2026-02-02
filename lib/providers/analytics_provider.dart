import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/app_analytics.dart';

final analyticsProvider = Provider<AppAnalytics>((ref) => AppAnalytics());
