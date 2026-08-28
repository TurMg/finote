import 'package:flutter/material.dart';

/// Widget text reusable yang pasti menganimasikan putaran angka (count-up / count-down)
/// baik saat pertama kali halaman dibuka/pindah tab, maupun saat nilai/ikon mata diubah.
class AnimatedCounterText extends StatefulWidget {
  final double value;
  final String Function(double val) formatter;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final double initialValue;

  const AnimatedCounterText({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.duration = const Duration(milliseconds: 1600),
    this.curve = Curves.easeOutCubic,
    this.initialValue = 0.0,
  });

  @override
  State<AnimatedCounterText> createState() => _AnimatedCounterTextState();
}

class _AnimatedCounterTextState extends State<AnimatedCounterText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _beginValue;
  late double _endValue;

  @override
  void initState() {
    super.initState();
    _beginValue = widget.initialValue;
    _endValue = widget.value;

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: _beginValue, end: _endValue).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // Paksa animasi berjalan saat pertama kali widget di-mount / halaman dibuka
    _controller.forward(from: 0.0);
  }

  @override
  void didUpdateWidget(covariant AnimatedCounterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _beginValue = _animation.value;
      _endValue = widget.value;

      _animation = Tween<double>(begin: _beginValue, end: _endValue).animate(
        CurvedAnimation(parent: _controller, curve: widget.curve),
      );

      _controller.forward(from: 0.0);
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
        return Text(
          widget.formatter(_animation.value),
          style: widget.style,
        );
      },
    );
  }
}
