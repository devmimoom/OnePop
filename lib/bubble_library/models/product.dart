import '../../localization/app_language.dart';

class Product {
  final String id;
  final String title;
  final bool published;
  final String pushStrategy; // seq
  final String trialMode; // previewFlag
  final int trialLimit; // 3
  final int order;
  final String topicId;
  final String level;
  final String? levelGoal;
  final String? levelBenefit;
  final String? contentArchitecture;
  final String? titleZh;
  final String? levelGoalZh;
  final String? levelBenefitZh;
  final String? contentArchitectureZh;

  const Product({
    required this.id,
    required this.title,
    required this.published,
    required this.pushStrategy,
    required this.trialMode,
    required this.trialLimit,
    required this.order,
    this.topicId = '',
    this.level = 'L1',
    this.levelGoal,
    this.levelBenefit,
    this.contentArchitecture,
    this.titleZh,
    this.levelGoalZh,
    this.levelBenefitZh,
    this.contentArchitectureZh,
  });

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  factory Product.fromMap(String id, Map<String, dynamic> m) {
    final pushStrategyValue = m['pushStrategy'];
    final trialModeValue = m['trialMode'];

    return Product(
      id: id,
      title: (m['title'] ?? '') as String,
      published: (m['published'] ?? false) as bool,
      pushStrategy:
          (pushStrategyValue != null ? pushStrategyValue.toString() : 'seq'),
      trialMode:
          (trialModeValue != null ? trialModeValue.toString() : 'previewFlag'),
      trialLimit: ((m['trialLimit'] ?? 3) as num).toInt(),
      order: ((m['order'] ?? 0) as num).toInt(),
      topicId: m['topicId']?.toString() ?? '',
      level: m['level']?.toString() ?? 'L1',
      levelGoal: _str(m['levelGoal']),
      levelBenefit: _str(m['levelBenefit']),
      contentArchitecture: _str(m['contentArchitecture']) ?? _str(m['contentarchitecture']),
      titleZh: _str(m['titleZh']) ?? _str(m['title_zh']),
      levelGoalZh: _str(m['levelGoalZh']) ?? _str(m['levelGoal_zh']),
      levelBenefitZh: _str(m['levelBenefitZh']) ?? _str(m['levelBenefit_zh']),
      contentArchitectureZh: _str(m['contentArchitectureZh']) ?? _str(m['contentArchitecture_zh']) ?? _str(m['contentarchitecture_zh']),
    );
  }
}

extension ProductDisplay on Product {
  String displayTitle(AppLanguage lang) {
    if (lang == AppLanguage.zhTw && titleZh != null && titleZh!.isNotEmpty) return titleZh!;
    return title;
  }

  String displayLevelGoal(AppLanguage lang) {
    if (lang == AppLanguage.zhTw && levelGoalZh != null && levelGoalZh!.isNotEmpty) return levelGoalZh!;
    return levelGoal ?? '';
  }

  String displayLevelBenefit(AppLanguage lang) {
    if (lang == AppLanguage.zhTw && levelBenefitZh != null && levelBenefitZh!.isNotEmpty) return levelBenefitZh!;
    return levelBenefit ?? '';
  }

  String displayContentArchitecture(AppLanguage lang) {
    if (lang == AppLanguage.zhTw && contentArchitectureZh != null && contentArchitectureZh!.isNotEmpty) return contentArchitectureZh!;
    return contentArchitecture ?? '';
  }
}
