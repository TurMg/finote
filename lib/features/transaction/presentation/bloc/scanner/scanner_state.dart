abstract class ScannerState {}

class ScannerInitial extends ScannerState {}

class ScannerProcessing extends ScannerState {}

class ScannerSuccess extends ScannerState {
  final double nominal;
  ScannerSuccess(this.nominal);
}

class ScannerError extends ScannerState {
  final String message;
  ScannerError(this.message);
}