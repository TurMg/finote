import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/category_icon_widget.dart';
import '../../domain/entities/transaction.dart';
import '../../../category/presentation/bloc/category_state.dart';

class TransactionCardTile extends StatelessWidget {
  final Transaction transaction;
  final CategoryState categoryState;
  final VoidCallback? onTap;
  final bool isGrouped;

  const TransactionCardTile({
    super.key,
    required this.transaction,
    required this.categoryState,
    this.onTap,
    this.isGrouped = false,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'INCOME';

    // Default icon fallback
    String iconName = isIncome ? 'account_balance_wallet_rounded' : 'receipt_long_rounded';
    Color iconColor = isIncome ? AppColors.incomeGreenDark : AppColors.primary;
    Color bgColor = isIncome ? AppColors.incomeSurface : AppColors.surfaceSubtle;

    if (categoryState is CategoryLoaded) {
      final cat = (categoryState as CategoryLoaded).findByName(transaction.category);
      if (cat != null) {
        iconName = cat.iconName;
        iconColor = Color(cat.colorValue);
        bgColor = Color(cat.bgColorValue);
      }
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final transactionDate = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
    final timeString = DateFormat('HH:mm').format(transaction.date);
    final categoryName = transaction.category;

    String timeDisplay;
    if (transactionDate == today) {
      timeDisplay = 'Hari ini, $timeString';
    } else if (transactionDate == yesterday) {
      timeDisplay = 'Kemarin, $timeString';
    } else {
      timeDisplay = '${DateFormat('dd MMM', 'id_ID').format(transaction.date)}, $timeString';
    }

    String subtitleText;
    if (isGrouped) {
      subtitleText = '$categoryName • $timeString';
    } else {
      subtitleText = timeDisplay;
    }

    final formatUang = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(transaction.nominal);
    final title = (transaction.note.trim().isNotEmpty) ? transaction.note : transaction.category;
    final amountPrefix = isIncome ? '+ ' : '- ';
    final amountColor = isIncome ? AppColors.incomeGreenDark : AppColors.expenseRedDark;

    Widget content = InkWell(
      borderRadius: BorderRadius.circular(isGrouped ? 0 : 16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: isGrouped
            ? null
            : BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder.withOpacity(0.4), width: 0.8),
              ),
        child: Row(
          children: [
            // Icon Avatar Container
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: CategoryIconWidget(
                iconName: iconName,
                color: iconColor,
                size: 24,
                imageBorderRadius: 14,
                useFullBox: true,
              ),
            ),
            const SizedBox(width: 14),
            // Title and Subtitle Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        subtitleText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (transaction.imagePath != null && transaction.imagePath!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.image_outlined, size: 12, color: AppColors.primary),
                              SizedBox(width: 3),
                              Text(
                                'Struk',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Nominal Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$amountPrefix$formatUang',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isGrouped) {
      return content;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: content,
      ),
    );
  }
}
