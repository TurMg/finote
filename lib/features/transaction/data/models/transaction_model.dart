// features/transaction/data/models/transaction_model.dart

import 'package:isar/isar.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  TransactionModel();
  
  Id id = Isar.autoIncrement; // ID internal Isar (Integer)
  
  @Index(unique: true)
  late String transactionId; // ID string asli dari Domain (UUID)
  
  late double nominal;
  late String category;
  late DateTime date;
  late String note;
  late String inputSource;
  String? imagePath;
  String type = 'EXPENSE'; // 'EXPENSE' atau 'INCOME'
  
  // Flag khusus infrastruktur Data Layer
  bool isSynced = false; 
  DateTime lastUpdated = DateTime.now();
  bool isDeleted = false;

  // Fungsi Mapper dari Entity ke Model
  factory TransactionModel.fromEntity(Transaction entity) {
    return TransactionModel()
      ..transactionId = entity.id
      ..nominal = entity.nominal
      ..category = entity.category
      ..date = entity.date
      ..note = entity.note
      ..inputSource = entity.inputSource
      ..imagePath = entity.imagePath
      ..type = entity.type
      ..isSynced = false
      ..lastUpdated = DateTime.now()
      ..isDeleted = false;
  }

  // Fungsi Mapper dari Model kembali ke Entity
  Transaction toEntity() {
    return Transaction(
      id: transactionId,
      nominal: nominal,
      category: category,
      date: date,
      note: note,
      inputSource: inputSource,
      imagePath: imagePath,
      type: type,
    );
  }
}