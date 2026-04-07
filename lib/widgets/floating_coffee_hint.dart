import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// 可拖曳的咖啡圖 + 點擊顯示的說明氣泡，供主畫面與圖書館頁共用。
class FloatingCoffeeHint extends StatelessWidget {
  const FloatingCoffeeHint({
    super.key,
    required this.coffeeLeft,
    required this.coffeeTop,
    required this.maxWidth,
    required this.showBubble,
    required this.message,
    required this.onCoffeeTap,
    required this.onBubbleTap,
    required this.onPanUpdate,
    required this.tokens,
    this.onDoubleTap,
    this.size = 180.0,
    this.margin = 16.0,
  });

  final double coffeeLeft;
  final double coffeeTop;
  final double maxWidth;
  final bool showBubble;
  final String message;
  final VoidCallback onCoffeeTap;
  final VoidCallback onBubbleTap;
  final void Function(Offset delta) onPanUpdate;
  final AppTokens tokens;
  final VoidCallback? onDoubleTap;
  final double size;
  final double margin;

  static const double _hintBubbleHeight = 80.0;
  static const double _bubbleMaxWidth = 260.0;

  @override
  Widget build(BuildContext context) {
    final hintBubbleTop = coffeeTop - _hintBubbleHeight - 8 >= margin
        ? coffeeTop - _hintBubbleHeight - 8
        : coffeeTop + size + 8;
    final bubbleLeft =
        coffeeLeft.clamp(margin, maxWidth - _bubbleMaxWidth - margin);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: coffeeLeft,
          top: coffeeTop,
          child: GestureDetector(
            onPanUpdate: (details) => onPanUpdate(details.delta),
            onTap: onCoffeeTap,
            onDoubleTap: onDoubleTap,
            child: Image.asset(
              'assets/images/coffee.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
          ),
        ),
        if (showBubble)
          Positioned(
            left: bubbleLeft,
            top: hintBubbleTop,
            child: _HintBubble(
              message: message,
              tokens: tokens,
              onTap: onBubbleTap,
            ),
          ),
      ],
    );
  }
}

class _HintBubble extends StatelessWidget {
  const _HintBubble({
    required this.message,
    required this.tokens,
    required this.onTap,
  });

  final String message;
  final AppTokens tokens;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: tokens.glassBlurSigma,
            sigmaY: tokens.glassBlurSigma,
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFFFFF9E0).withValues(alpha: 0.90),
                  const Color(0xFFFFC0EE).withValues(alpha: 0.90),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFFFC0EE).withValues(alpha: 0.52),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                '"$message"',
                style: const TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 15,
                  height: 1.4,
                  letterSpacing: 0.2,
                  decoration: TextDecoration.none,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
