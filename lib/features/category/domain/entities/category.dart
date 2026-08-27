// features/category/domain/entities/category.dart

class Category {
  final String id;
  final String name;
  final String iconName;
  final int colorValue;
  final int bgColorValue;
  final int sortOrder;
  final List<String> keywords;
  final bool isDefault;
  final bool isDeleted;
  final String type; // 'EXPENSE', 'INCOME', 'BOTH'

  Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorValue,
    required this.bgColorValue,
    required this.sortOrder,
    this.keywords = const [],
    this.isDefault = false,
    this.isDeleted = false,
    this.type = 'EXPENSE',
  });

  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    int? colorValue,
    int? bgColorValue,
    int? sortOrder,
    List<String>? keywords,
    bool? isDefault,
    bool? isDeleted,
    String? type,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      bgColorValue: bgColorValue ?? this.bgColorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      keywords: keywords ?? this.keywords,
      isDefault: isDefault ?? this.isDefault,
      isDeleted: isDeleted ?? this.isDeleted,
      type: type ?? this.type,
    );
  }
}

