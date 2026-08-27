import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keySaveReceipt = 'save_receipt_image';
  static const _keyCustomUsername = 'custom_username';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  /// Mengembalikan true/false jika sudah dipilih, null jika user belum pernah memilih.
  bool? get saveReceiptImage {
    if (!_prefs.containsKey(_keySaveReceipt)) {
      return null;
    }
    return _prefs.getBool(_keySaveReceipt);
  }

  Future<void> setSaveReceiptImage(bool value) async {
    await _prefs.setBool(_keySaveReceipt, value);
  }

  /// Mengembalikan nama kustom pengguna jika ada, null jika belum pernah diatur.
  String? get customUsername {
    return _prefs.getString(_keyCustomUsername);
  }

  Future<void> setCustomUsername(String value) async {
    await _prefs.setString(_keyCustomUsername, value.trim());
  }
}
