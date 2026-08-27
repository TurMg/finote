import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';
import '../bloc/history/history_state.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_detail_bottom_sheet.dart';
import '../widgets/transaction_card_tile.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_state.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const RiwayatView();
  }
}

class RiwayatView extends StatefulWidget {
  const RiwayatView({super.key});

  @override
  State<RiwayatView> createState() => _RiwayatViewState();
}

class _RiwayatViewState extends State<RiwayatView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Riwayat Transaksi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocListener<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is TransactionSavingSuccess) {
              context.read<HistoryBloc>().add(LoadHistory());
            }
          },
          child: BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, catState) {
              return BlocBuilder<HistoryBloc, HistoryState>(
                builder: (context, state) {
                  if (_searchController.text != state.searchQuery) {
                    _searchController.text = state.searchQuery;
                  }

                  return Column(
                    children: [
                      // Search Bar Input
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => context.read<HistoryBloc>().add(SearchHistoryChanged(val)),
                            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Cari transaksi atau catatan...',
                              hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        context.read<HistoryBloc>().add(SearchHistoryChanged(''));
                                      },
                                      child: const Icon(Icons.cancel_rounded, color: AppColors.textSecondary, size: 18),
                                    )
                                  : null,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),

                      // Tipe Filter (Segmented Control)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              _buildSegmentedTab(
                                context: context,
                                label: 'Semua',
                                type: TransactionTypeFilter.semua,
                                currentType: state.typeFilter,
                              ),
                              _buildSegmentedTab(
                                context: context,
                                label: 'Pemasukan',
                                type: TransactionTypeFilter.pemasukan,
                                currentType: state.typeFilter,
                              ),
                              _buildSegmentedTab(
                                context: context,
                                label: 'Pengeluaran',
                                type: TransactionTypeFilter.pengeluaran,
                                currentType: state.typeFilter,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Periode Filter Chips (Semua, Harian, Mingguan, Bulanan)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: FilterMode.values.map((mode) {
                            final isActive = state.filterMode == mode;
                            String label = mode.name[0].toUpperCase() + mode.name.substring(1);

                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () => context.read<HistoryBloc>().add(FilterHistoryChanged(mode)),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isActive ? AppColors.primary : AppColors.surfaceSubtle.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isActive ? AppColors.primary : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      color: isActive ? Colors.white : AppColors.textSecondary,
                                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Main List Content
                      Expanded(
                        child: state.isLoading
                            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                            : state.allTransactions.isEmpty
                                ? _buildEmptyState()
                                : _buildContent(context, state, catState),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTab({
    required BuildContext context,
    required String label,
    required TransactionTypeFilter type,
    required TransactionTypeFilter currentType,
  }) {
    final isActive = type == currentType;

    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<HistoryBloc>().add(TypeFilterChanged(type)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 72,
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Ada Transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Catat transaksi pertama Anda!',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, HistoryState state, CategoryState catState) {
    final grouped = <String, List<Transaction>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var t in state.filteredTransactions) {
      final date = DateTime(t.date.year, t.date.month, t.date.day);
      final diff = today.difference(date).inDays;
      final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID').format(t.date).toUpperCase();

      String key;
      if (diff == 0) {
        key = 'HARI INI ($dateFormat)';
      } else if (diff == 1) {
        key = 'KEMARIN ($dateFormat)';
      } else {
        key = dateFormat;
      }
      grouped.putIfAbsent(key, () => []).add(t);
    }

    final totalFilteredNominal = state.filteredTransactions.fold<double>(
      0.0,
      (sum, item) => sum + (item.type == 'INCOME' ? item.nominal : -item.nominal),
    );

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.filteredTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Tidak ada transaksi pada filter ini.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            )
          else ...[
            // Filter Summary Banner
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.filteredTransactions.length} Transaksi',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Total: ',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      Text(
                        '${totalFilteredNominal >= 0 ? '+' : ''}${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalFilteredNominal)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: totalFilteredNominal >= 0 ? AppColors.incomeGreenDark : AppColors.expenseRedDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: grouped.entries.map((entry) {
                final groupKey = entry.key;
                final items = entry.value;

                final dailyTotal = items.fold<double>(
                  0.0,
                  (sum, item) => sum + (item.type == 'INCOME' ? item.nominal : -item.nominal),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              groupKey,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              '${dailyTotal >= 0 ? '+' : ''}${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(dailyTotal)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: dailyTotal >= 0 ? AppColors.incomeGreenDark : AppColors.expenseRedDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder.withOpacity(0.4), width: 0.8),
                        ),
                        child: Column(
                          children: items.asMap().entries.map((itemEntry) {
                            final idx = itemEntry.key;
                            final t = itemEntry.value;

                            return Column(
                              children: [
                                TransactionCardTile(
                                  transaction: t,
                                  categoryState: catState,
                                  isGrouped: true,
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      useRootNavigator: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => TransactionDetailBottomSheet(transaction: t),
                                    );
                                  },
                                ),
                                if (idx < items.length - 1)
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: AppColors.divider.withOpacity(0.4),
                                    indent: 70,
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

}