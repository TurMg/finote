// lib/features/category/presentation/widgets/category_grid_item.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/category_icon_widget.dart';
import '../../domain/entities/category.dart';

class CategoryGridItem extends StatelessWidget {
  final Category category;
  final bool isEditMode;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CategoryGridItem({
    super.key,
    required this.category,
    required this.isEditMode,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final canDelete = isEditMode && onDelete != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Container Icon Utama
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(category.bgColorValue),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CategoryIconWidget(
                  iconName: category.iconName,
                  color: Color(category.colorValue),
                  size: 28,
                  imageBorderRadius: 18,
                  useFullBox: true,
                ),
              ),

              // Badge Minus (Hapus) di Pojok Kanan Atas
              if (canDelete)
                Positioned(
                  top: -5,
                  right: -5,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.remove_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Label Nama Kategori
          Text(
            category.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget khusus untuk Tile "+ Tambah" di dalam Grid
class CategoryAddGridTile extends StatelessWidget {
  final VoidCallback onTap;

  const CategoryAddGridTile({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.textHint.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.add_rounded,
                color: AppColors.textSecondary,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 8),
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
      ),
    );
  }
}
