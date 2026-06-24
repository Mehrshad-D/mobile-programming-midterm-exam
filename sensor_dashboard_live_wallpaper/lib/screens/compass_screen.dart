import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensor_dashboard_live_wallpaper/services/sensor_service.dart';
import 'package:sensor_dashboard_live_wallpaper/widgets/live_background.dart';

class CompassScreen extends StatelessWidget {
  const CompassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SensorService.instance,
      builder: (context, _) {
        final service = SensorService.instance;
        final theme = Theme.of(context);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('Compass'),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
            ),
          ),
          body: LiveBackground(
            child: SafeArea(
              child: service.compassAvailable && service.heading != null
                  ? _CompassView(
                      heading: service.heading!,
                      direction: service.compassDirection,
                    )
                  : _UnavailableView(message: service.compassMessage),
            ),
          ),
        );
      },
    );
  }
}

class _CompassView extends StatelessWidget {
  const _CompassView({
    required this.heading,
    required this.direction,
  });

  final double heading;
  final String direction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surface.withValues(alpha: 0.7),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                CustomPaint(
                  size: const Size(260, 260),
                  painter: _CompassDialPainter(theme: theme),
                ),
                Transform.rotate(
                  angle: -heading * math.pi / 180,
                  child: CustomPaint(
                    size: const Size(260, 260),
                    painter: _CompassNeedlePainter(theme: theme),
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Text(
            '${heading.toStringAsFixed(0)}°',
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            direction,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  _CompassDialPainter({required this.theme});

  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final directions = ['N', 'E', 'S', 'W'];
    for (var i = 0; i < 4; i++) {
      final angle = (i * 90 - 90) * math.pi / 180;
      final textOffset = Offset(
        center.dx + (radius - 30) * math.cos(angle),
        center.dy + (radius - 30) * math.sin(angle),
      );
      final tp = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: i == 0
                ? Colors.red
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        textOffset - Offset(tp.width / 2, tp.height / 2),
      );
    }

    for (var i = 0; i < 360; i += 30) {
      final angle = (i - 90) * math.pi / 180;
      final isMajor = i % 90 == 0;
      final innerR = radius - (isMajor ? 20 : 12);
      final outerR = radius - 4;
      final p1 = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );
      final p2 = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = theme.colorScheme.onSurface.withValues(alpha: 0.5)
          ..strokeWidth = isMajor ? 2 : 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CompassNeedlePainter extends CustomPainter {
  _CompassNeedlePainter({required this.theme});

  final ThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final path = Path()
      ..moveTo(center.dx, center.dy - 100)
      ..lineTo(center.dx - 8, center.dy)
      ..lineTo(center.dx, center.dy + 40)
      ..lineTo(center.dx + 8, center.dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = Colors.red.shade600,
    );

    final southPath = Path()
      ..moveTo(center.dx, center.dy + 40)
      ..lineTo(center.dx - 6, center.dy + 80)
      ..lineTo(center.dx + 6, center.dy + 80)
      ..close();

    canvas.drawPath(
      southPath,
      Paint()..color = theme.colorScheme.onSurfaceVariant,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _UnavailableView extends StatelessWidget {
  const _UnavailableView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_off,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
