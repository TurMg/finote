import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/top_snackbar.dart';

class KameraScanPage extends StatelessWidget {
  const KameraScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const KameraScanView();
  }
}

class KameraScanView extends StatefulWidget {
  const KameraScanView({super.key});

  @override
  State<KameraScanView> createState() => _KameraScanViewState();
}

class _KameraScanViewState extends State<KameraScanView> {
  CameraController? _cameraController;
  final _picker = ImagePicker();
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;

  // State untuk Tap-To-Focus
  Offset? _focusPoint;
  bool _showFocusRing = false;
  Timer? _focusTimer;

  @override
  void initState() {
    super.initState();
    _inisialisasiKameraLokal();
  }

  Future<void> _inisialisasiKameraLokal() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high, // Resolusi tinggi agar teks OCR lebih tajam
        enableAudio: false,
      );
      await _cameraController!.initialize();

      // Aktifkan Auto Focus bawaan jika didukung perangkat
      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (_) {}

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        TopSnackBar.show(context, message: 'Gagal inisialisasi hardware kamera: ${e.toString()}', type: TopSnackBarType.error);
      }
    }
  }

  Future<void> _handleTapToFocus(TapDownDetails details, BoxConstraints constraints) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    final double x = (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
    final double y = (details.localPosition.dy / constraints.maxHeight).clamp(0.0, 1.0);

    setState(() {
      _focusPoint = details.localPosition;
      _showFocusRing = true;
    });

    try {
      await _cameraController!.setFocusPoint(Offset(x, y));
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (_) {}

    _focusTimer?.cancel();
    _focusTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showFocusRing = false);
      }
    });
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
        setState(() => _isFlashOn = false);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
        setState(() => _isFlashOn = true);
      }
    } catch (e) {
      if (mounted) {
        TopSnackBar.show(context, message: 'Perangkat tidak mendukung fitur senter.', type: TopSnackBarType.error);
      }
    }
  }

  @override
  void dispose() {
    _focusTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _ambilFotoDariKamera() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    // MENCEGAH RACE CONDITION: Kalau kamera lagi motret, jangan izinkan tombol dipencet lagi
    if (_cameraController!.value.isTakingPicture) {
      return;
    }

    try {
      // 1. Eksekusi perangkat keras untuk memotret
      final XFile photo = await _cameraController!.takePicture();

      // 2. Matikan flash setelah motret jika menyala
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
        if (mounted) setState(() => _isFlashOn = false);
      }

      // 3. NAVIGASI: Gantikan layar kamera dengan layar hasil (agar tombol X langsung kembali ke beranda)
      if (mounted) {
        context.pushReplacement('/scan-result', extra: photo.path);
      }
    } catch (e) {
      if (mounted) {
        TopSnackBar.show(context, message: 'Gagal mengambil gambar: ${e.toString()}', type: TopSnackBarType.error);
      }
    }
  }

  Future<void> _pilihDariGaleri() async {
    try {
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      // NAVIGASI: Gantikan layar kamera dengan layar hasil
      if (photo != null && mounted) {
        context.pushReplacement('/scan-result', extra: photo.path);
      }
    } catch (e) {
      if (mounted) {
        TopSnackBar.show(context, message: 'Gagal memilih gambar dari galeri.', type: TopSnackBarType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: _toggleFlash,
                  icon: Icon(
                    _isFlashOn
                        ? Icons.flash_on_rounded
                        : Icons.flash_off_rounded,
                    color: _isFlashOn ? Colors.white : Colors.white70,
                    size: 28,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Column(
              children: [
                const Text('Scan Struk',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Text('Ketuk layar untuk memfokuskan teks struk',
                    style: TextStyle(
                        fontSize: 13, color: Colors.white.withOpacity(0.7))),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              height: 480,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: _isCameraInitialized && _cameraController != null
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return GestureDetector(
                            onTapDown: (details) => _handleTapToFocus(details, constraints),
                            behavior: HitTestBehavior.opaque,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CameraPreview(_cameraController!),
                                if (_showFocusRing && _focusPoint != null)
                                  Positioned(
                                    left: _focusPoint!.dx - 24,
                                    top: _focusPoint!.dy - 24,
                                    child: TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 1.3, end: 1.0),
                                      duration: const Duration(milliseconds: 200),
                                      builder: (context, scale, child) {
                                        return Transform.scale(
                                          scale: scale,
                                          child: Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.primary, width: 2),
                                            ),
                                            child: Center(
                                              child: Container(
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.document_scanner_rounded,
                                size: 64, color: Colors.white24),
                            SizedBox(height: 8),
                            Text('Menyiapkan kamera...',
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 14)),
                          ],
                        ),
                      ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(), // Menggunakan go_router
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ),
                  GestureDetector(
                    onTap: _ambilFotoDariKamera,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 3),
                      ),
                      child: Center(
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pilihDariGaleri,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.photo_library_rounded,
                          color: Colors.white70, size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
