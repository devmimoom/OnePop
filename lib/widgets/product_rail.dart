import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../data/models.dart';
import '../theme/app_spacing.dart';
import '../theme/app_tokens.dart';
import '../theme/layout_constants.dart';
import 'app_card.dart';
import '../pages/product_page.dart';
import '../localization/app_language.dart';
import '../localization/app_strings.dart';
import '../localization/bilingual_text.dart';

enum ProductRailSize { large, medium, small, compact }

class ProductRail extends StatelessWidget {
  final List<Product> products;
  final ProductRailSize size;
  final String? badgeText;
  final String? ctaText;
  final bool dim; // tone: dim
  final bool showReleaseDate;
  final VoidCallback? onTapViewAll;
  final AppLanguage? lang;
  final bool useCardFrame;

  const ProductRail({
    super.key,
    required this.products,
    this.size = ProductRailSize.medium,
    this.badgeText,
    this.ctaText,
    this.dim = false,
    this.showReleaseDate = false,
    this.onTapViewAll,
    this.lang,
    this.useCardFrame = true,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final effectiveLang = lang ?? AppLanguage.zhTw;

    // 根據螢幕寬度動態計算，iPad 上 clamp 住不會過大
    final screenWidth = MediaQuery.of(context).size.width;

    final cardWidth = switch (size) {
      ProductRailSize.large => (screenWidth * 0.45).clamp(180.0, kMaxCardWidth),
      ProductRailSize.medium =>
        (screenWidth * 0.45).clamp(180.0, kMaxCardWidth),
      ProductRailSize.small =>
        (screenWidth * 0.55).clamp(180.0, kMaxSmallCardWidth),
      // 新上架 compact：再放大，約 2.0~2.2 張 / 列
      ProductRailSize.compact => (screenWidth * 0.42).clamp(148.0, 188.0),
    };

    final imageHeight = cardWidth / kCoverAspectRatio;

    // 文字區高度：需足夠容納 2 行標題 + 副標 + CTA + padding
    final textAreaHeight = switch (size) {
      ProductRailSize.large => 100.0, // padding 8*2=16, 內容≤84
      ProductRailSize.medium => 80.0, // padding 8*2=16, 內容≤64
      ProductRailSize.small => 80.0, // padding 8*2=16, 內容≤64
      // compact 僅有頂部標籤列，其餘由圖片高度決定
      ProductRailSize.compact => 32.0,
    };

    final height = imageHeight + textAreaHeight;

    final titleFontSize = switch (size) {
      ProductRailSize.large => 16.0,
      ProductRailSize.medium => 16.0,
      ProductRailSize.small => 14.0,
      ProductRailSize.compact => 12.0,
    };

    final subtitleFontSize = switch (size) {
      ProductRailSize.large => 14.0,
      ProductRailSize.medium => 12.0,
      ProductRailSize.small => 12.0,
      ProductRailSize.compact => 10.0,
    };
    final itemSpacing =
        size == ProductRailSize.compact ? AppSpacing.xs : AppSpacing.sm;

    if (size == ProductRailSize.compact && onTapViewAll == null) {
      final compactCardHeight = imageHeight + 28;
      final rowHeight = compactCardHeight;

      final topRow = <Product>[];
      final bottomRow = <Product>[];

      for (var i = 0; i < products.length; i++) {
        if (i.isEven) {
          topRow.add(products[i]);
        } else {
          bottomRow.add(products[i]);
        }
      }

      Widget buildCompactCard(Product p) {
        void onCompactTap() {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ProductPage(productId: p.id)),
          );
        }

        return SizedBox(
          width: cardWidth,
          height: compactCardHeight,
          child: GestureDetector(
            onTap: onCompactTap,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: tokens.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                boxShadow: tokens.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    color: tokens.primary,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      productTitle(p, effectiveLang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: tokens.textOnPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  if (p.coverImageUrl != null && p.coverImageUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: p.coverImageUrl!,
                      width: double.infinity,
                      height: imageHeight,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      placeholder: (context, url) => Container(
                        height: imageHeight,
                        color: tokens.chipBg,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: imageHeight,
                        color: tokens.chipBg,
                        child: Icon(
                          Icons.image_not_supported,
                          color: tokens.textSecondary,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: imageHeight,
                      color: tokens.chipBg,
                      child: Icon(
                        Icons.auto_awesome,
                        color: tokens.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: rowHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topRow.length,
              separatorBuilder: (_, __) => SizedBox(width: itemSpacing),
              itemBuilder: (context, index) {
                return buildCompactCard(topRow[index]);
              },
            ),
          ),
          SizedBox(height: itemSpacing),
          SizedBox(
            height: rowHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: bottomRow.length,
              separatorBuilder: (_, __) => SizedBox(width: itemSpacing),
              itemBuilder: (context, index) {
                return buildCompactCard(bottomRow[index]);
              },
            ),
          ),
        ],
      );
    }

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length + (onTapViewAll != null ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(width: itemSpacing),
        itemBuilder: (context, i) {
          // 最後一個項目是「查看全部」按鈕
          if (onTapViewAll != null && i == products.length) {
            return SizedBox(
              width: cardWidth,
              child: AppCard(
                onTap: onTapViewAll,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward,
                          color: tokens.primary, size: 32),
                      const SizedBox(height: 8),
                      Text(uiString(effectiveLang, 'view_all_label'),
                          style: TextStyle(
                              color: tokens.primary,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            );
          }

          final p = products[i];
          final dt = p.releaseAt;
          final badge = badgeText != null
              ? (showReleaseDate && dt != null
                  ? '${dt.month}/${dt.day}'
                  : badgeText!)
              : null;

          void onItemTap() {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProductPage(productId: p.id)),
            );
          }

          final cardChild = SizedBox(
            width: cardWidth,
            height: height,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 封面圖片：上半部圖片 + ColorFiltered tint（保留 neon accent 氛圍）
                    if (p.coverImageUrl != null && p.coverImageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSpacing.radiusMd)),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            tokens.primary.withValues(alpha: 0.22),
                            BlendMode.softLight,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: p.coverImageUrl!,
                            width: double.infinity,
                            height: imageHeight,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            placeholder: (context, url) => Container(
                              height: imageHeight,
                              color: tokens.chipBg,
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: imageHeight,
                              color: tokens.chipBg,
                              child: Icon(Icons.image_not_supported,
                                  color: tokens.textSecondary),
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        height: imageHeight,
                        color: tokens.chipBg,
                        child: Icon(Icons.auto_awesome,
                            color: tokens.textSecondary),
                      ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(size == ProductRailSize.small
                            ? AppSpacing.xs
                            : AppSpacing.xs),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    productTitle(p, effectiveLang),
                                    maxLines:
                                        size == ProductRailSize.small ? 2 : 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w900,
                                      color: tokens.textPrimary
                                          .withValues(alpha: dim ? 0.75 : 1.0),
                                    ),
                                  ),
                                ),
                                // Badge 在內容區（非 small size 時）
                                if (badge != null &&
                                    size != ProductRailSize.small) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.xs,
                                        vertical: AppSpacing.xs),
                                    decoration: BoxDecoration(
                                      color: tokens.primaryBright,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                          color: tokens.primary
                                              .withValues(alpha: 0.35)),
                                    ),
                                    child: Text(
                                      badge,
                                      style: TextStyle(
                                        color: tokens.textOnPrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Flexible(
                              child: Text('${p.topicId} · ${p.level}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: tokens.textSecondary
                                        .withValues(alpha: dim ? 0.65 : 1.0),
                                  )),
                            ),
                            if (dim && showReleaseDate) ...[
                              const SizedBox(height: 8),
                              Text(
                                dt == null
                                    ? uiString(
                                        effectiveLang, 'coming_soon_label')
                                    : uiString(
                                            effectiveLang, 'release_date_label')
                                        .replaceFirst('{date}',
                                            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: tokens.textSecondary
                                      .withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            if (ctaText != null) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  ctaText!,
                                  style: TextStyle(
                                    color: tokens.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize:
                                        size == ProductRailSize.small ? 12 : 14,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Badge 在左上角（small size 或特定樣式）
                if (badge != null && size == ProductRailSize.small)
                  Positioned(
                    top: AppSpacing.xs,
                    left: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: tokens.primaryBright,
                        border: Border.all(
                            color: tokens.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: tokens.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );

          if (useCardFrame) {
            return AppCard(
              padding: EdgeInsets.zero,
              onTap: onItemTap,
              child: cardChild,
            );
          }

          return GestureDetector(
            onTap: onItemTap,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: tokens.cardBg.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(tokens.cardRadius),
              ),
              child: cardChild,
            ),
          );
        },
      ),
    );
  }
}
