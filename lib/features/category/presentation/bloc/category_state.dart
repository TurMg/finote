// features/category/presentation/bloc/category_state.dart

import '../../domain/entities/category.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  /// Kategori aktif (non-deleted) — untuk form input
  final List<Category> categories;

  /// Semua kategori termasuk deleted — untuk lookup icon/warna transaksi lama
  final List<Category> allCategories;

  CategoryLoaded({
    required this.categories,
    required this.allCategories,
  });

  /// Helper: cari kategori berdasarkan nama (termasuk yang deleted)
  Category? findByName(String name) {
    try {
      return allCategories.firstWhere((c) => c.name == name);
    } catch (_) {
      return null;
    }
  }
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);
}
