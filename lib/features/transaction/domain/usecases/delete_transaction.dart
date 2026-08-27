import '../repositories/i_transaction_repository.dart';

class DeleteTransaction {
  final ITransactionRepository repository;

  DeleteTransaction(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteTransaction(id);
  }
}
