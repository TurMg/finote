import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/category_icon_widget.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_state.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_state.dart';
import '../../../category/domain/entities/category.dart';

enum StatPeriodMode { harian, mingguan, bulanan, tahunan }

class CategoryStatData {
  final String categoryName;
  final double totalAmount;
  final double percentage;
  final Color color;
  final Color bgColor;
  final String iconName;

  CategoryStatData({
    required this.categoryName,
    required this.totalAmount,
    required this.percentage,
    required this.color,
    required this.bgColor,
    required this.iconName,
  });
}

class StatistikPage extends StatelessWidget {
  const StatistikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StatistikView();
  }
}

class StatistikView extends StatefulWidget {
  const StatistikView({super.key});

  @override
  State<StatistikView> createState() => _StatistikViewState();
}

class _StatistikViewState extends State<StatistikView> {
  StatPeriodMode _periodMode = StatPeriodMode.bulanan;
  String _selectedType = 'EXPENSE'; // 'EXPENSE' atau 'INCOME'
  DateTime _selectedDate = DateTime.now();

  String _formatRupiah(double amount) {
    final nf = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return nf.format(amount);
  }

  void _previousPeriod() {
    setState(() {
      switch (_periodMode) {
        case StatPeriodMode.harian:
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          break;
        case StatPeriodMode.mingguan:
          _selectedDate = _selectedDate.subtract(const Duration(days: 7));
          break;
        case StatPeriodMode.bulanan:
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
          break;
        case StatPeriodMode.tahunan:
          _selectedDate = DateTime(_selectedDate.year - 1, 1, 1);
          break;
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      switch (_periodMode) {
        case StatPeriodMode.harian:
          _selectedDate = _selectedDate.add(const Duration(days: 1));
          break;
        case StatPeriodMode.mingguan:
          _selectedDate = _selectedDate.add(const Duration(days: 7));
          break;
        case StatPeriodMode.bulanan:
          _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
          break;
        case StatPeriodMode.tahunan:
          _selectedDate = DateTime(_selectedDate.year + 1, 1, 1);
          break;
      }
    });
  }

  String get _periodTitleText {
    switch (_periodMode) {
      case StatPeriodMode.harian:
        final today = DateTime.now();
        if (_selectedDate.year == today.year &&
            _selectedDate.month == today.month &&
            _selectedDate.day == today.day) {
          return 'Hari Ini';
        }
        return DateFormat('dd MMM yyyy', 'id_ID').format(_selectedDate);
      case StatPeriodMode.mingguan:
        final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${DateFormat('dd MMM').format(startOfWeek)} - ${DateFormat('dd MMM yyyy').format(endOfWeek)}';
      case StatPeriodMode.bulanan:
        return DateFormat('MMMM yyyy', 'id_ID').format(_selectedDate);
      case StatPeriodMode.tahunan:
        return DateFormat('yyyy').format(_selectedDate);
    }
  }

  List<Transaction> _filterTransactions(List<Transaction> allTransactions) {
    return allTransactions.where((t) {
      // Filter Type
      if (t.type != _selectedType) return false;

      // Filter Date Period
      switch (_periodMode) {
        case StatPeriodMode.harian:
          return t.date.year == _selectedDate.year &&
              t.date.month == _selectedDate.month &&
              t.date.day == _selectedDate.day;
        case StatPeriodMode.mingguan:
          final startOfWeek = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)
              .subtract(Duration(days: _selectedDate.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
          return t.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
              t.date.isBefore(endOfWeek);
        case StatPeriodMode.bulanan:
          return t.date.year == _selectedDate.year && t.date.month == _selectedDate.month;
        case StatPeriodMode.tahunan:
          return t.date.year == _selectedDate.year;
      }
    }).toList();
  }

  List<CategoryStatData> _calculateCategoryData(
      List<Transaction> transactions, CategoryState catState) {
    if (transactions.isEmpty) return [];

    final Map<String, double> totalsMap = {};
    double grandTotal = 0.0;

    for (var t in transactions) {
      totalsMap[t.category] = (totalsMap[t.category] ?? 0.0) + t.nominal;
      grandTotal += t.nominal;
    }

    if (grandTotal <= 0) return [];

    // Map Category entities for icon & color
    final Map<String, Category> catMap = {};
    if (catState is CategoryLoaded) {
      for (var c in catState.categories) {
        catMap[c.name] = c;
      }
    }

    // Colors fallback palette
    final fallbackColors = [
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF06B6D4),
      const Color(0xFF84CC16),
      const Color(0xFFE53E3E),
    ];

    int colorIdx = 0;
    final List<CategoryStatData> result = [];

    totalsMap.forEach((catName, total) {
      final percentage = (total / grandTotal) * 100;
      final cat = catMap[catName];

      Color color;
      Color bgColor;
      String iconName;

      if (cat != null) {
        color = Color(cat.colorValue);
        bgColor = Color(cat.bgColorValue);
        iconName = cat.iconName;
      } else {
        color = fallbackColors[colorIdx % fallbackColors.length];
        bgColor = color.withOpacity(0.12);
        iconName = _selectedType == 'INCOME'
            ? 'account_balance_wallet_rounded'
            : 'shopping_bag_rounded';
        colorIdx++;
      }

      result.add(CategoryStatData(
        categoryName: catName,
        totalAmount: total,
        percentage: percentage,
        color: color,
        bgColor: bgColor,
        iconName: iconName,
      ));
    });

    // Sort by nominal descending
    result.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return result;
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
        title: const Text(
          'Statistik & Analisis',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // 1. Period Selector Tabs (Harian, Mingguan, Bulanan, Tahunan)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 40,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _buildPeriodTab('Harian', StatPeriodMode.harian),
                    _buildPeriodTab('Mingguan', StatPeriodMode.mingguan),
                    _buildPeriodTab('Bulanan', StatPeriodMode.bulanan),
                    _buildPeriodTab('Tahunan', StatPeriodMode.tahunan),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // 2. Date Navigation Bar (< Agustus 2026 >) & Type Selector Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Period Navigator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, size: 20, color: AppColors.textPrimary),
                          onPressed: _previousPeriod,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                        Text(
                          _periodTitleText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textPrimary),
                          onPressed: _nextPeriod,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ],
                    ),
                  ),

                  // Type Toggle (Pengeluaran / Pemasukan)
                  Container(
                    height: 38,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        _buildTypeTab('Pengeluaran', 'EXPENSE'),
                        _buildTypeTab('Pemasukan', 'INCOME'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. Main Data Content
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, txState) {
                List<Transaction> allTxs = [];
                if (txState is RecentTransactionsLoaded) {
                  allTxs = txState.transactions;
                }

                final filteredTxs = _filterTransactions(allTxs);

                return BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, catState) {
                    final categoryDataList = _calculateCategoryData(filteredTxs, catState);
                    final grandTotal = categoryDataList.fold<double>(
                        0.0, (sum, item) => sum + item.totalAmount);

                    if (filteredTxs.isEmpty || categoryDataList.isEmpty) {
                      return _buildEmptyState();
                    }

                    return Column(
                      children: [
                        // Donut Chart Container
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.03),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 220,
                                  height: 220,
                                  child: CustomPaint(
                                    painter: DonutChartPainter(
                                      dataList: categoryDataList,
                                      strokeWidth: 26,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _selectedType == 'INCOME' ? 'TOTAL PEMASUKAN' : 'TOTAL PENGELUARAN',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textSecondary,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text(
                                              _formatRupiah(grandTotal),
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: _selectedType == 'INCOME'
                                                    ? AppColors.incomeGreenDark
                                                    : AppColors.textPrimary,
                                                letterSpacing: -0.5,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${filteredTxs.length} Transaksi',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.textHint,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Section Title: Rincian per Kategori
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Rincian per Kategori',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Category Breakdown List Cards
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: categoryDataList.length,
                          itemBuilder: (context, index) {
                            final data = categoryDataList[index];
                            return _buildCategoryStatTile(data);
                          },
                        ),

                        const SizedBox(height: 100),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String label, StatPeriodMode mode) {
    final isActive = _periodMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _periodMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTab(String label, String type) {
    final isActive = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryStatTile(CategoryStatData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: data.bgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: CategoryIconWidget(
                  iconName: data.iconName,
                  color: data.color,
                  size: 22,
                  imageBorderRadius: 14,
                  useFullBox: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.categoryName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.percentage.toStringAsFixed(1)}% dari total',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatRupiah(data.totalAmount),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar percentage share
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.percentage / 100,
              minHeight: 6,
              backgroundColor: AppColors.surfaceSubtle,
              valueColor: AlwaysStoppedAnimation<Color>(data.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pie_chart_outline_rounded, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Data Statistik',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tidak ada transaksi ${_selectedType == 'INCOME' ? 'pemasukan' : 'pengeluaran'} pada periode ${_periodTitleText.toLowerCase()}.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final List<CategoryStatData> dataList;
  final double strokeWidth;

  DonutChartPainter({required this.dataList, this.strokeWidth = 24});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataList.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) - strokeWidth) / 2;

    double startAngle = -pi / 2; // Start from top
    const gapAngle = 0.05; // Gap between arcs in radians

    for (var item in dataList) {
      final sweepAngle = (item.percentage / 100) * 2 * pi - gapAngle;
      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + (gapAngle / 2),
        sweepAngle,
        false,
        paint,
      );

      startAngle += (item.percentage / 100) * 2 * pi;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.dataList != dataList || oldDelegate.strokeWidth != strokeWidth;
  }
}
