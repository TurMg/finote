// features/transaction/presentation/bloc/transaction_state.dart

import '../../domain/entities/transaction.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionError extends TransactionState {
  final String message;

  TransactionError(this.message);
}

class TransactionSavingLoading extends TransactionState {}

class TransactionSavingSuccess extends TransactionState {}

class TransactionLoading extends TransactionState {}

class RecentTransactionsLoaded extends TransactionState {
  final List<Transaction> transactions;
  final double totalPengeluaranBulanIni;
  final double totalPemasukanBulanIni;
  final double saldoBulanIni;
  final double totalPengeluaranBulanLalu;
  final double totalPemasukanBulanLalu;

  RecentTransactionsLoaded({
    required this.transactions,
    required this.totalPengeluaranBulanIni,
    required this.totalPemasukanBulanIni,
    required this.saldoBulanIni,
    required this.totalPengeluaranBulanLalu,
    required this.totalPemasukanBulanLalu,
  });

  // Getter legacy alias agar widget lama yang pakai totalBulanIni & totalBulanLalu tidak breaking
  double get totalBulanIni => totalPengeluaranBulanIni;
  double get totalBulanLalu => totalPengeluaranBulanLalu;
}