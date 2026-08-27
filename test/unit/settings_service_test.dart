import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finote/core/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService Custom Username Test Cases', () {
    late SettingsService settingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      settingsService = SettingsService(prefs);
    });

    test('customUsername returns null by default', () {
      expect(settingsService.customUsername, isNull);
    });

    test('setCustomUsername stores and retrieves trimmed custom username', () async {
      await settingsService.setCustomUsername('   Turr   ');
      expect(settingsService.customUsername, equals('Turr'));
    });
  });
}
