import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BubbleWelcomePage extends StatefulWidget {
  const BubbleWelcomePage({super.key, required this.onFinished});
  final VoidCallback onFinished;

  @override
  State<BubbleWelcomePage> createState() => _BubbleWelcomePageState();
}

class _BubbleWelcomePageState extends State<BubbleWelcomePage>
    with TickerProviderStateMixin {
  late final AnimationController _breathCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  late final AnimationController _popCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  final AudioPlayer _player = AudioPlayer();
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    _player.setSource(AssetSource('sfx/pop_01.wav'));
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _popCtrl.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_popped) return;
    setState(() => _popped = true);

    HapticFeedback.lightImpact();
    // ignore: unawaited_futures
    _player.play(AssetSource('sfx/pop_01.wav'), volume: 0.75);

    await _popCtrl.forward();
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Premium gradient background
          const _PremiumBackground(),

          // Floating bubbles
          const _FloatingBubbles(),

          // Rotating rings
          const _RotatingRings(),

          // Accent dots
          const _AccentDots(),

          // Center interactive bubble
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _onTap,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_breathCtrl, _popCtrl]),
                    builder: (_, __) {
                      final breath = 1.0 + (_breathCtrl.value * 0.03);
                      final t = _popCtrl.value;
                      final popT = Curves.easeOutCubic.transform(t);

                      double scale = breath;
                      double opacity = 1.0;

                      if (_popped) {
                        if (t < 0.15) {
                          scale = lerpDouble(breath, 0.96, t / 0.15)!;
                        } else {
                          scale = lerpDouble(0.96, 1.08, (t - 0.15) / 0.85)!;
                          opacity = lerpDouble(1.0, 0.0, popT)!;
                        }
                      }

                      return SizedBox(
                        width: min(size.width * 0.45, 180),
                        height: min(size.width * 0.45, 180),
                        child: Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: scale,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const _CenterBubble(),
                                if (_popped) _PopBurst(progress: t),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 60),

                // Brand text
                AnimatedOpacity(
                  opacity: _popped ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: const Column(
                    children: [
                      Text(
                        'OnePop',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Your mental snack',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xCCFFFFFF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'One pop',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xCCFFFFFF),
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          _TaglineSeparator(),
                          SizedBox(width: 8),
                          Text(
                            'One moment',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xCCFFFFFF),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Subtle glow effect
          if (!_popped) const _CenterGlow(),
        ],
      ),
    );
  }
}

// Premium gradient background
class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0E27),
            Color(0xFF1A2642),
            Color(0xFF0F1629),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}

// Floating bubbles (7 bubbles with different sizes)
class _FloatingBubbles extends StatefulWidget {
  const _FloatingBubbles();

  @override
  State<_FloatingBubbles> createState() => _FloatingBubblesState();
}

class _FloatingBubblesState extends State<_FloatingBubbles>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      7,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 18000 + (i * 1000)),
      )..repeat(),
    );
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubbles = [
      _BubbleData(size: 180, top: 0.15, left: 0.5, controller: _controllers[0]),
      _BubbleData(size: 120, top: 0.08, left: 0.85, controller: _controllers[1]),
      _BubbleData(size: 80, top: 0.65, left: 0.08, controller: _controllers[2]),
      _BubbleData(size: 100, top: 0.75, left: 0.88, controller: _controllers[3]),
      _BubbleData(size: 60, top: 0.25, left: 0.15, controller: _controllers[4]),
      _BubbleData(size: 90, top: 0.12, left: 0.1, controller: _controllers[5]),
      _BubbleData(size: 70, top: 0.85, left: 0.2, controller: _controllers[6]),
    ];

    return Stack(
      children: bubbles.map((data) => _AnimatedBubble(data: data)).toList(),
    );
  }
}

class _BubbleData {
  final double size;
  final double top;
  final double left;
  final AnimationController controller;

  _BubbleData({
    required this.size,
    required this.top,
    required this.left,
    required this.controller,
  });
}

class _AnimatedBubble extends StatelessWidget {
  const _AnimatedBubble({required this.data});
  final _BubbleData data;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: data.controller,
      builder: (context, child) {
        final t = data.controller.value;

        // Calculate floating movement
        double dx = sin(t * 2 * pi) * 20;
        double dy = -cos(t * 2 * pi) * 30;
        double scale = 1.0 + sin(t * 2 * pi) * 0.1;
        double opacity = 0.6 + sin(t * 2 * pi) * 0.2;

        return Positioned(
          top: size.height * data.top + dy,
          left: size.width * data.left + dx - data.size / 2,
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: data.size,
                height: data.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF667EEA).withOpacity(0.15),
                      const Color(0xFF667EEA).withOpacity(0.05),
                    ],
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Rotating rings
class _RotatingRings extends StatefulWidget {
  const _RotatingRings();

  @override
  State<_RotatingRings> createState() => _RotatingRingsState();
}

class _RotatingRingsState extends State<_RotatingRings>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring (clockwise)
              Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // Inner ring (counter-clockwise)
              Transform.rotate(
                angle: -_controller.value * 2 * pi * 1.5,
                child: Container(
                  width: 196,
                  height: 196,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF667EEA).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Center interactive bubble
class _CenterBubble extends StatelessWidget {
  const _CenterBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          const BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Shine effect
          Positioned(
            top: 30,
            left: 40,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.6),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          // Secondary shine
          Positioned(
            bottom: 35,
            right: 40,
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Accent dots (pulsing)
class _AccentDots extends StatefulWidget {
  const _AccentDots();

  @override
  State<_AccentDots> createState() => _AccentDotsState();
}

class _AccentDotsState extends State<_AccentDots>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      )..repeat(reverse: true),
    );

    // Stagger the animations
    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: i * 700), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dots = [
      {'top': 0.20, 'left': 0.20, 'index': 0},
      {'top': 0.25, 'left': 0.75, 'index': 1},
      {'top': 0.70, 'left': 0.25, 'index': 2},
      {'top': 0.72, 'left': 0.78, 'index': 3},
    ];

    return Stack(
      children: dots.map((dot) {
        return AnimatedBuilder(
          animation: _controllers[dot['index'] as int],
          builder: (context, child) {
            final opacity =
                0.4 + _controllers[dot['index'] as int].value * 0.6;
            final scale = 1.0 + _controllers[dot['index'] as int].value * 0.5;

            return Positioned(
              top: size.height * (dot['top'] as double),
              left: size.width * (dot['left'] as double),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF667EEA).withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

// Center glow effect
class _CenterGlow extends StatefulWidget {
  const _CenterGlow();

  @override
  State<_CenterGlow> createState() => _CenterGlowState();
}

class _CenterGlowState extends State<_CenterGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final opacity = 0.5 + _controller.value * 0.3;
          final scale = 1.0 + _controller.value * 0.1;

          return Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF667EEA).withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Tagline separator dot
class _TaglineSeparator extends StatelessWidget {
  const _TaglineSeparator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF667EEA).withOpacity(0.6),
      ),
    );
  }
}

// Pop burst effect
class _PopBurst extends StatelessWidget {
  const _PopBurst({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PopPainter(progress),
      child: const SizedBox.expand(),
    );
  }
}

class _PopPainter extends CustomPainter {
  _PopPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    // Ring
    final ringP = Curves.easeOutExpo.transform(t);
    final ringR = (size.width * 0.35) + ringP * (size.width * 0.30);
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = lerpDouble(2.2, 0.0, ringP)!
      ..color = Color.lerp(
        const Color(0x66FFFFFF),
        const Color(0x00FFFFFF),
        ringP,
      )!;
    canvas.drawCircle(c, ringR, ringPaint);

    // Particles
    final particlePaint = Paint()..color = const Color(0x55FFFFFF);
    const count = 20;
    for (int i = 0; i < count; i++) {
      final ang = (i / count) * pi * 2;
      final dist = ringP * (size.width * 0.32);
      final p = c + Offset(cos(ang), sin(ang)) * dist;
      final pr = lerpDouble(4.2, 0.0, ringP)!;
      canvas.drawCircle(p, pr, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PopPainter oldDelegate) => oldDelegate.t != t;
}
