// features/category/data/datasources/category_local_datasource.dart

import 'package:isar/isar.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getActiveCategories();
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel?> getCategoryByName(String name);
  Future<CategoryModel?> getCategoryById(String categoryId);
  Future<void> saveCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
  Future<void> reorderCategories(List<String> orderedIds);
  Future<int> countCategories();
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final Isar isar;

  CategoryLocalDataSourceImpl(this.isar);

  @override
  Future<List<CategoryModel>> getActiveCategories() async {
    return await isar.categoryModels
        .filter()
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    return await isar.categoryModels.where().sortBySortOrder().findAll();
  }

  @override
  Future<CategoryModel?> getCategoryByName(String name) async {
    return await isar.categoryModels
        .filter()
        .nameEqualTo(name)
        .findFirst();
  }

  @override
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    return await isar.categoryModels
        .filter()
        .categoryIdEqualTo(categoryId)
        .findFirst();
  }

  @override
  Future<void> saveCategory(CategoryModel category) async {
    await isar.writeTxn(() async {
      // Cek apakah sudah ada berdasarkan categoryId ATAU name
      var existing = await isar.categoryModels
          .filter()
          .categoryIdEqualTo(category.categoryId)
          .findFirst();

      existing ??= await isar.categoryModels
          .filter()
          .nameEqualTo(category.name)
          .findFirst();

      if (existing != null) {
        // Update: gunakan id & categoryId Isar yang sudah ada
        category.id = existing.id;
        category.categoryId = existing.categoryId;
      }

      await isar.categoryModels.put(category);
    });
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await isar.writeTxn(() async {
      final model = await isar.categoryModels
          .filter()
          .categoryIdEqualTo(categoryId)
          .findFirst();

      if (model != null) {
        model.isDeleted = true;
        await isar.categoryModels.put(model);
      }
    });
  }

  @override
  Future<void> reorderCategories(List<String> orderedIds) async {
    await isar.writeTxn(() async {
      for (int i = 0; i < orderedIds.length; i++) {
        final model = await isar.categoryModels
            .filter()
            .categoryIdEqualTo(orderedIds[i])
            .findFirst();

        if (model != null) {
          model.sortOrder = i;
          await isar.categoryModels.put(model);
        }
      }
    });
  }

  @override
  Future<int> countCategories() async {
    return await isar.categoryModels.count();
  }
}
