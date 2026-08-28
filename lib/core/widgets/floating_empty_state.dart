import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Widget empty state dengan animasi bernafas/melayang (floating pulse)
/// yang memberikan kesan dinamis saat data/layar sedang kosong.
class FloatingEmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final double iconSize;

  const FloatingEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
    this.iconSize = 64,
  });

  @override
  State<FloatingEmptyState> createState() => _FloatingEmptyStateState();
}

class _FloatingEmptyStateState extends State<FloatingEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _translateAnimation = Tween<double>(begin: 0.0, end: -8.0).animate(
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
    final effectiveIconColor = widget.iconColor ?? AppColors.textSecondary.withOpacity(0.4);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _translateAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _translateAnimation.value),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: widget.iconSize,
                  color: effectiveIconColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
