import 'package:flutter/material.dart';

class SensorCard extends StatefulWidget {
  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.gradientColors,
    this.isUnavailable = false,
    this.highlightColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final String? subtitle;
  final List<Color>? gradientColors;
  final bool isUnavailable;
  final Color? highlightColor;

  @override
  State<SensorCard> createState() => _SensorCardState();
}

class _SensorCardState extends State<SensorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = widget.gradientColors ??
        [
          theme.colorScheme.primaryContainer,
          theme.colorScheme.secondaryContainer,
        ];

    final cardColor = widget.highlightColor ?? colors.first;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shadowColor: cardColor.withValues(alpha: 0.4),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.isUnavailable
                    ? [
                        theme.colorScheme.surfaceContainerHighest,
                        theme.colorScheme.surfaceContainerHigh,
                      ]
                    : colors,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.isUnavailable
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onPrimaryContainer,
                          size: 28,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.isUnavailable
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: widget.isUnavailable
                          ? theme.colorScheme.error
                          : theme.colorScheme.onPrimaryContainer
                              .withValues(alpha: 0.85),
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
