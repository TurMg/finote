// features/category/presentation/bloc/category_event.dart

import '../../domain/entities/category.dart';

abstract class CategoryEvent {}

/// Muat semua kategori aktif dari database
class LoadCategories extends CategoryEvent {}

/// Muat semua kategori termasuk yang sudah di-delete (untuk lookup)
class LoadAllCategories extends CategoryEvent {}

/// Tambah kategori baru
class AddCategory extends CategoryEvent {
  final Category category;
  AddCategory(this.category);
}

/// Update kategori yang sudah ada
class UpdateCategory extends CategoryEvent {
  final Category category;
  UpdateCategory(this.category);
}

/// Soft delete kategori
class DeleteCategory extends CategoryEvent {
  final String categoryId;
  DeleteCategory(this.categoryId);
}

/// Ubah urutan kategori setelah drag-and-drop
class ReorderCategory extends CategoryEvent {
  final int oldIndex;
  final int newIndex;
  ReorderCategory({required this.oldIndex, required this.newIndex});
}
