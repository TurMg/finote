import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/category_icon_widget.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_event.dart';
import '../../../category/presentation/bloc/category_state.dart';
import '../../../category/presentation/widgets/form_kategori_bottom_sheet.dart';
import '../../../category/domain/entities/category.dart';
import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';
import '../../../../core/widgets/top_snackbar.dart';
import '../../../../core/widgets/shake_widget.dart';
import '../../../../core/utils/currency_input_formatter.dart';
import '../widgets/transaction_type_selector.dart';

class CatatPengeluaranPage extends StatelessWidget {
  const CatatPengeluaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CatatPengeluaranView();
  }
}

class CatatPengeluaranView extends StatefulWidget {
  const CatatPengeluaranView({super.key});

  @override
  State<CatatPengeluaranView> createState() => _CatatPengeluaranViewState();
}

class _CatatPengeluaranViewState extends State<CatatPengeluaranView> {
  final _nominalController = TextEditingController();
  final _nominalFocusNode = FocusNode();
  final _catatanController = TextEditingController();
  
  String _transactionType = 'EXPENSE'; // 'EXPENSE' or 'INCOME'
  String? _selectedKategori;
  DateTime _selectedDate = DateTime.now();

  bool _shakeNominal = false;
  String? _nominalError;
  bool _shakeKategori = false;
  String? _kategoriError;

  @override
  void dispose() {
    _nominalController.dispose();
    _nominalFocusNode.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _simpanTransaksi() {
    setState(() {
      _shakeNominal = false;
      _nominalError = null;
      _shakeKategori = false;
      _kategoriError = null;
    });

    final nominalText = _nominalController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final nominal = double.tryParse(nominalText) ?? 0.0;

    bool hasError = false;

    if (nominal <= 0) {
      setState(() {
        _shakeNominal = true;
        _nominalError = 'Nominal transaksi tidak boleh kosong.';
      });
      hasError = true;
    }

    if (_selectedKategori == null) {
      setState(() {
        _shakeKategori = true;
        _kategoriError = 'Pilih kategori terlebih dahulu.';
      });
      hasError = true;
    }

    if (hasError) return;

    context.read<TransactionBloc>().add(
          ManualInputSaved(
            nominal: nominal,
            category: _selectedKategori!,
            date: _selectedDate,
            note: _catatanController.text.trim(),
            type: _transactionType,
          ),
        );
  }

  Color get accentColor => AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final isIncome = _transactionType == 'INCOME';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
            onPressed: () => context.pop(),
          ),
          title: Text(
            isIncome ? 'Catat Pemasukan' : 'Catat Pengeluaran',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is TransactionSavingSuccess) {
              TopSnackBar.show(
                context,
                message: 'Transaksi berhasil disimpan!',
                type: TopSnackBarType.success,
              );
              context.read<HistoryBloc>().add(LoadHistory());
              context.go('/');
            } else if (state is TransactionError) {
              TopSnackBar.show(
                context,
                message: state.message,
                type: TopSnackBarType.error,
              );
            }
          },
          builder: (context, state) {
            final isSaving = state is TransactionSavingLoading;

            return SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // ================= SEGMENTED TOGGLE TYPE SELECTOR =================
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: TransactionTypeSelector(
                                selectedType: _transactionType,
                                onChanged: (newType) {
                                  if (_transactionType != newType) {
                                    setState(() {
                                      _transactionType = newType;
                                      _selectedKategori = null;
                                      _nominalError = null;
                                      _kategoriError = null;
                                    });
                                  }
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ================= DISPLAY NOMINAL JUMLAH =================
                            Column(
                              children: [
                                Text(
                                  isIncome ? 'NOMINAL PEMASUKAN' : 'NOMINAL PENGELUARAN',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary.withOpacity(0.8),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (_nominalFocusNode.hasFocus) {
                                      _nominalFocusNode.unfocus();
                                    }
                                    Future.delayed(const Duration(milliseconds: 50), () {
                                      _nominalFocusNode.requestFocus();
                                    });
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Rp ',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        IntrinsicWidth(
                                          child: TextField(
                                            focusNode: _nominalFocusNode,
                                            controller: _nominalController,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [CurrencyInputFormatter()],
                                            textAlign: TextAlign.center,
                                            onChanged: (val) {
                                              if (_nominalError != null) {
                                                setState(() {
                                                  _nominalError = null;
                                                  _shakeNominal = false;
                                                });
                                              }
                                            },
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: _nominalError != null ? AppColors.error : accentColor,
                                              letterSpacing: -0.5,
                                            ),
                                            decoration: const InputDecoration(
                                              hintText: '0',
                                              hintStyle: TextStyle(color: Color(0xFFB0C4BC)),
                                              filled: false,
                                              fillColor: Colors.transparent,
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              isDense: true,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_nominalError != null)
                                  ShakeWidget(
                                    shake: _shakeNominal,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        _nominalError!,
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // ================= CENTRAL FORM CARD =================
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isIncome ? 'Kategori Pemasukan' : 'Kategori Pengeluaran',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    BlocBuilder<CategoryBloc, CategoryState>(
                                      builder: (context, catState) {
                                        if (catState is CategoryLoaded) {
                                          final categories = catState.categories
                                              .where((c) => c.type == _transactionType)
                                              .toList();

                                          final isSelectedValid = _selectedKategori != null &&
                                              categories.any((c) => c.name == _selectedKategori);

                                          if (!isSelectedValid && categories.isNotEmpty) {
                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                              if (mounted) {
                                                setState(() {
                                                  _selectedKategori = categories.first.name;
                                                });
                                              }
                                            });
                                          }

                                          if (categories.isEmpty) {
                                            return _buildAddCategoryChip(
                                              catState.categories,
                                            );
                                          }

                                          // Append the "+" add chip to the item list
                                          final items = <Widget>[
                                            ...categories.map(_buildCategoryChip),
                                            _buildAddCategoryChip(
                                              catState.categories,
                                            ),
                                          ];

                                          final categoryRows = <Widget>[];
                                          for (int i = 0; i < items.length; i += 4) {
                                            final end = (i + 4 > items.length) ? items.length : i + 4;
                                            final chunk = items.sublist(i, end);
                                            categoryRows.add(
                                              Row(
                                                children: List.generate(4, (index) {
                                                  if (index < chunk.length) {
                                                    return Expanded(child: chunk[index]);
                                                  }
                                                  return const Expanded(child: SizedBox());
                                                }),
                                              ),
                                            );
                                            if (end < items.length) {
                                              categoryRows.add(const SizedBox(height: 14));
                                            }
                                          }

                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: categoryRows,
                                          );
                                        }
                                        return const Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    if (_kategoriError != null)
                                      ShakeWidget(
                                        shake: _shakeKategori,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Text(
                                            _kategoriError!,
                                            style: const TextStyle(
                                              color: AppColors.error,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Tanggal',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: _pilihTanggal,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceSubtle,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              color: accentColor,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    const Text(
                                      'Keterangan (Opsional)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _catatanController,
                                      maxLines: 3,
                                      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                                      decoration: InputDecoration(
                                        hintText: isIncome ? 'Contoh: Gaji bulan Agustus' : 'Contoh: Makan siang nasi padang',
                                        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                                        filled: true,
                                        fillColor: AppColors.surfaceSubtle,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: AppColors.cardBorder.withOpacity(0.5)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: AppColors.cardBorder.withOpacity(0.5)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: accentColor, width: 1.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const Spacer(),

                            // ================= FLOATING STADIUM SAVE BUTTON =================
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                              child: SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isSaving ? null : _simpanTransaksi,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                  ),
                                  child: isSaving
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.check_circle_rounded, size: 20, color: Colors.white),
                                            const SizedBox(width: 8),
                                            Text(
                                              isIncome ? 'Simpan Pemasukan' : 'Simpan Pengeluaran',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
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
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip(Category cat) {
    final isSelected = _selectedKategori == cat.name;
    final catColor = Color(cat.colorValue);
    final catBgColor = Color(cat.bgColorValue);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedKategori = cat.name;
          if (_kategoriError != null) {
            _kategoriError = null;
            _shakeKategori = false;
          }
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: catBgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? catColor : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: catColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [],
            ),
            child: CategoryIconWidget(
              iconName: cat.iconName,
              color: catColor,
              size: 24,
              imageBorderRadius: 26,
              useFullBox: true,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            cat.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Chip "+" untuk menambah kategori baru langsung dari halaman ini.
  Widget _buildAddCategoryChip(List<Category> allCategories) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppColors.surfaceSubtle,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () => _showAddCategorySheet(allCategories),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.textHint.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tambah',
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Buka FormKategoriBottomSheet dan auto-select kategori baru.
  void _showAddCategorySheet(List<Category> allCategories) async {
    final result = await showModalBottomSheet<Category>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FormKategoriBottomSheet(
        allCategories: allCategories,
        defaultType: _transactionType,
      ),
    );

    if (result != null && mounted) {
      context.read<CategoryBloc>().add(AddCategory(result));
      setState(() {
        _selectedKategori = result.name;
        _kategoriError = null;
        _shakeKategori = false;
      });
    }
  }
}
