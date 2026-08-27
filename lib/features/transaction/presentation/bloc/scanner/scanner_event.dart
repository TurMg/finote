abstract class ScannerEvent {}

class AnalyzeReceipt extends ScannerEvent {
  final String imagePath;
  AnalyzeReceipt(this.imagePath);
}

class ResetScanner extends ScannerEvent {}