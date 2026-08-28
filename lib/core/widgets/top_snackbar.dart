import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

enum TopSnackBarType { success, error, info }

class TopSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    TopSnackBarType type = TopSnackBarType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _TopSnackBarWidget(
        message: message,
        type: type,
        duration: duration,
        onDismissed: () => overlayEntry.remove(),
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

class _TopSnackBarWidget extends StatefulWidget {
  final String message;
  final TopSnackBarType type;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopSnackBarWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    ));

    _showAndHide();
  }

  Future<void> _showAndHide() async {
    // Trigger haptic vibration & tampilkan snackbar
    HapticFeedback.mediumImpact();
    await _controller.forward();
    
    // Tunggu durasi
    await Future.delayed(widget.duration);
    
    // Hilang jika belum di-dispose
    if (mounted) {
      await _controller.reverse();
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color glowColor;
    IconData icon;
    
    switch (widget.type) {
      case TopSnackBarType.success:
        glowColor = const Color(0xFF16A34A); // Hijau
        icon = Icons.check_circle_rounded;
        break;
      case TopSnackBarType.error:
        glowColor = const Color(0xFFDC2626); // Merah
        icon = Icons.error_rounded;
        break;
      case TopSnackBarType.info:
        glowColor = const Color(0xFF3B82F6); // Biru
        icon = Icons.info_rounded;
        break;
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: glowColor.withOpacity(0.95), // Solid status color (agak transparan dikit buat glass effect)
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25), // Lingkaran putih transparan
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white, // Teks putih agar kontras di atas background warna
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
