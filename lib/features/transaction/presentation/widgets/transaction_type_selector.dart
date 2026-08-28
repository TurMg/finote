import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/sliding_segmented_control.dart';

class TransactionTypeSelector extends StatelessWidget {
  final String selectedType; // 'EXPENSE' or 'INCOME'
  final ValueChanged<String> onChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = selectedType == 'EXPENSE';

    return SlidingSegmentedControl<String>(
      selectedValue: selectedType,
      items: const ['EXPENSE', 'INCOME'],
      height: 50,
      borderRadius: 16,
      activeColor: isExpense ? AppColors.expenseRed : AppColors.incomeGreen,
      labelBuilder: (type) => type == 'EXPENSE' ? 'Pengeluaran' : 'Pemasukan',
      customItemBuilder: (type, isActive) {
        final isExp = type == 'EXPENSE';
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExp ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              size: 18,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              isExp ? 'Pengeluaran' : 'Pemasukan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
      onChanged: onChanged,
    );
  }
}
