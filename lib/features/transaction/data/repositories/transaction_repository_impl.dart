import '../../domain/entities/transaction.dart';
import '../../domain/repositories/i_transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements ITransactionRepository {
  final TransactionLocalDataSource localDataSource;

  TransactionRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<void> saveTransaction(Transaction transaction) async {
    final model = TransactionModel()
      ..transactionId = transaction.id 
      ..nominal = transaction.nominal
      ..category = transaction.category
      ..date = transaction.date
      ..note = transaction.note
      ..inputSource = transaction.inputSource
      ..imagePath = transaction.imagePath
      ..type = transaction.type
      ..lastUpdated = DateTime.now();

    await localDataSource.saveTransaction(model);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final model = TransactionModel()
      ..transactionId = transaction.id 
      ..nominal = transaction.nominal
      ..category = transaction.category
      ..date = transaction.date
      ..note = transaction.note
      ..inputSource = transaction.inputSource
      ..imagePath = transaction.imagePath
      ..type = transaction.type;

    await localDataSource.updateTransaction(model);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await localDataSource.deleteTransaction(id);
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final models = await localDataSource.getAllTransactions();

    return models
        .map((m) => Transaction(
              id: m.transactionId,
              nominal: m.nominal,
              category: m.category,
              date: m.date,
              note: m.note,
              inputSource: m.inputSource,
              imagePath: m.imagePath,
              type: m.type,
            ))
        .toList();
  }
}
