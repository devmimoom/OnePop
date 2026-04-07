import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../theme/app_spacing.dart';
import '../../../theme/app_tokens.dart';

class DeepDivePageData {
  const DeepDivePageData({
    required this.body,
  });

  final String body;
}

List<DeepDivePageData> buildDeepDivePages(
  String deepAnalysis, {
  int maxPages = 4,
}) {
  final normalized = deepAnalysis.replaceAll('\r\n', '\n').trim();
  if (normalized.isEmpty) return const [];

  var sections = normalized
      .split(RegExp(r'\n\s*\n'))
      .map((section) => section.trim())
      .where((section) => section.isNotEmpty)
      .toList();

  if (sections.length == 1 && sections.first.length > 280) {
    sections = _splitSingleSection(sections.first);
  }

  final targetPages = math.min(
    maxPages,
    math.max(1, (normalized.length / 220).ceil()),
  );
  final groupedSections = _groupSections(sections, targetPages);

  return List.generate(groupedSections.length, (index) {
    final body = groupedSections[index];
    return DeepDivePageData(
      body: body,
    );
  });
}

class DeepDivePager extends StatefulWidget {
  const DeepDivePager({
    super.key,
    required this.deepAnalysis,
    required this.emptyLabel,
    required this.previousPageTooltip,
    required this.nextPageTooltip,
  });

  final String deepAnalysis;
  final String emptyLabel;
  final String previousPageTooltip;
  final String nextPageTooltip;

  @override
  State<DeepDivePager> createState() => _DeepDivePagerState();
}

class _DeepDivePagerState extends State<DeepDivePager> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.97);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DeepDivePager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deepAnalysis != widget.deepAnalysis) {
      _currentPage = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  void _animateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final pages = buildDeepDivePages(widget.deepAnalysis);

    if (pages.isEmpty) {
      return Text(
        widget.emptyLabel,
        style: TextStyle(color: tokens.textSecondary),
      );
    }

    final maxBodyLength =
        pages.map((page) => page.body.length).fold<int>(0, math.max);
    final pageHeight =
        ((384 + (maxBodyLength * 0.24)).clamp(440.0, 648.0) * 1.3).toDouble();
    final safeCurrentPage = _currentPage.clamp(0, pages.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: pageHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            padEnds: false,
            onPageChanged: (index) {
              if (_currentPage == index) return;
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final page = pages[index];
              return AnimatedBuilder(
                animation: _pageController,
                child: _DeepDiveSheet(
                  page: page,
                  index: index,
                  total: pages.length,
                ),
                builder: (context, child) {
                  final controllerPage = _pageController.hasClients &&
                          _pageController.position.hasContentDimensions
                      ? (_pageController.page ?? safeCurrentPage.toDouble())
                      : safeCurrentPage.toDouble();
                  final pageDelta =
                      (controllerPage - index).clamp(-1.0, 1.0).toDouble();
                  final distance = pageDelta.abs();
                  final rotationY = pageDelta * -0.4;
                  final scale = lerpDouble(0.94, 1, 1 - distance) ?? 1;
                  final opacity = lerpDouble(0.6, 1, 1 - distance) ?? 1;
                  final dx = lerpDouble(24, 0, 1 - distance) ?? 0;
                  final lift = lerpDouble(10, 0, 1 - distance) ?? 0;
                  final alignment = pageDelta >= 0
                      ? Alignment.centerRight
                      : Alignment.centerLeft;

                  return Transform.translate(
                    offset: Offset(pageDelta >= 0 ? dx : -dx, lift),
                    child: Transform(
                      alignment: alignment,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0018)
                        ..rotateY(rotationY)
                        ..multiply(Matrix4.diagonal3Values(scale, scale, 1)),
                      child: Opacity(
                        opacity: opacity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            child!,
                            IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: pageDelta >= 0
                                        ? Alignment.centerLeft
                                        : Alignment.centerRight,
                                    end: pageDelta >= 0
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    stops: const [0, 0.45, 1],
                                    colors: [
                                      Colors.black.withValues(
                                        alpha: 0.08 * distance,
                                      ),
                                      Colors.transparent,
                                      Colors.white.withValues(
                                        alpha: 0.03 * (1 - distance),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _PagerArrowButton(
              icon: Icons.arrow_back_ios_new_rounded,
              tooltip: widget.previousPageTooltip,
              enabled: safeCurrentPage > 0,
              onPressed: () => _animateToPage(safeCurrentPage - 1),
            ),
            Expanded(
              child: Row(
                children: List.generate(
                  pages.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == pages.length - 1 ? 0 : 6,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: index == safeCurrentPage
                              ? tokens.primaryBright
                              : tokens.cardBorder,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _PagerArrowButton(
              icon: Icons.arrow_forward_ios_rounded,
              tooltip: widget.nextPageTooltip,
              enabled: safeCurrentPage < pages.length - 1,
              onPressed: () => _animateToPage(safeCurrentPage + 1),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeepDiveSheet extends StatelessWidget {
  const _DeepDiveSheet({
    required this.page,
    required this.index,
    required this.total,
  });

  final DeepDivePageData page;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: tokens.primaryPale.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${index + 1} / $total',
                style: TextStyle(
                  color: tokens.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  scrollbars: false,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        page.body,
                        style: TextStyle(
                          color: tokens.textPrimary,
                          height: 1.55,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PagerArrowButton extends StatelessWidget {
  const _PagerArrowButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: enabled
                ? tokens.primaryPale.withValues(alpha: 0.7)
                : tokens.cardBorder.withValues(alpha: 0.4),
          ),
          child: Icon(
            icon,
            size: 18,
            color: enabled ? tokens.textPrimary : tokens.textMuted,
          ),
        ),
      ),
    );
  }
}

List<String> _splitSingleSection(String text) {
  final sentences = text
      .split(RegExp(r'(?<=[。！？.!?])\s+'))
      .map((sentence) => sentence.trim())
      .where((sentence) => sentence.isNotEmpty)
      .toList();

  if (sentences.length <= 1) {
    return _chunkByLength(text, maxChunkLength: 220);
  }

  final targetLength = math.max(120, (text.length / 3).ceil());
  final chunks = <String>[];
  final buffer = StringBuffer();

  for (final sentence in sentences) {
    final nextText =
        buffer.isEmpty ? sentence : '${buffer.toString()} $sentence';
    if (buffer.isNotEmpty && nextText.length > targetLength) {
      chunks.add(buffer.toString().trim());
      buffer.clear();
      buffer.write(sentence);
    } else {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(sentence);
    }
  }

  if (buffer.isNotEmpty) {
    chunks.add(buffer.toString().trim());
  }

  return chunks.where((chunk) => chunk.isNotEmpty).toList();
}

List<String> _groupSections(List<String> sections, int targetPages) {
  if (sections.isEmpty) return const [];
  if (sections.length <= targetPages) return sections;

  final totalLength =
      sections.fold<int>(0, (sum, section) => sum + section.length);
  final targetLength = (totalLength / targetPages).ceil();
  final groups = <String>[];
  final buffer = <String>[];
  var currentLength = 0;

  for (var i = 0; i < sections.length; i++) {
    final section = sections[i];
    final remainingSections = sections.length - i - 1;
    final remainingGroups = targetPages - groups.length - 1;

    buffer.add(section);
    currentLength += section.length;

    final shouldCloseGroup =
        currentLength >= targetLength && remainingSections >= remainingGroups;

    if (shouldCloseGroup) {
      groups.add(buffer.join('\n\n'));
      buffer.clear();
      currentLength = 0;
    }
  }

  if (buffer.isNotEmpty) {
    groups.add(buffer.join('\n\n'));
  }

  return groups;
}

List<String> _chunkByLength(
  String text, {
  required int maxChunkLength,
}) {
  final chunks = <String>[];
  var remaining = text.trim();

  while (remaining.isNotEmpty) {
    if (remaining.length <= maxChunkLength) {
      chunks.add(remaining);
      break;
    }

    var splitAt = remaining.lastIndexOf(' ', maxChunkLength);
    if (splitAt < maxChunkLength * 0.55) {
      splitAt = maxChunkLength;
    }

    chunks.add(remaining.substring(0, splitAt).trim());
    remaining = remaining.substring(splitAt).trim();
  }

  return chunks.where((chunk) => chunk.isNotEmpty).toList();
}
