import 'package:flutter_test/flutter_test.dart';
import 'package:finote/features/transaction/domain/usecases/parse_voice_input.dart';

void main() {
  test('Test ParseVoiceInput', () async {
    final parser = ParseVoiceInput();
    final result = await parser.execute('beli kopi Rp5.000');
    print('Nominal: ${result.nominal}');
    print('Note: ${result.note}');
  });
}
