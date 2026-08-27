// lib/features/category/presentation/widgets/category_type_tab_bar.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class CategoryTypeTabBar extends StatelessWidget {
  final String selectedType; // 'EXPENSE' or 'INCOME'
  final ValueChanged<String> onTypeChanged;

  const CategoryTypeTabBar({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.cardBorder.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              label: 'Pengeluaran',
              type: 'EXPENSE',
              isSelected: selectedType == 'EXPENSE',
            ),
          ),
          Expanded(
            child: _buildTabItem(
              label: 'Pemasukan',
              type: 'INCOME',
              isSelected: selectedType == 'INCOME',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String label,
    required String type,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (type == 'EXPENSE'
                    ? AppColors.expenseRed
                    : AppColors.incomeGreen)
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
