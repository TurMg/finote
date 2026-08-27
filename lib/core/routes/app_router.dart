import 'package:flutter/material.dart'; // Wajib ditambahin buat manggil GlobalKey
import 'package:go_router/go_router.dart';

// Import kerangka global lu (Sesuaikan path-nya dengan tempat lu nyimpen main_layout.dart)
import '../../features/transaction/presentation/widgets/main_layout.dart'; 

import '../../features/transaction/presentation/pages/beranda_page.dart';
import '../../features/transaction/presentation/pages/kamera_scan_page.dart';
import '../../features/transaction/presentation/pages/ocr_result_page.dart';
import '../../features/transaction/presentation/pages/catat_pengeluaran_page.dart';
import '../../features/transaction/presentation/pages/riwayat_page.dart';
import '../../features/transaction/presentation/pages/statistik_page.dart';
import '../../features/category/presentation/pages/kelola_kategori_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/transaction/presentation/pages/splash_page.dart';

// Siapkan kunci navigator untuk membedakan mana layar cangkang dan mana layar utama
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash', 
  routes: [
    // ================= 1. RUTE CANGKANG (BOTTOM NAV GLOBAL) =================
    // Semua layar di dalam rute ini bakal terus nampilin MainLayout (Bottom Nav)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayout(child: child); 
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const BerandaPage(),
        ),
        GoRoute(
          path: '/riwayat',
          builder: (context, state) => const RiwayatPage(),
        ),
        GoRoute(
          path: '/statistik',
          builder: (context, state) => const StatistikPage(),
        ),
        GoRoute(
          path: '/profil',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),

    // ================= 2. RUTE FULL SCREEN (TANPA BOTTOM NAV) =================
    // Semua fitur input harus menimpa seluruh layar biar nggak tabrakan sama navbar
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey, // Paksa render di root layar teratas
      path: '/scan-kamera',
      builder: (context, state) => const KameraScanPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey, 
      path: '/scan-result',
      builder: (context, state) {
        final String imagePath = state.extra as String;
        return OcrResultPage(imagePath: imagePath);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey, 
      path: '/catat-pengeluaran',
      builder: (context, state) => const CatatPengeluaranPage(),
    ),

    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/kelola-kategori',
      builder: (context, state) => const KelolaKategoriPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);