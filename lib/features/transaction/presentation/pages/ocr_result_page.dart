import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/category_icon_widget.dart';
import '../../../../injection_container.dart';
import '../../../../core/widgets/top_snackbar.dart';
import '../../../../core/widgets/shake_widget.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import 'package:intl/intl.dart';

// BLoC Transaksi (Untuk Simpan Data)
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_type_selector.dart';

import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';

// BLoC Scanner (Untuk Ekstraksi OCR)
import '../bloc/scanner/scanner_bloc.dart';
import '../bloc/scanner/scanner_event.dart';
import '../bloc/scanner/scanner_state.dart';

// BLoC Kategori
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_event.dart';
import '../../../category/presentation/bloc/category_state.dart';
import '../../../category/presentation/widgets/form_kategori_bottom_sheet.dart';
import '../../../category/domain/entities/category.dart';

class OcrResultPage extends StatelessWidget {
  final String imagePath;

  const OcrResultPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScannerBloc>()..add(AnalyzeReceipt(imagePath)),
      child: OcrResultView(imagePath: imagePath),
    );
  }
}

class OcrResultView extends StatefulWidget {
  final String imagePath;
  const OcrResultView({super.key, required this.imagePath});

  @override
  State<OcrResultView> createState() => _OcrResultViewState();
}

class _OcrResultViewState extends State<OcrResultView> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final _keteranganController = TextEditingController();
  String? _selectedKategori;
  String _transactionType = 'EXPENSE';
  DateTime _selectedDate = DateTime.now();
  double _extractedAmount = 0.0;

  bool _shakeKategori = false;
  String? _kategoriError;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _keteranganController.dispose();
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
      _shakeKategori = false;
      _kategoriError = null;
    });

    if (_extractedAmount <= 0) {
      TopSnackBar.show(context, message: 'Nominal 0. Silakan scan ulang atau perbaiki struk.', type: TopSnackBarType.error);
      return;
    }
    if (_selectedKategori == null) {
      setState(() {
        _shakeKategori = true;
        _kategoriError = 'Pilih kategori terlebih dahulu.';
      });
      return;
    }

    _prosesSimpanTransaksi();
  }

  void _prosesSimpanTransaksi() {
    final settingsCubit = context.read<SettingsCubit>();
    final savePref = settingsCubit.state;

    if (savePref == null) {
      _showSaveReceiptPrompt();
    } else {
      _dispatchSimpanEvent(savePref);
    }
  }

  void _showSaveReceiptPrompt() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Simpan Foto Struk?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          content: const Text(
            'Apakah Anda ingin menyimpan foto struk ini di aplikasi? Menyimpan struk memudahkan Anda mengecek ulang nanti, tapi akan memakan sedikit memori HP Anda.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<SettingsCubit>().updateSaveReceiptPreference(false);
                Navigator.pop(context);
                _dispatchSimpanEvent(false);
              },
              child: const Text('Jangan Simpan', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<SettingsCubit>().updateSaveReceiptPreference(true);
                Navigator.pop(context);
                _dispatchSimpanEvent(true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _dispatchSimpanEvent(bool saveReceipt) {
    context.read<TransactionBloc>().add(
          ManualInputSaved(
            nominal: _extractedAmount,
            category: _selectedKategori!,
            date: _selectedDate,
            note: _keteranganController.text.trim(),
            inputSource: 'SCAN',
            imagePath: saveReceipt ? widget.imagePath : null,
            type: _transactionType,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.splashBackground,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          title: const Text(
            'Tinjau Hasil Scan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
        ),
        body: MultiBlocListener(
          listeners: [
            // Listener untuk memantau hasil OCR dari ScannerBloc
            BlocListener<ScannerBloc, ScannerState>(
              listener: (context, state) {
                if (state is ScannerSuccess) {
                  setState(() => _extractedAmount = state.nominal);
                } else if (state is ScannerError) {
                  TopSnackBar.show(context, message: state.message, type: TopSnackBarType.error);
                }
              },
            ),
            // Listener untuk memantau status penyimpanan dari TransactionBloc
            BlocListener<TransactionBloc, TransactionState>(
              listener: (context, state) {
                if (state is TransactionSavingSuccess) {
                  TopSnackBar.show(context, message: 'Transaksi struk berhasil disimpan!', type: TopSnackBarType.success);
                  context.read<HistoryBloc>().add(LoadHistory());
                  context.go('/'); 
                } else if (state is TransactionError) {
                  TopSnackBar.show(context, message: state.message, type: TopSnackBarType.error);
                }
              },
            ),
          ],
          // Builder mengikuti state dari ScannerBloc untuk mengatur transisi layar loading ke form
          child: BlocBuilder<ScannerBloc, ScannerState>(
            builder: (context, scannerState) {
              
              // ================= STATE 1: LOADING ANIMATION =================
              if (scannerState is ScannerProcessing || scannerState is ScannerInitial) {
                return SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(scale: _pulseAnimation.value, child: child);
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFFFFFFFF)]),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10))
                              ],
                            ),
                            child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 48),
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text('Sedang memproses...',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                );
              }

              // ================= STATE 2: HASIL OCR DAN FORM =================
              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Bukti Transaksi',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary)),
                                    Text('Silakan periksa kembali.',
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              // Tombol Pratinjau Fullscreen
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: EdgeInsets.zero,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            InteractiveViewer(
                                              child: Image.file(File(widget.imagePath)),
                                            ),
                                            Positioned(
                                              top: 40,
                                              right: 20,
                                              child: IconButton(
                                                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                                                onPressed: () => Navigator.pop(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.crop_free_rounded, color: AppColors.primary, size: 24),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            const Text('TOTAL TERDETEKSI',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4A6B5D),
                                    letterSpacing: 1.2)),
                            const SizedBox(height: 2),
                            Text(
                              NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_extractedAmount),
                              style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: -0.5),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kategori',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 14),
                                // ======= KATEGORI DINAMIS DARI BLOC =======
                              BlocBuilder<CategoryBloc, CategoryState>(
                                builder: (context, catState) {
                                  if (catState is CategoryLoaded) {
                                    final categories = catState.categories
                                        .where((c) => c.type == _transactionType)
                                        .toList();

                                    // Auto-select kategori pertama
                                    if (_selectedKategori == null &&
                                        categories.isNotEmpty) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (mounted) {
                                          setState(() {
                                            _selectedKategori =
                                                categories.first.name;
                                          });
                                        }
                                      });
                                    } else if (categories.isNotEmpty &&
                                        !categories.any((c) =>
                                            c.name == _selectedKategori)) {
                                      // If current selected category is not in the filtered list, reset it
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (mounted) {
                                          setState(() {
                                            _selectedKategori =
                                                categories.first.name;
                                          });
                                        }
                                      });
                                    }

                                    // Append the "+" add chip to the item list
                                    final items = <Widget>[
                                      ...categories.map(_buildCategoryChip),
                                      _buildAddCategoryChip(catState.categories),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TransactionTypeSelector(
                                          selectedType: _transactionType,
                                          onChanged: (newType) {
                                            setState(() {
                                              _transactionType = newType;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 24),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: categoryRows,
                                        ),
                                      ],
                                    );
                                  }
                                  return const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary),
                                    ),
                                  );
                                },
                              ),
                              if (_kategoriError != null)
                                ShakeWidget(
                                  shake: _shakeKategori,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12),
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
                              const SizedBox(height: 24),
                              const Text('Tanggal',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: _pilihTanggal,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCDDAD4)
                                        .withOpacity(0.65),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                          Icons.calendar_today_outlined,
                                          color: AppColors.textPrimary,
                                          size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                                        style: const TextStyle(
                                            fontSize: 15,
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text('Keterangan',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _keteranganController,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  hintText: 'Tambahkan catatan opsional...',
                                  filled: true,
                                  fillColor: const Color(0xFFCDDAD4).withOpacity(0.65),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Tombol Aksi dibungkus BlocBuilder untuk memantau loading dari TransactionBloc
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: BlocBuilder<TransactionBloc, TransactionState>(
                          builder: (context, transactionState) {
                            final isSaving = transactionState is TransactionSavingLoading;
                            return Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton.icon(
                                    onPressed: isSaving ? null : _simpanTransaksi,
                                    icon: isSaving
                                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                        : const Icon(Icons.check_rounded, color: Colors.white, size: 22),
                                    label: Text(
                                      isSaving ? 'Menyimpan...' : 'Simpan Transaksi',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: const StadiumBorder()),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton.icon(
                                    onPressed: isSaving ? null : () => context.pop(),
                                    icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 22),
                                    label: const Text('Scan Ulang',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary)),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary.withOpacity(0.12),
                                        foregroundColor: AppColors.primary,
                                        elevation: 0,
                                        shape: const StadiumBorder()),
                                  ),
                                ),
                              ],
                            );
                          }
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

  Widget _buildCategoryChip(Category cat) {
    final isSelected = _selectedKategori == cat.name;
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
              color: Color(cat.bgColorValue),
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Color(cat.colorValue), width: 2.5)
                  : null,
            ),
            child: CategoryIconWidget(
              iconName: cat.iconName,
              color: Color(cat.colorValue),
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
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
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