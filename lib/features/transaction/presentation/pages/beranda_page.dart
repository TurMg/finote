import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/google_sheets_service.dart';
import '../../../../core/services/sync_service.dart';
import '../../../../core/services/settings_service.dart';
import '../widgets/transaction_detail_bottom_sheet.dart';
import '../widgets/transaction_card_tile.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../../domain/entities/transaction.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_event.dart';
import '../../../category/presentation/bloc/category_state.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BerandaView();
  }
}

class BerandaView extends StatefulWidget {
  const BerandaView({super.key});

  @override
  State<BerandaView> createState() => _BerandaViewState();
}

class _BerandaViewState extends State<BerandaView> {
  bool _isBalanceVisible = true;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _checkGoogleUser();
    _triggerStartupSync();
  }

  Future<void> _triggerStartupSync() async {
    try {
      final syncService = GetIt.instance<SyncService>();
      await syncService.syncNow();
      if (mounted) {
        context.read<TransactionBloc>().add(FetchRecentTransactions());
      }
    } catch (e) {
      debugPrint("Startup background sync silent log: $e");
    }
  }

  Future<void> _checkGoogleUser() async {
    try {
      final sheetsService = GetIt.instance<GoogleSheetsService>();
      var user = sheetsService.currentUser;
      user ??= await sheetsService.signInSilently();
      if (user != null && mounted) {
        setState(() {
          _userName = user?.displayName?.split(' ').first ?? user?.displayName;
        });
      }
    } catch (_) {}
  }

  String? get _resolvedUserName {
    final settingsService = GetIt.instance<SettingsService>();
    final customName = settingsService.customUsername;
    if (customName != null && customName.trim().isNotEmpty) {
      return customName.trim();
    }
    return _userName;
  }

  String _formatRupiah(double amount) {
    final nf = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return nf.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(
                'assets/images/logo_finote.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Finote',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          context.read<TransactionBloc>().add(FetchRecentTransactions());
          context.read<CategoryBloc>().add(LoadAllCategories());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: BlocBuilder<TransactionBloc, TransactionState>(
            buildWhen: (previous, current) {
              if (current is TransactionSavingLoading || current is TransactionSavingSuccess) {
                return false;
              }
              if (current is TransactionError && previous is RecentTransactionsLoaded) {
                return false;
              }
              return true;
            },
            builder: (context, state) {
              if (state is TransactionLoading || state is TransactionInitial) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              } else if (state is RecentTransactionsLoaded) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildGreeting(),
                    const SizedBox(height: 20),
                    _buildFinancialSummaryCard(state),
                    const SizedBox(height: 28),
                    _buildRecentTransactions(context, state.transactions.take(10).toList()),
                    const SizedBox(height: 100),
                  ],
                );
              } else if (state is TransactionError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Gagal memuat data: ${state.message}',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String timeGreeting;

    if (hour >= 4 && hour < 11) {
      timeGreeting = 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      timeGreeting = 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      timeGreeting = 'Selamat Sore';
    } else {
      timeGreeting = 'Selamat Malam';
    }

    final displayName = _resolvedUserName;
    final titleText = (displayName != null && displayName.isNotEmpty)
        ? '$timeGreeting, $displayName!'
        : '$timeGreeting!';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Kelola pengeluaran & pemasukan keuanganmu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCard(RecentTransactionsLoaded state) {
    final saldo = state.saldoBulanIni;
    final pemasukan = state.totalPemasukanBulanIni;
    final pengeluaran = state.totalPengeluaranBulanIni;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4E453E), // Cokelat asli di bagian atas
              Color(0xFF6E5F54), // Transisi hangat di tengah
              Color(0xFF8F7C6E), // Cokelat JAUH LEBIH TERANG di bagian bawah
            ],
            stops: [0.0, 0.45, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4E453E).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white.withOpacity(0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL SALDO BULAN INI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC2E0D1),
                          letterSpacing: 0.8,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isBalanceVisible ? _formatRupiah(saldo) : 'Rp •••••••',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: saldo >= 0 ? Colors.white : const Color(0xFFFCA5A5),
                            letterSpacing: -0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isBalanceVisible = !_isBalanceVisible;
                          });
                        },
                        icon: Icon(
                          _isBalanceVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: Colors.white.withOpacity(0.85),
                          size: 22,
                        ),
                        tooltip: _isBalanceVisible ? 'Sembunyikan Saldo' : 'Tampilkan Saldo',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.15),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Stat Pemasukan
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_downward_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pemasukan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFA7F3D0),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isBalanceVisible ? _formatRupiah(pemasukan) : 'Rp •••••••',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 32,
                        width: 1,
                        color: Colors.white.withOpacity(0.15),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      // Stat Pengeluaran
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE53E3E),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_upward_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pengeluaran',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFFECDD3),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isBalanceVisible ? _formatRupiah(pengeluaran) : 'Rp •••••••',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List<Transaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaksi Terbaru',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => context.push('/riwayat'),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (transactions.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Center(
              child: Text(
                'Belum ada transaksi',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, catState) {
              return Column(
                children: transactions.map((t) {
                  return TransactionCardTile(
                    transaction: t,
                    categoryState: catState,
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => TransactionDetailBottomSheet(transaction: t),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }
}