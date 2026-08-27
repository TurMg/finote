import 'dart:math';
import 'package:flutter/material.dart';

/// Widget untuk memberikan efek getar (shake) kiri-kanan
/// biasa digunakan untuk validasi error pada form.
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final bool shake;

  const ShakeWidget({
    super.key,
    required this.child,
    required this.shake,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    if (widget.shake) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shake && !oldWidget.shake) {
      // Trigger getaran dari awal
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value;
        final offset = sin(progress * pi * 4) * 8.0; 
        final dx = progress == 1.0 ? 0.0 : offset;

        return Transform.translate(
          offset: Offset(dx, 0),
          child: widget.child,
        );
      },
    );
  }
}
