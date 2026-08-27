// features/category/domain/usecases/get_categories.dart

import '../entities/category.dart';
import '../repositories/i_category_repository.dart';

class GetCategories {
  final ICategoryRepository repository;

  GetCategories(this.repository);

  /// Ambil kategori aktif (non-deleted) untuk form input
  Future<List<Category>> call() async {
    return await repository.getActiveCategories();
  }

  /// Ambil semua kategori termasuk deleted (untuk lookup transaksi lama)
  Future<List<Category>> allIncludingDeleted() async {
    return await repository.getAllCategories();
  }

  /// Cari kategori berdasarkan nama
  Future<Category?> byName(String name) async {
    return await repository.getCategoryByName(name);
  }

  /// Seed/Sync kategori default
  Future<void> seedDefaultCategories() async {
    await repository.seedDefaultCategories();
  }
}
