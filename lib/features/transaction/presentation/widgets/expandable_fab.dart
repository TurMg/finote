import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class ExpandableFab extends StatefulWidget {
  final VoidCallback onManual;
  final VoidCallback onScan;
  final VoidCallback onVoice;

  const ExpandableFab({
    super.key,
    required this.onManual,
    required this.onScan,
    required this.onVoice,
  });

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    if (_isOpen) {
      _overlayEntry?.remove();
    }
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _controller.reverse().then((_) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        if (mounted) setState(() => _isOpen = false);
      });
    } else {
      setState(() => _isOpen = true);
      _showOverlay();
      _controller.forward();
    }
  }

  void _executeAction(VoidCallback action) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _controller.reset();
    if (mounted) setState(() => _isOpen = false);
    action();
  }

  void _showOverlay() {
    // 1. Radar Absolut: Lacak titik presisi tombol FAB lu di seluruh layar
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    // 2. Tentukan titik episentrum (tengah) dari tombol FAB asli (56 dibagi 2 = 28)
    final centerX = offset.dx + 28.0;
    final centerY = offset.dy + 28.0;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Background redup penangkap klik luar
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggle,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),
            ),

            // Mesin penggerak koordinat secara real-time
            AnimatedBuilder(
              animation: _expandAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Tombol Suara (Kiri Atas)
                    _buildAbsoluteAction(
                        Icons.mic_rounded,
                        const Color(0xFF4A90E2),
                        widget.onVoice,
                        centerX,
                        centerY,
                        -55,
                        -55),

                    // Tombol Kamera (Vertikal Atas)
                    _buildAbsoluteAction(
                        Icons.document_scanner_rounded,
                        AppColors.primary,
                        widget.onScan,
                        centerX,
                        centerY,
                        0,
                        -75),

                    // Tombol Manual (Kanan Atas)
                    _buildAbsoluteAction(
                        Icons.edit_rounded,
                        const Color(0xFFF5A623),
                        widget.onManual,
                        centerX,
                        centerY,
                      55,
                        -55),

                    // Tombol Utama (Replika yang menimpa tombol asli)
                    Positioned(
                      left: offset.dx,
                      top: offset.dy,
                      child: GestureDetector(
                        onTap: _toggle,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                          child: Center(
                            child: Transform.rotate(
                              angle:
                                  _controller.value * 0.785398, // Putar jadi X
                              child: const Icon(Icons.add_rounded,
                                  color: Colors.white, size: 32),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildAbsoluteAction(
      IconData icon,
      Color color,
      VoidCallback action,
      double startX,
      double startY,
      double targetOffsetX,
      double targetOffsetY) {
    // 24 adalah setengah dari ukuran tombol aksi (48px) agar sentral koordinatnya pas di tengah
    final currentX = startX - 24.0 + (targetOffsetX * _expandAnimation.value);
    final currentY = startY - 24.0 + (targetOffsetY * _expandAnimation.value);

    return Positioned(
      left: currentX,
      top: currentY,
      child: Opacity(
        opacity: _expandAnimation.value,
        child: GestureDetector(
          onTap: () => _executeAction(action),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'main_fab_base',
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      onPressed: _toggle,
      child: const Icon(Icons.add_rounded, size: 32),
    );
  }
}
