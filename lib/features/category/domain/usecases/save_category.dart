// features/category/domain/usecases/save_category.dart

import '../entities/category.dart';
import '../repositories/i_category_repository.dart';

class SaveCategoryUseCase {
  final ICategoryRepository repository;

  SaveCategoryUseCase(this.repository);

  Future<void> call(Category category) async {
    await repository.saveCategory(category);
  }
}
