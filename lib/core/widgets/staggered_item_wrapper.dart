import 'package:flutter/material.dart';

/// Widget wrapper reusable yang memberikan efek animasi masuk bertahap
/// (slide up + fade in) berurutan berdasarkan index posisi elemen.
class StaggeredItemWrapper extends StatelessWidget {
  final int index;
  final Widget child;
  final Duration baseDuration;
  final int maxStaggerIndex;

  const StaggeredItemWrapper({
    super.key,
    required this.index,
    required this.child,
    this.baseDuration = const Duration(milliseconds: 350),
    this.maxStaggerIndex = 8,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIndex = index > maxStaggerIndex ? maxStaggerIndex : index;
    final delayMs = effectiveIndex * 45;

    return FutureBuilder<bool>(
      future: Future.delayed(Duration(milliseconds: delayMs), () => true),
      builder: (context, snapshot) {
        final isReady = snapshot.data == true;

        return AnimatedOpacity(
          duration: baseDuration,
          curve: Curves.easeOutCubic,
          opacity: isReady ? 1.0 : 0.0,
          child: AnimatedSlide(
            duration: baseDuration,
            curve: Curves.easeOutCubic,
            offset: isReady ? Offset.zero : const Offset(0.0, 0.15),
            child: child,
          ),
        );
      },
    );
  }
}
