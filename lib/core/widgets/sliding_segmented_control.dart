import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';

/// Widget segmented control reusable dengan indikator kapsul aktif
/// yang meluncur (sliding) secara fisik & smooth antar item.
class SlidingSegmentedControl<T> extends StatelessWidget {
  final T selectedValue;
  final List<T> items;
  final String Function(T item) labelBuilder;
  final Widget Function(T item, bool isActive)? customItemBuilder;
  final ValueChanged<T> onChanged;
  final Color? activeColor;
  final Color? backgroundColor;
  final Color? activeTextColor;
  final Color? inactiveTextColor;
  final double height;
  final double padding;
  final double borderRadius;
  final Duration duration;
  final Curve curve;

  const SlidingSegmentedControl({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.customItemBuilder,
    this.activeColor,
    this.backgroundColor,
    this.activeTextColor,
    this.inactiveTextColor,
    this.height = 40,
    this.padding = 3,
    this.borderRadius = 14,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = items.indexOf(selectedValue);
    final safeIndex = selectedIndex < 0 ? 0 : selectedIndex;
    final count = items.length;

    final alignX = count <= 1
        ? 0.0
        : -1.0 + (2.0 * safeIndex / (count - 1));

    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final effectiveBgColor = backgroundColor ?? AppColors.surfaceSubtle;

    return Container(
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / count;

          return Stack(
            children: [
              // Sliding Active Pill Background
              AnimatedAlign(
                duration: duration,
                curve: curve,
                alignment: Alignment(alignX, 0),
                child: Container(
                  width: itemWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: effectiveActiveColor,
                    borderRadius: BorderRadius.circular(borderRadius - (padding / 2)),
                    boxShadow: [
                      BoxShadow(
                        color: effectiveActiveColor.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive Text / Custom Widget Row
              Row(
                children: items.map((item) {
                  final isActive = item == selectedValue;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onChanged(item);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        child: customItemBuilder != null
                            ? customItemBuilder!(item, isActive)
                            : AnimatedDefaultTextStyle(
                                duration: duration,
                                curve: curve,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                                  color: isActive
                                      ? (activeTextColor ?? Colors.white)
                                      : (inactiveTextColor ?? AppColors.textSecondary),
                                ),
                                child: Text(
                                  labelBuilder(item),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
