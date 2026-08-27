import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/category_icon_widget.dart';
import '../../domain/entities/transaction.dart';
import '../../../category/presentation/bloc/category_bloc.dart';
import '../../../category/presentation/bloc/category_state.dart';
import 'update_transaction_bottom_sheet.dart';

class TransactionDetailBottomSheet extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailBottomSheet({super.key, required this.transaction});

  String _formatRupiah(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'id_ID').format(date);
  }

  String _inputSourceLabel(String source) {
    switch (source.toUpperCase()) {
      case 'MANUAL':
        return 'Input Manual';
      case 'SCAN':
        return 'Scan Struk';
      case 'VOICE':
        return 'Input Suara';
      default:
        return source;
    }
  }

  IconData _inputSourceIcon(String source) {
    switch (source.toUpperCase()) {
      case 'MANUAL':
        return Icons.edit_rounded;
      case 'SCAN':
        return Icons.document_scanner_rounded;
      case 'VOICE':
        return Icons.mic_rounded;
      default:
        return Icons.input_rounded;
    }
  }

  void _showImagePreview(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.6),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'INCOME';
    final amountPrefix = isIncome ? '+ ' : '- ';
    final amountColor = isIncome ? AppColors.incomeGreenDark : AppColors.expenseRedDark;

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, catState) {
        String iconName = isIncome ? 'account_balance_wallet_rounded' : 'receipt_long_rounded';
        Color iconColor = isIncome ? AppColors.incomeGreenDark : AppColors.primary;
        Color bgColor = isIncome ? AppColors.incomeSurface : AppColors.surfaceSubtle;

        if (catState is CategoryLoaded) {
          final cat = catState.findByName(transaction.category);
          if (cat != null) {
            iconName = cat.iconName;
            iconColor = Color(cat.colorValue);
            bgColor = Color(cat.bgColorValue);
          }
        }

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const SizedBox(height: 20),

              // Ikon Kategori
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: bgColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CategoryIconWidget(
                  iconName: iconName,
                  color: iconColor,
                  size: 30,
                  imageBorderRadius: 20,
                  useFullBox: true,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isIncome ? AppColors.incomeSurface : AppColors.expenseSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isIncome ? AppColors.incomeBorder : AppColors.expenseBorder,
                      ),
                    ),
                    child: Text(
                      isIncome ? 'Pemasukan • ${transaction.category}' : 'Pengeluaran • ${transaction.category}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isIncome ? AppColors.incomeGreenDark : AppColors.expenseRedDark,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Nominal
              Text(
                '$amountPrefix${_formatRupiah(transaction.nominal)}',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                  letterSpacing: -1.2,
                ),
              ),

              const SizedBox(height: 20),

              // Detail Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.calendar_today_rounded,
                      iconBgColor: AppColors.incomeSurface,
                      iconColor: AppColors.incomeGreenDark,
                      label: 'Tanggal',
                      value: _formatDate(transaction.date),
                    ),
                    if (transaction.note.trim().isNotEmpty) ...[
                      Divider(height: 1, color: AppColors.divider.withOpacity(0.5)),
                      _buildDetailRow(
                        icon: Icons.sticky_note_2_rounded,
                        iconBgColor: const Color(0xFFFFF3E0),
                        iconColor: const Color(0xFFF57C00),
                        label: 'Catatan',
                        value: transaction.note,
                      ),
                    ],
                    Divider(height: 1, color: AppColors.divider.withOpacity(0.5)),
                    _buildDetailRow(
                      icon: _inputSourceIcon(transaction.inputSource),
                      iconBgColor: const Color(0xFFE3F2FD),
                      iconColor: const Color(0xFF1565C0),
                      label: 'Sumber',
                      value: _inputSourceLabel(transaction.inputSource),
                    ),
                  ],
                ),
              ),

              if (transaction.imagePath != null && transaction.imagePath!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCE4EC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.photo_rounded, size: 16, color: Color(0xFFC62828)),
                          ),
                          const SizedBox(width: 10),
                          const Text('Foto Struk', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _showImagePreview(context, transaction.imagePath!),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(transaction.imagePath!),
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceSubtle,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text('Foto tidak ditemukan', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.zoom_in_rounded, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Ketuk untuk perbesar',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => UpdateTransactionBottomSheet(transaction: transaction),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit Transaksi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
