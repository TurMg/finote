import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'expandable_fab.dart';
import '../../../../core/constants/colors.dart'; // Sesuaikan path AppColors lu
import 'voice_input_bottom_sheet.dart';

class MainLayout extends StatelessWidget {
  final Widget child; // Ini yang bakal diisi otomatis sama Beranda atau Riwayat
  
  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Lacak kita lagi ada di URL mana buat ngewarnain icon tab yang aktif
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      extendBody: true, // Biar body tembus ke bawah BottomAppBar dan keliatan dari celah notch
      resizeToAvoidBottomInset: false, // Mencegah FAB ikut naik saat keyboard muncul
      
      body: child, // Konten layar disuntikkan ke sini
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ExpandableFab(
        // Untuk fitur input, kita tetap pakai PUSH agar layarnya tampil full screen menutupi navbar
        onManual: () => context.push('/catat-pengeluaran'),
        onScan: () => context.push('/scan-kamera'),
        onVoice: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const VoiceInputBottomSheet(),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.primary,
        height: 60, // Pindahkan height langsung ke BottomAppBar
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        padding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () {}, // Mencegah tap di area kosong navbar tembus ke item transaksi di belakangnya
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.only(top: 2),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  // Sisi Kiri: Home & Statistik (Berdekatan)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.go('/'),
                              child: Center(
                                child: Icon(Icons.home_rounded, color: location == '/' ? Colors.white : Colors.white54, size: 25),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.go('/statistik'),
                              child: Center(
                                child: Icon(Icons.pie_chart_rounded, color: location == '/statistik' ? Colors.white : Colors.white54, size: 25),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Celah Tengah untuk FAB Notch
                  const SizedBox(width: 76),

                  // Sisi Kanan: Riwayat & Profil (Berdekatan)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.go('/riwayat'),
                              child: Center(
                                child: Icon(Icons.history_rounded, color: location == '/riwayat' ? Colors.white : Colors.white54, size: 25),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => context.go('/profil'),
                              child: Center(
                                child: Icon(Icons.person_rounded, color: (location == '/profil' || location == '/settings') ? Colors.white : Colors.white54, size: 25),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}