// features/transaction/presentation/bloc/transaction_event.dart
import '../../domain/entities/transaction.dart';

abstract class TransactionEvent {}

class ManualInputSaved extends TransactionEvent {
  final double nominal;
  final String category;
  final DateTime date;
  final String note;
  final String inputSource;
  final String? imagePath;
  final String type; // 'EXPENSE' or 'INCOME'

  ManualInputSaved({
    required this.nominal,
    required this.category,
    required this.date,
    required this.note,
    this.inputSource = 'MANUAL',
    this.imagePath,
    this.type = 'EXPENSE',
  });
}

class FetchRecentTransactions extends TransactionEvent {}

class TransactionUpdated extends TransactionEvent {
  final Transaction transaction;
  TransactionUpdated(this.transaction);
}

class TransactionDeleted extends TransactionEvent {
  final String transactionId;
  TransactionDeleted(this.transactionId);
}

class VoiceTransactionStarted extends TransactionEvent {
  final String rawText;

  VoiceTransactionStarted(this.rawText);
}