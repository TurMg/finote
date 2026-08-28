import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_event.dart';
import '../../../category/presentation/bloc/category_state.dart';
import '../../../category/presentation/widgets/form_kategori_bottom_sheet.dart';
import '../../../category/domain/entities/category.dart';
import '../../../../core/widgets/top_snackbar.dart';
import '../../../../core/widgets/category_icon_widget.dart';
import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';
import 'transaction_type_selector.dart';

class UpdateTransactionBottomSheet extends StatefulWidget {
  final Transaction transaction;

  const UpdateTransactionBottomSheet({super.key, required this.transaction});

  @override
  State<UpdateTransactionBottomSheet> createState() =>
      _UpdateTransactionBottomSheetState();
}

class _UpdateTransactionBottomSheetState
    extends State<UpdateTransactionBottomSheet> {
  late TextEditingController _nominalController;
  late TextEditingController _keteranganController;
  late String _transactionType;
  late String _selectedKategori;
  late DateTime _selectedDate;
  late FocusNode _nominalFocusNode;
  String? _currentImagePath;

  @override
  void initState() {
    super.initState();
    _nominalFocusNode = FocusNode();
    _nominalController = TextEditingController(
      text: NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0)
          .format(widget.transaction.nominal)
          .trim(),
    );
    _keteranganController = TextEditingController(text: widget.transaction.note);
    _transactionType = widget.transaction.type;
    if (_transactionType != 'INCOME' && _transactionType != 'EXPENSE') {
      _transactionType = 'EXPENSE';
    }
    _selectedKategori = widget.transaction.category;
    _selectedDate = widget.transaction.date;
    _currentImagePath = widget.transaction.imagePath;
  }

  @override
  void dispose() {
    _nominalFocusNode.dispose();
    _nominalController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Sumber Foto Struk',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              ),
              title: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Ambil foto struk baru secara langsung'),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() => _currentImagePath = image.path);
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.incomeSurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.incomeGreenDark),
              ),
              title: const Text('Galeri Foto', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Pilih foto dari album penyimpanan'),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() => _currentImagePath = image.path);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
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

  void _onSave() {
    final nominalStr = _nominalController.text.replaceAll('.', '');
    final nominal = double.tryParse(nominalStr) ?? 0.0;

    if (nominal <= 0) {
      TopSnackBar.show(context,
          message: 'Jumlah transaksi tidak valid', type: TopSnackBarType.error);
      return;
    }

    final updatedTransaction = Transaction(
      id: widget.transaction.id,
      nominal: nominal,
      category: _selectedKategori,
      date: _selectedDate,
      note: _keteranganController.text,
      inputSource: widget.transaction.inputSource,
      imagePath: _currentImagePath,
      type: _transactionType,
    );

    context.read<TransactionBloc>().add(TransactionUpdated(updatedTransaction));
  }

  void _onDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin menghapus transaksi ini? Data yang sudah dihapus tidak bisa dikembalikan.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<TransactionBloc>().add(TransactionDeleted(widget.transaction.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color get accentColor => AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final isIncome = _transactionType == 'INCOME';

    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSavingSuccess) {
          Navigator.pop(context);
          context.read<HistoryBloc>().add(LoadHistory());
          TopSnackBar.show(context,
              message: 'Transaksi berhasil disimpan!',
              type: TopSnackBarType.success);
        } else if (state is TransactionError) {
          TopSnackBar.show(context,
              message: state.message, type: TopSnackBarType.error);
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  top: 12,
                  left: 24,
                  right: 24,
                ),
                children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Update Transaksi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    InkWell(
                      onTap: _onDelete,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                TransactionTypeSelector(
                  selectedType: _transactionType,
                  onChanged: (newType) {
                    if (_transactionType != newType) {
                      setState(() {
                        _transactionType = newType;
                      });
                    }
                  },
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    isIncome ? 'NOMINAL PEMASUKAN' : 'NOMINAL PENGELUARAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    if (_nominalFocusNode.hasFocus) {
                      _nominalFocusNode.unfocus();
                    }
                    Future.delayed(const Duration(milliseconds: 50), () {
                      if (mounted) _nominalFocusNode.requestFocus();
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
                        Text(
                          'Rp ',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        IntrinsicWidth(
                          child: TextField(
                            focusNode: _nominalFocusNode,
                            controller: _nominalController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                              letterSpacing: -0.5,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) {
                              final cleanVal = value.replaceAll('.', '');
                              final parsed = int.tryParse(cleanVal);
                              if (parsed != null) {
                                final formatted = NumberFormat.currency(
                                        locale: 'id_ID',
                                        symbol: '',
                                        decimalDigits: 0)
                                    .format(parsed)
                                    .trim();
                                _nominalController.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(
                                      offset: formatted.length),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Kategori',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, catState) {
                    if (catState is CategoryLoaded) {
                      final filteredCategories = catState.categories
                          .where((c) => c.type == _transactionType)
                          .toList();
                      final categories = filteredCategories.isNotEmpty
                          ? filteredCategories
                          : catState.categories;

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
                        mainAxisSize: MainAxisSize.min,
                        children: categoryRows,
                      );
                    }
                    return const CircularProgressIndicator();
                  },
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
                InkWell(
                  onTap: () => _selectDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: accentColor),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                          style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Keterangan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _keteranganController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Tambahkan catatan opsional...',
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
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.all(14),
                    hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Foto Struk',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_currentImagePath != null && _currentImagePath!.isNotEmpty)
                      InkWell(
                        onTap: () => setState(() => _currentImagePath = null),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                              SizedBox(width: 4),
                              Text('Hapus Foto', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_currentImagePath != null && _currentImagePath!.isNotEmpty) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(_currentImagePath!),
                          height: 140,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text('Foto tidak dapat dimuat', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: ElevatedButton.icon(
                          onPressed: _showImageSourceDialog,
                          icon: const Icon(Icons.camera_alt_rounded, size: 14),
                          label: const Text('Scan Ulang / Ganti', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.75),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  InkWell(
                    onTap: _showImageSourceDialog,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.add_a_photo_outlined, color: accentColor, size: 26),
                          const SizedBox(height: 6),
                          Text(
                            'Tambah / Scan Foto Struk Baru',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: accentColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      final isLoading = state is TransactionSavingLoading;
                      return ElevatedButton(
                        onPressed: isLoading ? null : _onSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    ),
    );
  }

  Widget _buildCategoryChip(Category category) {
    final isSelected = _selectedKategori == category.name;
    final catColor = Color(category.colorValue);
    final bgColor = Color(category.bgColorValue);

    return GestureDetector(
      onTap: () => setState(() => _selectedKategori = category.name),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? catColor : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: CategoryIconWidget(
              iconName: category.iconName,
              color: catColor,
              size: 24,
              imageBorderRadius: 26,
              useFullBox: true,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
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
      });
    }
  }
}
