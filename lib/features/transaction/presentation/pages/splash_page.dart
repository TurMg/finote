import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/sync_service.dart';
import 'package:get_it/get_it.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Jalankan auto-sync di background saat aplikasi dibuka
    final syncService = GetIt.instance<SyncService>();
    syncService.syncNow().catchError((e) => debugPrint("Auto-sync at launch failed: $e"));

    // Pindah ke halaman beranda setelah 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: Stack(
        children: [
          // Konten Tengah
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    'assets/images/logo_finote.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Finote',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track Smart. Save More.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Loading Spinner di Bawah
          const Positioned(
            bottom: 64,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
