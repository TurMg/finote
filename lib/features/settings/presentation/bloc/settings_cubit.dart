import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/settings_service.dart';

class SettingsCubit extends Cubit<bool?> {
  final SettingsService _settingsService;

  SettingsCubit(this._settingsService) : super(_settingsService.saveReceiptImage);

  Future<void> updateSaveReceiptPreference(bool value) async {
    await _settingsService.setSaveReceiptImage(value);
    emit(value);
  }
}
