import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/google_sheets_service.dart';
import '../../../../core/services/sync_service.dart';
import '../bloc/settings_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GoogleSheetsService _sheetsService = GetIt.instance<GoogleSheetsService>();
  final SyncService _syncService = GetIt.instance<SyncService>();
  
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    // Rebuild ui if user already logged in
    _sheetsService.signInSilently().then((user) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _sheetsService.signIn();
      setState(() {
        _isLoading = false;
        if (user != null) {
          _statusMessage = "Berhasil masuk sebagai ${user.email}";
        } else {
          _statusMessage = "Gagal masuk. (Dibatalkan)";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = "Gagal masuk: $e";
      });
    }
  }

  Future<void> _handleLogout() async {
    await _sheetsService.signOut();
    setState(() {
      _statusMessage = "Berhasil keluar.";
    });
  }

  Future<void> _handleSync() async {
    setState(() {
      _isLoading = true;
      _statusMessage = "Sedang sinkronisasi data...";
    });
    
    try {
      await _syncService.syncNow();
      setState(() {
        _statusMessage = "Sinkronisasi berhasil pada ${DateTime.now().toString().substring(0,16)}!";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Sinkronisasi gagal: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuCard(
            title: 'Kelola Kategori',
            subtitle: 'Tambah, ubah, atau hapus kategori pengeluaran',
            icon: Icons.category_rounded,
            onTap: () => context.push('/kelola-kategori'),
          ),
          const SizedBox(height: 16),
          _buildCloudSyncCard(),
          const SizedBox(height: 16),
          BlocBuilder<SettingsCubit, bool?>(
            builder: (context, saveReceiptImage) {
              final isEnabled = saveReceiptImage ?? false;
              return _buildSwitchCard(
                title: 'Simpan Gambar Struk',
                subtitle: 'Simpan foto bukti transaksi untuk dilihat kembali',
                icon: Icons.receipt_long_rounded,
                value: isEnabled,
                onChanged: (val) {
                  context.read<SettingsCubit>().updateSaveReceiptPreference(val);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCloudSyncCard() {
    final user = _sheetsService.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cloud Backup (Google Sheets)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          if (user != null) ...[
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                  child: user.photoUrl == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.displayName ?? 'Pengguna', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(user.email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: _handleLogout,
                )
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleSync,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 44),
              ),
              icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.sync, color: Colors.white),
              label: Text(_isLoading ? 'Menyinkronkan...' : 'Sinkronisasi Sekarang', style: const TextStyle(color: Colors.white)),
            ),
          ] else ...[
            const Text('Login dengan akun Google Anda untuk membackup data transaksi ke Google Sheets.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: const Size(double.infinity, 44),
              ),
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text('Login dengan Google', style: TextStyle(color: Colors.white)),
            ),
          ],
          if (_statusMessage != null) ...[
            const SizedBox(height: 16),
            Text(_statusMessage!, style: TextStyle(fontSize: 13, color: _statusMessage!.contains('gagal') ? Colors.red : Colors.green)),
          ]
        ],
      ),
    );
  }
}
