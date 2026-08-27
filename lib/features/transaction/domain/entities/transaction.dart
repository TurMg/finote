// features/transaction/domain/entities/transaction.dart

class Transaction {
  final String id;
  final double nominal;
  final String category;
  final DateTime date;
  final String note;
  final String inputSource; // Contoh: 'MANUAL', 'SCAN', 'VOICE'
  final String? imagePath;
  final String type; // 'EXPENSE' atau 'INCOME'

  Transaction({
    required this.id,
    required this.nominal,
    required this.category,
    required this.date,
    required this.note,
    required this.inputSource,
    this.imagePath,
    this.type = 'EXPENSE',
  });

  bool get isIncome => type == 'INCOME';
  bool get isExpense => type == 'EXPENSE';
}