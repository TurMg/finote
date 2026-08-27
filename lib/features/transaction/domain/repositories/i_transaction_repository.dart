import '../entities/transaction.dart';

abstract class ITransactionRepository {
  Future<void> saveTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  
  Future<List<Transaction>> getAllTransactions();
}