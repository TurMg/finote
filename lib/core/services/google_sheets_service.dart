import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../../features/transaction/data/models/transaction_model.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

class GoogleSheetsService {
  static const _spreadsheetIdKey = 'finote_spreadsheet_id';
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      drive.DriveApi.driveFileScope,
      drive.DriveApi.driveReadonlyScope, // Akses untuk baca/copy public template
      sheets.SheetsApi.spreadsheetsScope,
    ],
  );

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      var user = await _googleSignIn.signIn();
      return user;
    } catch (e) {
      debugPrint("Google Sign In Error: $e");
      throw Exception("Google Sign In Error: $e");
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      var user = await _googleSignIn.signInSilently();
      return user;
    } catch (e) {
      debugPrint("Google Sign In Silently Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  Future<GoogleAuthClient?> _getAuthenticatedClient() async {
    final user = _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    if (user == null) return null;
    
    final headers = await user.authHeaders;
    return GoogleAuthClient(headers);
  }

  static const _spreadsheetName = 'Finote_Sync_Data';
  static const _templateId = '1IMNImfbQvVlxqugBmwYfyAzH_Az-_CnoiRlTD2o6eXQ';

  /// Memastikan Spreadsheet Finote ada.
  /// Urutan pengecekan:
  /// 1. Cek cache lokal (SharedPreferences) & validasi ke Drive.
  /// 2. Jika tidak ada di cache lokal (misal: device baru), cari file dengan nama 'Finote_Sync_Data' di Google Drive.
  /// 3. Jika belum pernah ada di Drive sama sekali, barulah klon dari template.
  Future<String?> ensureSpreadsheetExists() async {
    final client = await _getAuthenticatedClient();
    if (client == null) return null;

    final prefs = await SharedPreferences.getInstance();
    String? spreadsheetId = prefs.getString(_spreadsheetIdKey);
    final driveApi = drive.DriveApi(client);

    // 1. Cek apakah ID dari cache lokal valid & belum dihapus
    if (spreadsheetId != null) {
      try {
        final file = await driveApi.files.get(spreadsheetId, $fields: 'id, trashed') as drive.File;
        if (file.trashed != true) {
          return spreadsheetId;
        }
      } catch (e) {
        debugPrint("Spreadsheet cached ID invalid atau tidak ditemukan: $e");
      }
      spreadsheetId = null;
      await prefs.remove(_spreadsheetIdKey);
    }

    // 2. Cari spreadsheet yang sudah ada di Google Drive (agar tidak duplikat saat login di device baru)
    spreadsheetId = await _findExistingSpreadsheet(driveApi);

    // 3. Klon Spreadsheet dari Template jika belum ada sama sekali di Drive
    if (spreadsheetId == null) {
      try {
        final copiedFile = await driveApi.files.copy(
          drive.File()..name = _spreadsheetName,
          _templateId,
        );
        spreadsheetId = copiedFile.id;
      } catch (e) {
        debugPrint("Gagal klon template Google Sheets: $e");
        throw Exception("Gagal klon template: $e");
      }
    }

    // Simpan ID yang valid ke cache lokal untuk mempercepat akses berikutnya
    if (spreadsheetId != null) {
      await prefs.setString(_spreadsheetIdKey, spreadsheetId);
    }

    return spreadsheetId;
  }

  /// Mencari spreadsheet 'Finote_Sync_Data' yang aktif di Google Drive pengguna
  Future<String?> _findExistingSpreadsheet(drive.DriveApi driveApi) async {
    try {
      final fileList = await driveApi.files.list(
        q: "name = '$_spreadsheetName' and mimeType = 'application/vnd.google-apps.spreadsheet' and trashed = false",
        orderBy: 'modifiedTime desc',
        $fields: 'files(id, name, modifiedTime)',
        pageSize: 1,
      );

      final files = fileList.files;
      if (files != null && files.isNotEmpty) {
        return files.first.id;
      }
    } catch (e) {
      debugPrint("Gagal mencari spreadsheet yang sudah ada di Drive: $e");
    }
    return null;
  }

  /// Download seluruh baris transaksi dari Google Sheets tab 'RawData' (mulai A2)
  Future<List<TransactionModel>> pullFromSheets() async {
    final spreadsheetId = await ensureSpreadsheetExists();
    final client = await _getAuthenticatedClient();
    if (spreadsheetId == null || client == null) return [];

    final sheetsApi = sheets.SheetsApi(client);
    try {
      final response = await sheetsApi.spreadsheets.values.get(spreadsheetId, "'RawData'!A2:J");
      final rows = response.values;
      
      if (rows == null || rows.isEmpty) return [];

      List<TransactionModel> models = [];
      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 3) continue; // Butuh minimal Date, Category, Nominal
        
        try {
          final dateStr = row[0]?.toString();
          final categoryStr = row.length > 1 ? row[1]?.toString() : null;
          final nominalStr = row.length > 2 ? row[2]?.toString() : null;
          
          if (dateStr == null || dateStr.trim().isEmpty || nominalStr == null || nominalStr.trim().isEmpty) continue;
          
          final date = _parseDateTime(dateStr) ?? DateTime.now();
          final category = (categoryStr != null && categoryStr.trim().isNotEmpty) ? categoryStr.trim() : 'Lain-lain';
          final nominal = double.tryParse(nominalStr.replaceAll(RegExp(r'[^0-9.]'), '').trim()) ?? 0.0;
          if (nominal <= 0) continue;

          // Auto-generate transactionId jika diisi manual di browser tanpa ID
          final String txId = (row.length > 5 && row[5] != null && row[5].toString().trim().isNotEmpty)
              ? row[5].toString().trim()
              : 'tx_sheets_${date.millisecondsSinceEpoch}_$i';

          // Type (EXPENSE/INCOME): Dari kolom ke-10 (J) atau infer dari nama kategori
          String type = 'EXPENSE';
          if (row.length > 9 && row[9] != null && row[9].toString().trim().isNotEmpty) {
            type = row[9].toString().trim().toUpperCase();
          } else {
            // Infer type jika kolom Type di Google Sheets lama belum ada
            final lowerCat = category.toLowerCase();
            if (lowerCat.contains('gaji') || 
                lowerCat.contains('bonus') || 
                lowerCat.contains('pemasukan') || 
                lowerCat.contains('income') || 
                lowerCat.contains('investasi') ||
                lowerCat.contains('hibah') ||
                lowerCat.contains('freelance')) {
              type = 'INCOME';
            }
          }

          final model = TransactionModel()
            ..transactionId = txId
            ..date = date
            ..category = category
            ..nominal = nominal
            ..note = (row.length > 3 && row[3] != null) ? row[3].toString() : ''
            ..inputSource = (row.length > 4 && row[4] != null && row[4].toString().isNotEmpty) ? row[4].toString() : 'MANUAL'
            ..imagePath = (row.length > 6 && row[6] != null && row[6].toString().isNotEmpty) ? row[6].toString() : null
            ..lastUpdated = (row.length > 7 && row[7] != null) ? (_parseDateTime(row[7].toString()) ?? DateTime.now()) : DateTime.now()
            ..isDeleted = (row.length > 8 && row[8] != null && row[8].toString().toUpperCase() == 'TRUE')
            ..type = type
            ..isSynced = true;
            
          models.add(model);
        } catch (rowError) {
          debugPrint("Skipping invalid row: $rowError");
        }
      }
      return models;
    } catch (e) {
      debugPrint("Pull from sheets error: $e");
      return [];
    }
  }

  /// Helper untuk parsing tanggal berbagai format (ISO-8601, Google Sheets format, UTC conversion)
  DateTime? _parseDateTime(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final trimmed = input.trim();

    // 1. Coba parse ISO-8601 standar
    var parsed = DateTime.tryParse(trimmed);

    // 2. Coba ganti spasi dengan 'T' (misal "2026-09-02 13:30:00")
    parsed ??= DateTime.tryParse(trimmed.replaceAll(' ', 'T'));

    // 3. Coba parse format garis miring (misal "DD/MM/YYYY" atau "YYYY/MM/DD")
    if (parsed == null && trimmed.contains('/')) {
      final parts = trimmed.split(' ');
      final dateParts = parts[0].split('/');
      if (dateParts.length == 3) {
        int? day, month, year;
        if (dateParts[0].length == 4) {
          year = int.tryParse(dateParts[0]);
          month = int.tryParse(dateParts[1]);
          day = int.tryParse(dateParts[2]);
        } else {
          day = int.tryParse(dateParts[0]);
          month = int.tryParse(dateParts[1]);
          year = int.tryParse(dateParts[2]);
        }
        if (year != null && month != null && day != null) {
          int hour = 0, minute = 0, second = 0;
          if (parts.length > 1) {
            final timeParts = parts[1].split(':');
            if (timeParts.length >= 2) {
              hour = int.tryParse(timeParts[0]) ?? 0;
              minute = int.tryParse(timeParts[1]) ?? 0;
              if (timeParts.length >= 3) {
                second = int.tryParse(timeParts[2]) ?? 0;
              }
            }
          }
          parsed = DateTime(year, month, day, hour, minute, second);
        }
      }
    }

    return parsed?.toLocal();
  }

  /// Full Overwrite: Hapus semua data lalu tulis ulang ke tab 'RawData' dari A2
  Future<void> pushToSheets(List<TransactionModel> pendingTransactions) async {
    final spreadsheetId = await ensureSpreadsheetExists();
    final client = await _getAuthenticatedClient();
    if (client == null) throw Exception("Tidak bisa mendapatkan akses ke akun Google. Coba login ulang.");
    if (spreadsheetId == null) throw Exception("Gagal membuat/mengkopi Spreadsheet.");

    final sheetsApi = sheets.SheetsApi(client);
    try {
      // 1. Tulis Header ke RawData!A1:J1
      final headers = [
        ['Date', 'Category', 'Nominal', 'Note', 'InputSource', 'TransactionId', 'ImagePath', 'LastUpdated', 'IsDeleted', 'Type']
      ];
      await sheetsApi.spreadsheets.values.update(
        sheets.ValueRange(values: headers),
        spreadsheetId,
        "'RawData'!A1:J1",
        valueInputOption: 'USER_ENTERED',
      );

      if (pendingTransactions.isEmpty) return;

      // 2. Hapus bersih data lama A2:J10000
      await sheetsApi.spreadsheets.values.clear(
        sheets.ClearValuesRequest(),
        spreadsheetId,
        "'RawData'!A2:J10000",
      );

      // 3. Siapkan baris data mentah
      final allRows = pendingTransactions.map((t) => [
        t.date.toIso8601String(),
        t.category,
        t.nominal,
        t.note,
        t.inputSource,
        t.transactionId,
        t.imagePath ?? '',
        t.lastUpdated.toIso8601String(),
        t.isDeleted.toString().toUpperCase(),
        t.type.toUpperCase(),
      ]).toList();

      // 4. Tulis data mentah ke RawData!A2:J...
      final endRow = allRows.length + 1; // +1 karena mulai dari A2
      final valueRange = sheets.ValueRange(values: allRows);
      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        "'RawData'!A2:J$endRow",
        valueInputOption: 'USER_ENTERED',
      );

    } catch (e) {
      debugPrint("Push to sheets error: $e");
      throw Exception("Gagal sinkronisasi data ke Google Sheets: $e");
    }
  }
}

