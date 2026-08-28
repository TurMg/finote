import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_counter_text.dart';
import '../../../../core/widgets/bouncing_button.dart';
import '../../../../core/widgets/floating_empty_state.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/sliding_segmented_control.dart';
import '../../../../core/widgets/staggered_item_wrapper.dart';
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
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
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

                      // Tipe Filter (Sliding Segmented Control)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SlidingSegmentedControl<TransactionTypeFilter>(
                          selectedValue: state.typeFilter,
                          items: TransactionTypeFilter.values,
                          height: 40,
                          borderRadius: 22,
                          labelBuilder: (type) {
                            switch (type) {
                              case TransactionTypeFilter.semua:
                                return 'Semua';
                              case TransactionTypeFilter.pemasukan:
                                return 'Pemasukan';
                              case TransactionTypeFilter.pengeluaran:
                                return 'Pengeluaran';
                            }
                          },
                          onChanged: (type) => context.read<HistoryBloc>().add(TypeFilterChanged(type)),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Periode Filter Chips (Sliding Segmented Control)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SlidingSegmentedControl<FilterMode>(
                          selectedValue: state.filterMode,
                          items: FilterMode.values,
                          height: 36,
                          borderRadius: 18,
                          labelBuilder: (mode) => mode.name[0].toUpperCase() + mode.name.substring(1),
                          onChanged: (mode) => context.read<HistoryBloc>().add(FilterHistoryChanged(mode)),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Main List Content
                      Expanded(
                        child: state.isLoading
                            ? ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 6,
                                itemBuilder: (context, index) => const SkeletonCardTile(),
                              )
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

  Widget _buildEmptyState() {
    return const FloatingEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'Belum Ada Transaksi',
      subtitle: 'Catat transaksi pertama Anda!',
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
            const FloatingEmptyState(
              icon: Icons.search_off_rounded,
              title: 'Tidak Ada Transaksi',
              subtitle: 'Tidak ditemukan transaksi yang cocok dengan filter.',
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
                      AnimatedCounterText(
                        value: totalFilteredNominal,
                        formatter: (val) {
                          final prefix = val >= 0 ? '+' : '-';
                          final absVal = val.abs();
                          return '$prefix${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(absVal)}';
                        },
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
                            AnimatedCounterText(
                              value: dailyTotal,
                              formatter: (val) {
                                final prefix = val >= 0 ? '+' : '-';
                                final absVal = val.abs();
                                return '$prefix${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(absVal)}';
                              },
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

                            return StaggeredItemWrapper(
                              index: idx,
                              child: Column(
                                children: [
                                  BouncingButton(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        useRootNavigator: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (context) => TransactionDetailBottomSheet(transaction: t),
                                      );
                                    },
                                    child: TransactionCardTile(
                                      transaction: t,
                                      categoryState: catState,
                                      isGrouped: true,
                                    ),
                                  ),
                                  if (idx < items.length - 1)
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.divider.withOpacity(0.4),
                                      indent: 70,
                                    ),
                                ],
                              ),
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