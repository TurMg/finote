// features/category/data/models/category_model.dart

import 'package:isar/isar.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  CategoryModel();

  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String categoryId;

  @Index(unique: true)
  late String name;

  late String iconName;
  late int colorValue;
  late int bgColorValue;
  late int sortOrder;
  late List<String> keywords;
  late bool isDefault;
  late bool isDeleted;
  String type = 'EXPENSE'; // 'EXPENSE', 'INCOME', 'BOTH'

  // Mapper dari Entity ke Model
  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel()
      ..categoryId = entity.id
      ..name = entity.name
      ..iconName = entity.iconName
      ..colorValue = entity.colorValue
      ..bgColorValue = entity.bgColorValue
      ..sortOrder = entity.sortOrder
      ..keywords = entity.keywords
      ..isDefault = entity.isDefault
      ..isDeleted = entity.isDeleted
      ..type = entity.type;
  }

  // Mapper dari Model ke Entity
  Category toEntity() {
    return Category(
      id: categoryId,
      name: name,
      iconName: iconName,
      colorValue: colorValue,
      bgColorValue: bgColorValue,
      sortOrder: sortOrder,
      keywords: keywords,
      isDefault: isDefault,
      isDeleted: isDeleted,
      type: type,
    );
  }
}
