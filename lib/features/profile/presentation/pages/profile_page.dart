import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/google_sheets_service.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/widgets/top_snackbar.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GoogleSheetsService _sheetsService = GetIt.instance<GoogleSheetsService>();
  final SyncService _syncService = GetIt.instance<SyncService>();
  final SettingsService _settingsService = GetIt.instance<SettingsService>();

  bool _isLoading = false;
  String? _statusMessage;
  String? _customName;

  @override
  void initState() {
    super.initState();
    _customName = _settingsService.customUsername;
    _sheetsService.signInSilently().then((user) {
      if (mounted) setState(() {});
    });
  }

  String get _displayName {
    if (_customName != null && _customName!.trim().isNotEmpty) {
      return _customName!.trim();
    }
    final googleUser = _sheetsService.currentUser;
    if (googleUser != null &&
        googleUser.displayName != null &&
        googleUser.displayName!.trim().isNotEmpty) {
      return googleUser.displayName!.trim();
    }
    return 'Pengguna Finote';
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
          _statusMessage = "Gagal masuk (dibatalkan).";
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
      _statusMessage = "Berhasil keluar dari akun Google.";
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
        _statusMessage =
            "Sinkronisasi berhasil pada ${DateTime.now().toString().substring(11, 16)}!";
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Sinkronisasi gagal: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEditUsernameDialog() {
    final controller = TextEditingController(text: _displayName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Nama Pengguna',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Nama ini hanya digunakan di aplikasi Finote dan tidak mengubah nama akun Google asli Anda.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Nama Tampilan',
                  hintText: 'Masukkan nama kustom Anda...',
                  filled: true,
                  fillColor: AppColors.splashBackground.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final newName = controller.text.trim();
                    if (newName.isNotEmpty) {
                      await _settingsService.setCustomUsername(newName);
                      if (!mounted) return;
                      setState(() {
                        _customName = newName;
                      });
                      Navigator.pop(context);
                      TopSnackBar.show(
                        context,
                        message: 'Nama pengguna berhasil diperbarui!',
                        type: TopSnackBarType.success,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Simpan Nama',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final googleUser = _sheetsService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // ================= 1. PROFILE HERO HEADER =================
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(45),
                      child: googleUser?.photoUrl != null
                          ? Image.network(
                              googleUser!.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildAvatarInitial(),
                            )
                          : _buildAvatarInitial(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: _showEditUsernameDialog,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _displayName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    googleUser != null ? googleUser.email : 'Mode Lokal (Offline)',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      googleUser != null ? 'Cloud Sync Active' : 'Level 1: Pengguna Finote',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ================= 2. SECTION: PENGATURAN KARTU PUTIH =================
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Pengaturan Akun & Fitur',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  _buildListTile(
                    icon: Icons.category_outlined,
                    title: 'Kelola Kategori',
                    subtitle: 'Tambah, ubah, atau hapus kategori',
                    onTap: () => context.push('/kelola-kategori'),
                  ),
                  const Divider(height: 1, indent: 64, endIndent: 20, color: Color(0xFFEEEEEE)),
                  BlocBuilder<SettingsCubit, bool?>(
                    builder: (context, saveReceiptImage) {
                      final isEnabled = saveReceiptImage ?? false;
                      return _buildSwitchTile(
                        icon: Icons.receipt_long_outlined,
                        title: 'Simpan Gambar Struk',
                        subtitle: 'Simpan foto bukti transaksi',
                        value: isEnabled,
                        onChanged: (val) {
                          context.read<SettingsCubit>().updateSaveReceiptPreference(val);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= 3. SECTION: CLOUD BACKUP GOOGLE SHEETS =================
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Cloud Backup & Storage',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_sync_outlined, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Google Sheets Backup',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              googleUser != null
                                  ? 'Terhubung dengan ${googleUser.email}'
                                  : 'Belum terhubung ke Google Drive',
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (googleUser != null)
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleSync,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.sync_rounded, color: Colors.white, size: 20),
                        label: Text(
                          _isLoading ? 'Menyinkronkan...' : 'Sinkronisasi Sekarang',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.login_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'Login dengan Google',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _statusMessage!.contains('Gagal') || _statusMessage!.contains('gagal')
                            ? Colors.redAccent
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ================= 4. BOTTOM ACTION BUTTON =================
            if (googleUser != null)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDE8E8), // Soft pink/red
                    foregroundColor: const Color(0xFFE53935),
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.logout_rounded, color: Color(0xFFE53935), size: 20),
                  label: const Text(
                    'Keluar Akun',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE53935),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.login_rounded, color: AppColors.primary, size: 20),
                  label: const Text(
                    'Hubungkan Akun Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarInitial() {
    final char = _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'P';
    return Center(
      child: Text(
        char,
        style: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
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
}

