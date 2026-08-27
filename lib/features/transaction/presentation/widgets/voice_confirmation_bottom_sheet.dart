import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/category_icon_widget.dart';
import '../../../../core/widgets/top_snackbar.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_state.dart';
import '../../domain/entities/voice_parsed_data.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';

class VoiceConfirmationBottomSheet extends StatefulWidget {
  final VoiceParsedData parsedData;
  final String rawText;
  final VoidCallback? onRetry;

  const VoiceConfirmationBottomSheet({
    super.key,
    required this.parsedData,
    required this.rawText,
    this.onRetry,
  });

  @override
  State<VoiceConfirmationBottomSheet> createState() =>
      _VoiceConfirmationBottomSheetState();
}

class _VoiceConfirmationBottomSheetState
    extends State<VoiceConfirmationBottomSheet> {
  late TextEditingController _nominalController;
  late TextEditingController _noteController;
  late String _selectedType;
  late String _selectedCategory;

  final _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _selectedType = widget.parsedData.type;
    _selectedCategory = widget.parsedData.category;
    _noteController = TextEditingController(text: widget.parsedData.note);

    final initialNominalInt = widget.parsedData.nominal.toInt();
    _nominalController = TextEditingController(
      text: initialNominalInt > 0 ? _currencyFormat.format(initialNominalInt) : '',
    );
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  double _getCleanNominal() {
    final cleanStr = _nominalController.text.replaceAll('.', '').trim();
    return double.tryParse(cleanStr) ?? 0.0;
  }

  void _onNominalChanged(String val) {
    final cleanStr = val.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanStr.isEmpty) {
      _nominalController.value = const TextEditingValue(text: '');
      return;
    }

    final doubleVal = double.tryParse(cleanStr) ?? 0.0;
    final formatted = _currencyFormat.format(doubleVal.toInt());

    _nominalController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  void _onSave() {
    final nominal = _getCleanNominal();
    if (nominal <= 0) {
      TopSnackBar.show(
        context,
        message: 'Nominal transaksi tidak boleh kosong atau 0',
        type: TopSnackBarType.error,
      );
      return;
    }

    if (_selectedCategory.isEmpty) {
      TopSnackBar.show(
        context,
        message: 'Pilih kategori transaksi terlebih dahulu',
        type: TopSnackBarType.error,
      );
      return;
    }

    context.read<TransactionBloc>().add(
          ManualInputSaved(
            nominal: nominal,
            category: _selectedCategory,
            date: DateTime.now(),
            note: _noteController.text.trim().isEmpty
                ? widget.rawText
                : _noteController.text.trim(),
            inputSource: 'VOICE',
            type: _selectedType,
          ),
        );
    context.read<HistoryBloc>().add(LoadHistory());

    TopSnackBar.show(
      context,
      message: 'Transaksi dari suara berhasil disimpan!',
      type: TopSnackBarType.success,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = _selectedType == 'EXPENSE';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title & Subtitle
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.record_voice_over_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hasil Tangkapan Suara',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Cek & sesuaikan jika ada yang keliru',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Gelembung Teks Suara
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.cardBorder.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.graphic_eq_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '"${widget.rawText}"',
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Selector Tipe (Pengeluaran vs Pemasukan)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = 'EXPENSE'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isExpense
                                ? AppColors.expenseRed
                                : AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pengeluaran',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  isExpense ? FontWeight.bold : FontWeight.w600,
                              color: isExpense
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = 'INCOME'),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isExpense
                                ? AppColors.incomeGreen
                                : AppColors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Pemasukan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  !isExpense ? FontWeight.bold : FontWeight.w600,
                              color: !isExpense
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Nominal Input
                const Text(
                  'Nominal Transaksi',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nominalController,
                  keyboardType: TextInputType.number,
                  onChanged: _onNominalChanged,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isExpense
                        ? AppColors.expenseRedDark
                        : AppColors.incomeGreenDark,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 6),
                      child: Text(
                        'Rp',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isExpense
                              ? AppColors.expenseRedDark
                              : AppColors.incomeGreenDark,
                        ),
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    hintText: '0',
                    filled: true,
                    fillColor: AppColors.surfaceSubtle,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Selector
                const Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, catState) {
                    List categories = [];
                    if (catState is CategoryLoaded) {
                      categories = catState.categories
                          .where((c) => c.type == _selectedType || c.type == 'BOTH')
                          .toList();
                    }

                    if (categories.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Tidak ada kategori tersedia',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = _selectedCategory == cat.name;

                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat.name),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: AppColors.cardBorder.withOpacity(0.5),
                                      ),
                              ),
                              child: Row(
                                children: [
                                  CategoryIconWidget(
                                    iconName: cat.iconName,
                                    color: isSelected
                                        ? Colors.white
                                        : Color(cat.colorValue),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Note Input
                const Text(
                  'Catatan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _noteController,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tambahkan catatan...',
                    filled: true,
                    fillColor: AppColors.surfaceSubtle,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    if (widget.onRetry != null) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          widget.onRetry!();
                        },
                        icon: const Icon(Icons.mic_rounded, size: 18),
                        label: const Text('Ulangi'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _onSave,
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text(
                          'Simpan Transaksi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
