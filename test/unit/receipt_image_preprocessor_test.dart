import 'package:flutter_test/flutter_test.dart';
import 'package:finote/features/transaction/domain/usecases/receipt_image_preprocessor.dart';

void main() {
  group('ReceiptImagePreprocessor Test Cases', () {
    test('Returns original path cleanly if file does not exist', () async {
      const nonExistentPath = '/tmp/non_existent_image_12345.jpg';
      final result = await ReceiptImagePreprocessor.processImage(nonExistentPath);
      expect(result, equals(nonExistentPath));
    });

    test('Cleanup does not crash for identical paths or missing files', () async {
      await expectLater(
        ReceiptImagePreprocessor.cleanupTempFile('/tmp/dummy.jpg', '/tmp/dummy.jpg'),
        completes,
      );
    });
  });
}
