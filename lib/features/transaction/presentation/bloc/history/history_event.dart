import 'history_state.dart';
import '../../../domain/entities/transaction.dart';

abstract class HistoryEvent {}

class LoadHistory extends HistoryEvent {}

class FilterHistoryChanged extends HistoryEvent {
  final FilterMode mode;
  FilterHistoryChanged(this.mode);
}

class TypeFilterChanged extends HistoryEvent {
  final TransactionTypeFilter typeFilter;
  TypeFilterChanged(this.typeFilter);
}

class SearchHistoryChanged extends HistoryEvent {
  final String query;
  SearchHistoryChanged(this.query);
}

class UpdateTransactionsData extends HistoryEvent {
  final List<Transaction> transactions;
  UpdateTransactionsData(this.transactions);
}