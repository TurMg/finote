// features/category/domain/usecases/delete_category.dart

import '../repositories/i_category_repository.dart';

class DeleteCategoryUseCase {
  final ICategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  /// Soft delete — kategori tidak benar-benar dihapus, hanya ditandai isDeleted = true
  Future<void> call(String categoryId) async {
    await repository.deleteCategory(categoryId);
  }
}
