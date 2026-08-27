// features/category/data/repositories/category_repository_impl.dart

import '../../domain/entities/category.dart';
import '../../domain/repositories/i_category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements ICategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Category>> getActiveCategories() async {
    final models = await localDataSource.getActiveCategories();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Category>> getAllCategories() async {
    final models = await localDataSource.getAllCategories();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Category?> getCategoryByName(String name) async {
    final model = await localDataSource.getCategoryByName(name);
    return model?.toEntity();
  }

  @override
  Future<void> saveCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await localDataSource.saveCategory(model);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await localDataSource.deleteCategory(id);
  }

  @override
  Future<void> reorderCategories(List<String> orderedIds) async {
    await localDataSource.reorderCategories(orderedIds);
  }

  @override
  Future<void> seedDefaultCategories() async {
    // Delete/Remove old 'Lainnya (Pemasukan)' if present as requested by user
    final oldLainnya = await localDataSource.getCategoryByName('Lainnya (Pemasukan)');
    if (oldLainnya != null) {
      await localDataSource.deleteCategory(oldLainnya.categoryId);
    }

    final defaults = [
      // EXPENSE CATEGORIES
      Category(
        id: 'default_makanan',
        name: 'Makanan',
        iconName: 'restaurant_rounded',
        colorValue: 0xFFE05263,
        bgColorValue: 0xFFFAB5C7,
        sortOrder: 0,
        keywords: ['makan', 'nasi', 'warteg', 'roti', 'camilan', 'sarapan', 'bakso', 'mie', 'food'],
        isDefault: true,
        type: 'EXPENSE',
      ),
      Category(
        id: 'default_minuman',
        name: 'Minuman',
        iconName: 'local_cafe_rounded',
        colorValue: 0xFF4A90E2,
        bgColorValue: 0xFF96DCFF,
        sortOrder: 1,
        keywords: ['minum', 'kopi', 'es', 'teh', 'susu', 'boba', 'cafe'],
        isDefault: true,
        type: 'EXPENSE',
      ),
      Category(
        id: 'default_transport',
        name: 'Transport',
        iconName: 'directions_bus_rounded',
        colorValue: 0xFFF5A623,
        bgColorValue: 0xFFFFFDB4,
        sortOrder: 2,
        keywords: ['transport', 'bensin', 'parkir', 'ojek', 'gojek', 'grab', 'tol', 'kereta', 'bus', 'angkot'],
        isDefault: true,
        type: 'EXPENSE',
      ),
      Category(
        id: 'default_tagihan',
        name: 'Tagihan',
        iconName: 'receipt_long_rounded',
        colorValue: 0xFF006B2C,
        bgColorValue: 0xFF88F9B7,
        sortOrder: 3,
        keywords: ['tagihan', 'listrik', 'air', 'wifi', 'internet', 'pulsa', 'cicilan'],
        isDefault: true,
        type: 'EXPENSE',
      ),
      // INCOME CATEGORIES
      Category(
        id: 'default_gaji',
        name: 'Gaji',
        iconName: 'account_balance_wallet_rounded',
        colorValue: 0xFF10B981,
        bgColorValue: 0xFFA7F3D0,
        sortOrder: 4,
        keywords: ['gaji', 'paycheck', 'salary', 'payroll', 'pendapatan', 'bulanan'],
        isDefault: true,
        type: 'INCOME',
      ),
      Category(
        id: 'default_bonus',
        name: 'Bonus',
        iconName: 'card_giftcard_rounded',
        colorValue: 0xFF8B5CF6,
        bgColorValue: 0xFFDDD6FE,
        sortOrder: 5,
        keywords: ['bonus', 'thr', 'insentif', 'hadiah', 'reward'],
        isDefault: true,
        type: 'INCOME',
      ),
      Category(
        id: 'default_investasi',
        name: 'Investasi',
        iconName: 'trending_up_rounded',
        colorValue: 0xFF3B82F6,
        bgColorValue: 0xFFBFDBFE,
        sortOrder: 6,
        keywords: ['investasi', 'dividen', 'saham', 'crypto', 'reksadana', 'bunga'],
        isDefault: true,
        type: 'INCOME',
      ),
      Category(
        id: 'default_penjualan',
        name: 'Penjualan',
        iconName: 'storefront_rounded',
        colorValue: 0xFFF59E0B,
        bgColorValue: 0xFFFDE68A,
        sortOrder: 7,
        keywords: ['jual', 'penjualan', 'dagang', 'olshop', 'omset'],
        isDefault: true,
        type: 'INCOME',
      ),
    ];

    for (final category in defaults) {
      // Find existing category by categoryId OR by name
      var existing = await localDataSource.getCategoryById(category.id);
      existing ??= await localDataSource.getCategoryByName(category.name);

      if (existing == null) {
        final model = CategoryModel.fromEntity(category);
        await localDataSource.saveCategory(model);
      } else {
        // Force update the type if it differs from the default type
        final entity = existing.toEntity();
        if (entity.type != category.type) {
          final updated = Category(
            id: entity.id,
            name: entity.name,
            iconName: category.iconName,
            colorValue: category.colorValue,
            bgColorValue: category.bgColorValue,
            sortOrder: entity.sortOrder,
            keywords: entity.keywords,
            isDefault: true,
            isDeleted: false,
            type: category.type,
          );
          final model = CategoryModel.fromEntity(updated);
          await localDataSource.saveCategory(model);
        }
      }
    }
  }
}
