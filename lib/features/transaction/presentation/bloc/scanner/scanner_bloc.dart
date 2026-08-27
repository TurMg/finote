import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/receipt_scanner_usecase.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final ReceiptScannerUseCase _scannerUseCase;

  ScannerBloc(this._scannerUseCase) : super(ScannerInitial()) {
    on<AnalyzeReceipt>(_onAnalyzeReceipt);
    on<ResetScanner>((event, emit) => emit(ScannerInitial()));
  }

  Future<void> _onAnalyzeReceipt(AnalyzeReceipt event, Emitter<ScannerState> emit) async {
    emit(ScannerProcessing()); // Ubah state jadi loading agar UI bisa nampilin animasi loading
    
    try {
      // Panggil otak algoritma Levenshtein dan Row Grouping kita
      final amount = await _scannerUseCase.execute(event.imagePath);
      
      if (amount > 0) {
        emit(ScannerSuccess(amount));
      } else {
        emit(ScannerError('Nominal total tidak ditemukan. Pastikan foto struk terlihat jelas dan tidak terpotong.'));
      }
    } catch (e) {
      emit(ScannerError('Gagal memproses gambar: ${e.toString()}'));
    }
  }
}