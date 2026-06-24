import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensor_dashboard_live_wallpaper/services/sensor_service.dart';

class LiveBackground extends StatefulWidget {
  const LiveBackground({
    super.key,
    required this.child,
    this.intensity = 18.0,
  });

  final Widget child;
  final double intensity;

  @override
  State<LiveBackground> createState() => _LiveBackgroundState();
}

class _LiveBackgroundState extends State<LiveBackground>
    with SingleTickerProviderStateMixin {
  double _offsetX = 0;
  double _offsetY = 0;
  double _targetX = 0;
  double _targetY = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_smoothUpdate);
    _controller.repeat();
    SensorService.instance.addListener(_onSensorUpdate);
  }

  void _onSensorUpdate() {
    final service = SensorService.instance;
    _targetX = (service.accelX * widget.intensity * 0.3).clamp(-widget.intensity, widget.intensity);
    _targetY = (service.accelY * widget.intensity * 0.3).clamp(-widget.intensity, widget.intensity);
  }

  void _smoothUpdate() {
    setState(() {
      _offsetX += (_targetX - _offsetX) * 0.08;
      _offsetY += (_targetY - _offsetY) * 0.08;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    SensorService.instance.removeListener(_onSensorUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        Transform.translate(
          offset: Offset(_offsetX, _offsetY),
          child: Transform.scale(
            scale: 1.15,
            child: CustomPaint(
              painter: _ParallaxBackgroundPainter(isDark: isDark),
              size: Size.infinite,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.6),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.4),
                    ],
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _ParallaxBackgroundPainter extends CustomPainter {
  _ParallaxBackgroundPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF0D1B2A),
              const Color(0xFF1B263B),
              const Color(0xFF415A77),
              const Color(0xFF778DA9),
            ]
          : [
              const Color(0xFF667EEA),
              const Color(0xFF764BA2),
              const Color(0xFFF093FB),
              const Color(0xFFF5576C),
            ],
    );

    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    final random = math.Random(42);
    final dotPaint = Paint()
      ..color = (isDark ? Colors.white : Colors.white).withValues(alpha: 0.08);

    for (var i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;
      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = (isDark ? Colors.cyan : Colors.white).withValues(alpha: 0.12);

    for (var w = 0; w < 5; w++) {
      final path = Path();
      final baseY = size.height * (0.2 + w * 0.15);
      path.moveTo(0, baseY);
      for (var x = 0.0; x <= size.width; x += 10) {
        path.lineTo(
          x,
          baseY + math.sin(x * 0.01 + w) * 20,
        );
      }
      canvas.drawPath(path, wavePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParallaxBackgroundPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
