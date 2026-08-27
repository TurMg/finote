import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/usecases/save_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_recent_transactions.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/parse_voice_input.dart';
import '../../../category/domain/usecases/get_categories.dart';
import '../../../../core/services/sync_service.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final SaveTransaction saveTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;
  final GetRecentTransactions getRecentTransactions;
  final ParseVoiceInput parseVoiceInput;
  final GetCategories getCategories;
  final SyncService syncService;

  TransactionBloc({
    required this.saveTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
    required this.getRecentTransactions,
    required this.parseVoiceInput,
    required this.getCategories,
    required this.syncService,
  }) : super(TransactionInitial()) {
    on<ManualInputSaved>(_onManualInputSaved);
    on<FetchRecentTransactions>(_onFetchRecentTransactions);
    on<TransactionUpdated>(_onTransactionUpdated);
    on<TransactionDeleted>(_onTransactionDeleted);
    on<VoiceTransactionStarted>(_onVoiceTransactionStarted);
  }

  Future<void> _onFetchRecentTransactions(
    FetchRecentTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await getRecentTransactions();

      final now = DateTime.now();
      final currentMonth = now.month;
      final currentYear = now.year;

      int prevMonth = currentMonth - 1;
      int prevYear = currentYear;
      if (prevMonth == 0) {
        prevMonth = 12;
        prevYear -= 1;
      }

      final thisMonthTx = transactions
          .where((t) => t.date.year == currentYear && t.date.month == currentMonth)
          .toList();

      final prevMonthTx = transactions
          .where((t) => t.date.year == prevYear && t.date.month == prevMonth)
          .toList();

      final totalPengeluaranBulanIni = thisMonthTx
          .where((t) => t.type != 'INCOME')
          .fold<double>(0, (sum, t) => sum + t.nominal);

      final totalPemasukanBulanIni = thisMonthTx
          .where((t) => t.type == 'INCOME')
          .fold<double>(0, (sum, t) => sum + t.nominal);

      final saldoBulanIni = totalPemasukanBulanIni - totalPengeluaranBulanIni;

      final totalPengeluaranBulanLalu = prevMonthTx
          .where((t) => t.type != 'INCOME')
          .fold<double>(0, (sum, t) => sum + t.nominal);

      final totalPemasukanBulanLalu = prevMonthTx
          .where((t) => t.type == 'INCOME')
          .fold<double>(0, (sum, t) => sum + t.nominal);

      transactions.sort((a, b) => b.date.compareTo(a.date));

      emit(RecentTransactionsLoaded(
        transactions: transactions,
        totalPengeluaranBulanIni: totalPengeluaranBulanIni,
        totalPemasukanBulanIni: totalPemasukanBulanIni,
        saldoBulanIni: saldoBulanIni,
        totalPengeluaranBulanLalu: totalPengeluaranBulanLalu,
        totalPemasukanBulanLalu: totalPemasukanBulanLalu,
      ));
    } catch (e) {
      emit(TransactionError("Gagal memuat riwayat transaksi: ${e.toString()}"));
    }
  }

  Future<void> _onManualInputSaved(
    ManualInputSaved event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionSavingLoading());
    try {
      String? finalImagePath;

      if (event.imagePath != null && event.imagePath!.isNotEmpty) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final receiptsDir = Directory('${appDocDir.path}/receipts');
        if (!await receiptsDir.exists()) {
          await receiptsDir.create(recursive: true);
        }
        
        final fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = await File(event.imagePath!).copy('${receiptsDir.path}/$fileName');
        finalImagePath = savedImage.path;
      }

      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nominal: event.nominal,
        category: event.category,
        date: event.date,
        note: event.note,
        inputSource: event.inputSource,
        imagePath: finalImagePath,
        type: event.type,
      );

      await saveTransaction(newTransaction);

      emit(TransactionSavingSuccess());
      add(FetchRecentTransactions()); // Auto refresh list
      
      // Auto background sync
      syncService.syncNow().catchError((e) => debugPrint("Auto-sync failed: $e"));
    } catch (e) {
      emit(TransactionError("Gagal menyimpan transaksi: ${e.toString()}"));
    }
  }

  Future<void> _onTransactionUpdated(
    TransactionUpdated event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionSavingLoading());
    try {
      await updateTransaction(event.transaction);
      emit(TransactionSavingSuccess());
      add(FetchRecentTransactions()); // Auto refresh
      syncService.syncNow().catchError((e) => debugPrint("Auto-sync failed: $e"));
    } catch (e) {
      emit(TransactionError("Gagal memperbarui transaksi: $e"));
      add(FetchRecentTransactions());
    }
  }

  Future<void> _onTransactionDeleted(
    TransactionDeleted event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionSavingLoading());
    try {
      await deleteTransaction(event.transactionId);
      emit(TransactionSavingSuccess());
      add(FetchRecentTransactions()); // Auto refresh
      syncService.syncNow().catchError((e) => debugPrint("Auto-sync failed: $e"));
    } catch (e) {
      emit(TransactionError("Gagal menghapus transaksi: $e"));
      add(FetchRecentTransactions());
    }
  }

  Future<void> _onVoiceTransactionStarted(
    VoiceTransactionStarted event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionSavingLoading());
    try {
      // Ambil kategori dinamis untuk keyword matching
      final categories = await getCategories();

      final parsedData = parseVoiceInput(event.rawText, categories: categories);

      if (parsedData.nominal <= 0) {
        emit(TransactionError(
            "Gagal menangkap nominal dari suaramu. Coba sebutkan angkanya lebih jelas."));
        return;
      }

      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nominal: parsedData.nominal,
        category: parsedData.category,
        date: DateTime.now(),
        note: parsedData.note,
        inputSource: 'VOICE',
        type: parsedData.type,
      );

      await saveTransaction(newTransaction);

      await Future.delayed(const Duration(milliseconds: 500));
      emit(TransactionSavingSuccess());
      add(FetchRecentTransactions()); // Auto refresh list
      syncService.syncNow().catchError((e) => debugPrint("Auto-sync failed: $e"));
    } catch (e, stackTrace) {
      debugPrint("🚨 [BLoC ERROR] Voice Save: $e");
      debugPrint("🚨 [STACKTRACE]: $stackTrace");
      emit(TransactionError("Sistem gagal memproses suaramu: ${e.toString()}"));
    }
  }
}
