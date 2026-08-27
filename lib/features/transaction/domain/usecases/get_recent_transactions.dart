import '../entities/transaction.dart';
import '../repositories/i_transaction_repository.dart';

class GetRecentTransactions {
  final ITransactionRepository repository;

  GetRecentTransactions(this.repository);

  Future<List<Transaction>> call() async {
    return await repository.getAllTransactions();
  }
}