import 'package:isar/isar.dart';
import '../models/transaction_model.dart';

abstract class TransactionLocalDataSource {
  Future<void> saveTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String transactionId);
  Future<List<TransactionModel>> getAllTransactions();
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  final Isar isar;

  TransactionLocalDataSourceImpl(this.isar);

  @override
  Future<void> saveTransaction(TransactionModel transaction) async {
    await isar.writeTxn(() async {
      await isar.transactionModels.put(transaction);
    });
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await isar.writeTxn(() async {
      final existing = await isar.transactionModels.filter().transactionIdEqualTo(transaction.transactionId).findFirst();
      if (existing != null) {
        transaction.id = existing.id; // Pastikan Isar autoIncrement id tidak berubah
        transaction.isSynced = false;
        transaction.lastUpdated = DateTime.now();
        await isar.transactionModels.put(transaction);
      }
    });
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await isar.writeTxn(() async {
      final existing = await isar.transactionModels.filter().transactionIdEqualTo(transactionId).findFirst();
      if (existing != null) {
        existing.isDeleted = true;
        existing.isSynced = false;
        existing.lastUpdated = DateTime.now();
        await isar.transactionModels.put(existing);
      }
    });
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    return await isar.transactionModels.filter().isDeletedEqualTo(false).findAll();
  }
}