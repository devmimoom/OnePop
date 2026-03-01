class Segment {
  final String id;
  final String title;
  final int order;
  final String mode; // "all" | "tag"
  final String? tag;
  final bool published;

  Segment({
    required this.id,
    required this.title,
    required this.order,
    required this.mode,
    required this.published,
    this.tag,
  });

  factory Segment.fromMap(Map<String, dynamic> m) => Segment(
        id: m['id'] ?? '',
        title: m['title'] ?? '',
        order: (m['order'] ?? 0) as int,
        mode: m['mode'] ?? 'all',
        tag: m['tag'],
        published: (m['published'] ?? true) as bool,
      );
}

class Topic {
  final String id;
  final String title;
  final bool published;
  final int order;
  final List<String> tags;
  final String? bubbleImageUrl;

  Topic({
    required this.id,
    required this.title,
    required this.published,
    required this.order,
    required this.tags,
    this.bubbleImageUrl,
  });

  factory Topic.fromDoc(String id, Map<String, dynamic> m) => Topic(
        id: id,
        title: m['title'] ?? '',
        published: (m['published'] ?? true) as bool,
        order: (m['order'] ?? 0) as int,
        tags: List<String>.from(m['tags'] ?? const []),
        bubbleImageUrl: m['bubbleImageUrl'],
      );
}

class FeaturedList {
  final String id;
  final String title;
  final bool published;
  final int order;
  final List<String> productIds;
  final List<String>? topicIds;
  final String? coverImageUrl;
  final String? coverStorageFile;

  FeaturedList({
    required this.id,
    required this.title,
    required this.published,
    required this.order,
    required this.productIds,
    this.topicIds,
    this.coverImageUrl,
    this.coverStorageFile,
  });

  factory FeaturedList.fromDoc(String id, Map<String, dynamic> m) =>
      FeaturedList(
        id: id,
        title: m['title'] ?? '',
        published: (m['published'] ?? true) as bool,
        order: (m['order'] ?? 0) as int,
        productIds: List<String>.from(m['productIds'] ?? const []),
        topicIds: m['topicIds'] != null
            ? List<String>.from(m['topicIds'] as List)
            : null,
        coverImageUrl: m['coverImageUrl']?.toString(),
        coverStorageFile: m['coverStorageFile']?.toString(),
      );
}

class Product {
  final String id;
  final String title;
  // 雙語欄位（若未提供則為 null）
  final String? titleZh;
  final String? titleEn;
  final String topicId;
  final String level;
  final bool published;

  final String? coverImageUrl;
  final String? levelGoal;
  final String? levelGoalZh;
  final String? levelGoalEn;
  final String? levelBenefit;
  final String? levelBenefitZh;
  final String? levelBenefitEn;

  final String? spec1Label;
  final String? spec2Label;
  final String? spec3Label;
  final String? spec4Label;

  final int trialLimit;
  final int? releaseAtMs;
  final int? createdAtMs;
  final String? contentArchitecture;
  final String? contentArchitectureZh;
  final String? contentArchitectureEn;
  /// 解鎖所需額度：0=免費，1=1 額度，2+=多額度
  final int creditsRequired;

  Product({
    required this.id,
    required this.title,
    this.titleZh,
    this.titleEn,
    required this.topicId,
    required this.level,
    required this.published,
    this.coverImageUrl,
    this.levelGoal,
    this.levelGoalZh,
    this.levelGoalEn,
    this.levelBenefit,
    this.levelBenefitZh,
    this.levelBenefitEn,
    this.spec1Label,
    this.spec2Label,
    this.spec3Label,
    this.spec4Label,
    required this.trialLimit,
    this.releaseAtMs,
    this.createdAtMs,
    this.contentArchitecture,
    this.contentArchitectureZh,
    this.contentArchitectureEn,
    this.creditsRequired = 1,
  });

  factory Product.fromDoc(String id, Map<String, dynamic> m) => Product(
        id: id,
        // 既有欄位仍以 title 儲存主要語言（多數情況為繁中），雙語欄位另外存放
        title: m['title'] ?? '',
        titleZh: m['titleZh']?.toString() ?? m['title_zh']?.toString(),
        titleEn: m['titleEn']?.toString() ?? m['title_en']?.toString(),
        topicId: m['topicId'] ?? '',
        level: m['level'] ?? 'L1',
        published: (m['published'] ?? true) as bool,
        coverImageUrl: m['coverImageUrl'],
        levelGoal: m['levelGoal'],
        levelGoalZh: m['levelGoalZh']?.toString() ?? m['levelGoal_zh']?.toString(),
        levelGoalEn: m['levelGoalEn']?.toString() ?? m['levelGoal_en']?.toString(),
        levelBenefit: m['levelBenefit'],
        levelBenefitZh: m['levelBenefitZh']?.toString() ?? m['levelBenefit_zh']?.toString(),
        levelBenefitEn: m['levelBenefitEn']?.toString() ?? m['levelBenefit_en']?.toString(),
        spec1Label: m['spec1Label'],
        spec2Label: m['spec2Label'],
        spec3Label: m['spec3Label'],
        spec4Label: m['spec4Label'],
        trialLimit: (m['trialLimit'] ?? 3) as int,
        releaseAtMs: (m['releaseAtMs'] is num)
            ? (m['releaseAtMs'] as num).toInt()
            : null,
        createdAtMs: (m['createdAtMs'] is num)
            ? (m['createdAtMs'] as num).toInt()
            : null,
        contentArchitecture: (m['contentArchitecture'] ?? m['contentarchitecture']) as String?,
        contentArchitectureZh: m['contentArchitectureZh']?.toString() ?? m['contentArchitecture_zh']?.toString() ?? m['contentarchitecture_zh']?.toString(),
        contentArchitectureEn: m['contentArchitectureEn']?.toString() ?? m['contentArchitecture_en']?.toString() ?? m['contentarchitecture_en']?.toString(),
        creditsRequired: (m['creditsRequired'] is num)
            ? (m['creditsRequired'] as num).toInt().clamp(0, 999)
            : 1,
      );

  DateTime? get releaseAt =>
      releaseAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(releaseAtMs!);

  DateTime? get createdAt =>
      createdAtMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(createdAtMs!);
}

class ContentItem {
  final String id;
  final String productId;
  final String anchor;
  final String? anchorZh;
  final String? anchorEn;
  final String content;
  final String? contentZh;
  final String? contentEn;
  final String intent;
  final String? intentZh;
  final String? intentEn;
  final int difficulty;
  final int seq;
  final bool isPreview;
  final String deepAnalysis;
  final String? deepAnalysisZh;
  final String? deepAnalysisEn;

  ContentItem({
    required this.id,
    required this.productId,
    required this.anchor,
    this.anchorZh,
    this.anchorEn,
    required this.content,
    this.contentZh,
    this.contentEn,
    required this.intent,
    this.intentZh,
    this.intentEn,
    required this.difficulty,
    required this.seq,
    required this.isPreview,
    this.deepAnalysis = '',
    this.deepAnalysisZh,
    this.deepAnalysisEn,
  });

  factory ContentItem.fromDoc(String id, Map<String, dynamic> m) => ContentItem(
        id: id,
        productId: m['productId'] ?? '',
        anchor: m['anchor'] ?? '',
        anchorZh: m['anchorZh']?.toString() ?? m['anchor_zh']?.toString(),
        anchorEn: m['anchorEn']?.toString() ?? m['anchor_en']?.toString(),
        content: m['content'] ?? '',
        contentZh: m['contentZh']?.toString() ?? m['content_zh']?.toString(),
        contentEn: m['contentEn']?.toString() ?? m['content_en']?.toString(),
        intent: m['intent'] ?? '',
        intentZh: m['intentZh']?.toString() ?? m['intent_zh']?.toString(),
        intentEn: m['intentEn']?.toString() ?? m['intent_en']?.toString(),
        difficulty: (m['difficulty'] ?? 1) as int,
        seq: (m['seq'] ?? 0) as int,
        isPreview: (m['isPreview'] ?? false) as bool,
        deepAnalysis: (m['deepAnalysis'] ?? '') as String,
        deepAnalysisZh: m['deepAnalysisZh']?.toString() ?? m['deepAnalysis_zh']?.toString(),
        deepAnalysisEn: m['deepAnalysisEn']?.toString() ?? m['deepAnalysis_en']?.toString(),
      );
}
