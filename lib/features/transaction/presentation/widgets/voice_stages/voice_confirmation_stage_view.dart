import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/constants/colors.dart';
import '../../../../../../core/widgets/category_icon_widget.dart';
import '../../../../category/domain/entities/category.dart';
import '../../../../category/presentation/bloc/category_bloc.dart';
import '../../../../category/presentation/bloc/category_state.dart';
import '../transaction_type_selector.dart';

class VoiceConfirmationStageView extends StatelessWidget {
  final String text;
  final String selectedType;
  final ValueChanged<String> onTypeChanged;
  final TextEditingController nominalController;
  final FocusNode nominalFocusNode;
  final ValueChanged<String> onNominalChanged;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onAddCategory;
  final TextEditingController noteController;
  final VoidCallback onSaveTransaction;
  final VoidCallback onRetryVoice;

  const VoiceConfirmationStageView({
    super.key,
    required this.text,
    required this.selectedType,
    required this.onTypeChanged,
    required this.nominalController,
    required this.nominalFocusNode,
    required this.onNominalChanged,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onAddCategory,
    required this.noteController,
    required this.onSaveTransaction,
    required this.onRetryVoice,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Text(
          'Konfirmasi Transaksi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),

        // Gelembung Teks Suara
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Icon(Icons.graphic_eq_rounded, size: 18, color: accentColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '"$text"',
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
        const SizedBox(height: 20),

        // Type Selector
        TransactionTypeSelector(
          selectedType: selectedType,
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 20),

        // Nominal
        Center(
          child: Text(
            selectedType == 'INCOME'
                ? 'NOMINAL PEMASUKAN'
                : 'NOMINAL PENGELUARAN',
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
            if (nominalFocusNode.hasFocus) {
              nominalFocusNode.unfocus();
            }
            Future.delayed(const Duration(milliseconds: 50), () {
              nominalFocusNode.requestFocus();
            });
          },
          child: Container(
            width: double.infinity,
            color: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                    focusNode: nominalFocusNode,
                    controller: nominalController,
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
                    onChanged: onNominalChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Kategori
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
              final filtered = catState.categories
                  .where((c) => c.type == selectedType || c.type == 'BOTH')
                  .toList();
              final categories = filtered.isNotEmpty ? filtered : catState.categories;

              // Append the "+" add chip to the item list
              final items = <Widget>[
                ...categories.map(_buildCategoryChip),
                _buildAddCategoryChip(),
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
            return const Center(child: CircularProgressIndicator());
          },
        ),
        const SizedBox(height: 20),

        // Keterangan
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
          controller: noteController,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
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
        const SizedBox(height: 28),

        // Tombol Simpan
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onSaveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'Simpan Transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Tombol Ulangi Voice
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton.icon(
            onPressed: onRetryVoice,
            icon: const Icon(Icons.mic_rounded, size: 18),
            label: const Text(
              'Ulangi dengan Suara',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCategoryChip(Category category) {
    final isSelected = selectedCategory == category.name;
    final catColor = Color(category.colorValue);
    final bgColor = Color(category.bgColorValue);

    return GestureDetector(
      onTap: () => onCategorySelected(category.name),
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

  /// Chip "+" untuk menambah kategori baru.
  Widget _buildAddCategoryChip() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppColors.surfaceSubtle,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: onAddCategory,
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
}
