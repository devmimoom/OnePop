import '../data/models.dart';
import 'app_language.dart';

String _pickText({
  required AppLanguage lang,
  String? zh,
  String? en,
  required String fallback,
}) {
  // 主語言優先，沒有就退回 fallback，再退另一語言
  if (lang == AppLanguage.zhTw) {
    if (zh != null && zh.trim().isNotEmpty) return zh;
    if (fallback.trim().isNotEmpty) return fallback;
    return en?.trim() ?? '';
  } else {
    if (en != null && en.trim().isNotEmpty) return en;
    if (fallback.trim().isNotEmpty) return fallback;
    return zh?.trim() ?? '';
  }
}

String productTitle(Product p, AppLanguage lang) {
  return _pickText(
    lang: lang,
    zh: p.titleZh,
    en: p.titleEn,
    fallback: p.title,
  );
}

String productLevelGoal(Product p, AppLanguage lang) {
  final base = p.levelGoal ?? '';
  return _pickText(
    lang: lang,
    zh: p.levelGoalZh,
    en: p.levelGoalEn,
    fallback: base,
  );
}

String productLevelBenefit(Product p, AppLanguage lang) {
  final base = p.levelBenefit ?? '';
  return _pickText(
    lang: lang,
    zh: p.levelBenefitZh,
    en: p.levelBenefitEn,
    fallback: base,
  );
}

String productContentArchitecture(Product p, AppLanguage lang) {
  final base = p.contentArchitecture ?? '';
  return _pickText(
    lang: lang,
    zh: p.contentArchitectureZh,
    en: p.contentArchitectureEn,
    fallback: base,
  );
}

String contentItemAnchor(ContentItem c, AppLanguage lang) {
  return _pickText(
    lang: lang,
    zh: c.anchorZh,
    en: c.anchorEn,
    fallback: c.anchor,
  );
}

String contentItemText(ContentItem c, AppLanguage lang) {
  return _pickText(
    lang: lang,
    zh: c.contentZh,
    en: c.contentEn,
    fallback: c.content,
  );
}

