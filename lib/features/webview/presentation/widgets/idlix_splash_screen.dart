import 'package:flutter/material.dart';

class IdlixSplashScreen extends StatefulWidget {
  final int loadingProgress;
  final bool isFinished;
  final VoidCallback? onDismissed;

  const IdlixSplashScreen({
    super.key,
    required this.loadingProgress,
    required this.isFinished,
    this.onDismissed,
  });

  @override
  State<IdlixSplashScreen> createState() => _IdlixSplashScreenState();
}

class _IdlixSplashScreenState extends State<IdlixSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _letterSpacingAnimation;

  bool _canDismiss = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
    ]).animate(_animController);

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.6)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
    ]).animate(_animController);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _letterSpacingAnimation = Tween<double>(begin: 2.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _animController.forward().then((_) {
      if (mounted) {
        setState(() {
          _canDismiss = true;
        });
        if (widget.isFinished) {
          widget.onDismissed?.call();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant IdlixSplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFinished && _canDismiss && !oldWidget.isFinished) {
      widget.onDismissed?.call();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF090B10), // Deep Netflix dark background
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. Cinematic Red Ambient Radial Glow (Netflix-style flare)
              Transform.scale(
                scale: _scaleAnimation.value * 1.5,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFE50914).withValues(alpha: 0.35 * _glowAnimation.value),
                        const Color(0xFFE50914).withValues(alpha: 0.12 * _glowAnimation.value),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // 2. Main Center Animated Logo & Typography
              Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Iconic Ribbon "I" and Play Symbol
                      _buildCinematicLogoBadge(),
                      const SizedBox(height: 22),

                      // "IDLIX" Bold Title with Red Gradient
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.white, Color(0xFFFFD4D7), Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds),
                        child: Text(
                          'IDLIX',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: _letterSpacingAnimation.value,
                            shadows: [
                              Shadow(
                                color: const Color(0xFFE50914).withValues(alpha: 0.8),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle "STREAMING CINEMA"
                      Text(
                        'STREAMING CINEMA',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: _letterSpacingAnimation.value * 0.7,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Subtle Bottom Loading Progress
              Positioned(
                bottom: 48,
                left: 48,
                right: 48,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 3,
                        color: Colors.white10,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: MediaQuery.of(context).size.width *
                                ((widget.loadingProgress.clamp(5, 100)) / 100.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE50914), Color(0xFFFF4151)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE50914).withValues(alpha: 0.8),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.loadingProgress >= 100
                          ? 'Membuka IDLIX...'
                          : 'Memuat... ${widget.loadingProgress}%',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCinematicLogoBadge() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE50914).withValues(alpha: 0.8),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE50914).withValues(alpha: 0.45),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.9),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vertical Ribbon "I"
          Positioned(
            left: 24,
            top: 20,
            bottom: 20,
            child: Container(
              width: 14,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF2434), Color(0xFFB5040D)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          // Glowing Play Triangle
          Positioned(
            right: 22,
            child: CustomPaint(
              size: const Size(26, 26),
              painter: _PlayTrianglePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height / 2)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
