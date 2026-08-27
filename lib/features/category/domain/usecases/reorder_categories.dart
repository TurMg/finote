// features/category/domain/usecases/reorder_categories.dart

import '../repositories/i_category_repository.dart';

class ReorderCategoriesUseCase {
  final ICategoryRepository repository;

  ReorderCategoriesUseCase(this.repository);

  /// Update sortOrder seluruh kategori berdasarkan urutan ID yang diberikan
  Future<void> call(List<String> orderedIds) async {
    await repository.reorderCategories(orderedIds);
  }
}
