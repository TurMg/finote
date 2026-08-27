// features/category/domain/repositories/i_category_repository.dart

import '../entities/category.dart';

abstract class ICategoryRepository {
  /// Ambil semua kategori yang aktif (isDeleted == false), diurutkan berdasarkan sortOrder
  Future<List<Category>> getActiveCategories();

  /// Ambil semua kategori termasuk yang sudah di-soft-delete (untuk lookup transaksi lama)
  Future<List<Category>> getAllCategories();

  /// Cari kategori berdasarkan nama (untuk lookup dari transaksi)
  Future<Category?> getCategoryByName(String name);

  /// Simpan kategori baru atau update yang sudah ada
  Future<void> saveCategory(Category category);

  /// Soft delete — set isDeleted = true
  Future<void> deleteCategory(String id);

  /// Update sortOrder seluruh kategori setelah user reorder
  Future<void> reorderCategories(List<String> orderedIds);

  /// Seed 4 kategori default saat pertama kali app dijalankan
  Future<void> seedDefaultCategories();
}
