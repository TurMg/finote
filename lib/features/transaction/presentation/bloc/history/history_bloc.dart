import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/i_transaction_repository.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final ITransactionRepository _repository;

  HistoryBloc(this._repository) : super(const HistoryState()) {
    on<LoadHistory>(_onLoadHistory);
    on<FilterHistoryChanged>(_onFilterChanged);
    on<TypeFilterChanged>(_onTypeFilterChanged);
    on<SearchHistoryChanged>(_onSearchChanged);
    on<UpdateTransactionsData>(_onUpdateData);
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final transactions = await _repository.getAllTransactions();
      emit(state.copyWith(
        allTransactions: transactions,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onUpdateData(UpdateTransactionsData event, Emitter<HistoryState> emit) {
    emit(state.copyWith(
      allTransactions: event.transactions,
      isLoading: false,
    ));
  }

  void _onFilterChanged(FilterHistoryChanged event, Emitter<HistoryState> emit) {
    emit(state.copyWith(filterMode: event.mode));
  }

  void _onTypeFilterChanged(TypeFilterChanged event, Emitter<HistoryState> emit) {
    emit(state.copyWith(typeFilter: event.typeFilter));
  }

  void _onSearchChanged(SearchHistoryChanged event, Emitter<HistoryState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }
}