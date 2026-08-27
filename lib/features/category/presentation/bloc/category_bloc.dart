// features/category/presentation/bloc/category_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/save_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/reorder_categories.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories getCategories;
  final SaveCategoryUseCase saveCategory;
  final DeleteCategoryUseCase deleteCategory;
  final ReorderCategoriesUseCase reorderCategories;

  CategoryBloc({
    required this.getCategories,
    required this.saveCategory,
    required this.deleteCategory,
    required this.reorderCategories,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<LoadAllCategories>(_onLoadAllCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<ReorderCategory>(_onReorderCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      await getCategories.seedDefaultCategories();
      final active = await getCategories();
      final all = await getCategories.allIncludingDeleted();
      emit(CategoryLoaded(categories: active, allCategories: all));
    } catch (e) {
      emit(CategoryError('Gagal memuat kategori: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAllCategories(
    LoadAllCategories event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      final active = await getCategories();
      final all = await getCategories.allIncludingDeleted();
      emit(CategoryLoaded(categories: active, allCategories: all));
    } catch (e) {
      emit(CategoryError('Gagal memuat kategori: ${e.toString()}'));
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await saveCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('Gagal menambah kategori: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await saveCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('Gagal mengupdate kategori: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await deleteCategory(event.categoryId);
      add(LoadCategories());
    } catch (e) {
      emit(CategoryError('Gagal menghapus kategori: ${e.toString()}'));
    }
  }

  Future<void> _onReorderCategory(
    ReorderCategory event,
    Emitter<CategoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CategoryLoaded) return;

    try {
      final categories = List.of(currentState.categories);
      int oldIdx = event.oldIndex;
      int newIdx = event.newIndex;

      // ReorderableListView behavior: jika geser ke bawah, newIndex perlu dikurangi 1
      if (newIdx > oldIdx) newIdx--;

      final item = categories.removeAt(oldIdx);
      categories.insert(newIdx, item);

      // Emit state optimistic (UI langsung update tanpa jeda loading)
      emit(CategoryLoaded(
        categories: categories,
        allCategories: currentState.allCategories,
      ));

      // Simpan urutan baru ke database secara senyap di background
      final orderedIds = categories.map((c) => c.id).toList();
      await reorderCategories(orderedIds);
    } catch (e) {
      emit(CategoryError('Gagal mengubah urutan: ${e.toString()}'));
    }
  }
}
