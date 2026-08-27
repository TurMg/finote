// features/transaction/domain/usecases/save_transaction.dart

import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/i_transaction_repository.dart';

class SaveTransaction implements UseCase<void, Transaction> {
  final ITransactionRepository repository;

  SaveTransaction(this.repository);

  @override
  Future<void> call(Transaction params) async {
    // Lu bisa tambahin logic validasi bisnis di sini
    // Misal: Nominal tidak boleh 0 atau minus
    if (params.nominal <= 0) {
      throw Exception('Nominal transaksi harus lebih dari nol.');
    }
    
    // Apapun sumber inputnya (Scan/Voice/Manual), masuknya ke sini
    return await repository.saveTransaction(params);
  }
}