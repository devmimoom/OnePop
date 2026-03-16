import 'package:flutter/material.dart';

/// 可愛雲朵外框的 Home/Plus 按鈕（僅 UI，尚未接任何功能邏輯）。
class CloudHomeButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double width;
  final double height;
  final Widget? icon;

  const CloudHomeButton({
    super.key,
    this.onTap,
    this.width = 72,
    this.height = 52,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 依照明暗主題，微調顏色，讓雲朵在兩種模式下都可愛又清楚。
    final Color cloudFill =
        isDark ? const Color(0xFF151929) : Colors.white; // 主體底色
    final Color cloudBorder = isDark
        ? const Color.fromRGBO(92, 204, 214, 0.70)
        : const Color.fromRGBO(59, 181, 192, 0.70);
    final Color bubbleFill =
        isDark ? const Color(0xFF1C2139) : const Color(0xFFFDFBFF);
    final Color bubbleBorder = cloudBorder;
    final Color iconColor =
        isDark ? const Color(0xFF5CCCD6) : const Color(0xFF3BB5C0);

    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 120),
        tween: Tween(begin: 1, end: 1),
        builder: (context, scale, child) {
          // scale 目前先固定 1，之後如果要做按壓動畫可以接 GestureDetector 的 onTapDown。
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: SizedBox(
          width: width,
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 雲朵主體（圓角矩形）
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: cloudFill,
                    borderRadius: BorderRadius.circular(height * 0.55),
                    border: Border.all(
                      color: cloudBorder,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
                        blurRadius: isDark ? 16 : 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),

              // 左上小圓泡泡
              Positioned(
                left: -width * 0.08,
                top: -height * 0.25,
                child: _CloudBubble(
                  size: height * 0.48,
                  fillColor: bubbleFill,
                  borderColor: bubbleBorder,
                ),
              ),
              // 中上大圓泡泡
              Positioned(
                left: width * 0.25,
                top: -height * 0.32,
                child: _CloudBubble(
                  size: height * 0.60,
                  fillColor: bubbleFill,
                  borderColor: bubbleBorder,
                ),
              ),
              // 右上小圓泡泡
              Positioned(
                right: -width * 0.05,
                top: -height * 0.22,
                child: _CloudBubble(
                  size: height * 0.44,
                  fillColor: bubbleFill,
                  borderColor: bubbleBorder,
                ),
              ),

              // 中央圖示（預設為加號）
              Center(
                child: icon ??
                    Icon(
                      Icons.add,
                      color: iconColor,
                      size: height * 0.52,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloudBubble extends StatelessWidget {
  final double size;
  final Color fillColor;
  final Color borderColor;

  const _CloudBubble({
    required this.size,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fillColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
    );
  }
}

