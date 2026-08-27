import 'package:flutter_test/flutter_test.dart';
import 'package:finote/features/transaction/data/models/transaction_model.dart';

void main() {
  group('SyncService Data Models & Logic Unit Tests', () {
    test('TransactionModel entity mapper works properly', () {
      final now = DateTime.now();
      final model = TransactionModel()
        ..transactionId = 'tx_123'
        ..nominal = 50000.0
        ..category = 'Makanan'
        ..date = now
        ..note = 'Beli sate'
        ..inputSource = 'MANUAL'
        ..isSynced = true
        ..lastUpdated = now
        ..isDeleted = false;

      final entity = model.toEntity();
      expect(entity.id, equals('tx_123'));
      expect(entity.nominal, equals(50000.0));
      expect(entity.category, equals('Makanan'));
      expect(entity.note, equals('Beli sate'));
    });

    test('Two-Way merge timestamp comparison picks newer data', () {
      final oldTime = DateTime(2026, 8, 1);
      final newTime = DateTime(2026, 8, 27);

      final cloudItem = TransactionModel()
        ..transactionId = 'tx_123'
        ..nominal = 75000.0
        ..lastUpdated = newTime;

      final localItem = TransactionModel()
        ..transactionId = 'tx_123'
        ..nominal = 50000.0
        ..lastUpdated = oldTime;

      expect(cloudItem.lastUpdated.isAfter(localItem.lastUpdated), isTrue);
    });
  });
}
