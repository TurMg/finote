import '../entities/transaction.dart';
import '../repositories/i_transaction_repository.dart';

class UpdateTransaction {
  final ITransactionRepository repository;

  UpdateTransaction(this.repository);

  Future<void> call(Transaction transaction) async {
    return await repository.updateTransaction(transaction);
  }
}
