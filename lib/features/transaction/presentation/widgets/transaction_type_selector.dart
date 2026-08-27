import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

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

    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Segment 1: Pengeluaran
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged('EXPENSE'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isExpense ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isExpense
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_downward_rounded,
                      size: 18,
                      color: isExpense ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pengeluaran',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isExpense ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Segment 2: Pemasukan
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged('INCOME'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: selectedType == 'INCOME' ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: selectedType == 'INCOME'
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 18,
                      color: selectedType == 'INCOME' ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pemasukan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: selectedType == 'INCOME' ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
