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

  /// Memastikan Spreadsheet Finote ada. Jika belum, buat baru lengkap dengan Dashboard Emerald Dark Mode.
  Future<String?> ensureSpreadsheetExists() async {
    final client = await _getAuthenticatedClient();
    if (client == null) return null;

    final prefs = await SharedPreferences.getInstance();
    String? spreadsheetId = prefs.getString(_spreadsheetIdKey);

    final driveApi = drive.DriveApi(client);

    // Cek apakah file benar-benar ada di Drive
    if (spreadsheetId != null) {
      try {
        final file = await driveApi.files.get(spreadsheetId, $fields: 'trashed') as drive.File;
        if (file.trashed == true) {
          spreadsheetId = null;
        } else {
          return spreadsheetId;
        }
      } catch (e) {
        spreadsheetId = null;
      }
    }

    // Klon Spreadsheet dari Template jika belum ada
    if (spreadsheetId == null) {
      try {
        const templateId = '1IMNImfbQvVlxqugBmwYfyAzH_Az-_CnoiRlTD2o6eXQ';
        
        final copiedFile = await driveApi.files.copy(
          drive.File()..name = 'Finote_Sync_Data', 
          templateId
        );
        spreadsheetId = copiedFile.id;
        
        if (spreadsheetId != null) {
          await prefs.setString(_spreadsheetIdKey, spreadsheetId);
        }
      } catch (e) {
        debugPrint("Gagal klon template Google Sheets: $e");
        throw Exception("Gagal klon template: $e");
      }
    }
    return spreadsheetId;
  }

  /// Download seluruh baris transaksi dari Google Sheets tab 'RawData' (mulai A2)
  Future<List<TransactionModel>> pullFromSheets() async {
    final spreadsheetId = await ensureSpreadsheetExists();
    final client = await _getAuthenticatedClient();
    if (spreadsheetId == null || client == null) return [];

    final sheetsApi = sheets.SheetsApi(client);
    try {
      final response = await sheetsApi.spreadsheets.values.get(spreadsheetId, "'RawData'!A2:I");
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
          
          final date = DateTime.tryParse(dateStr.trim()) ?? DateTime.now();
          final category = (categoryStr != null && categoryStr.trim().isNotEmpty) ? categoryStr.trim() : 'Lain-lain';
          final nominal = double.tryParse(nominalStr.replaceAll(RegExp(r'[^0-9.]'), '').trim()) ?? 0.0;
          if (nominal <= 0) continue;

          // Auto-generate transactionId jika diisi manual di browser tanpa ID
          final String txId = (row.length > 5 && row[5] != null && row[5].toString().trim().isNotEmpty)
              ? row[5].toString().trim()
              : 'tx_sheets_${DateTime.now().millisecondsSinceEpoch}_$i';

          final model = TransactionModel()
            ..transactionId = txId
            ..date = date
            ..category = category
            ..nominal = nominal
            ..note = (row.length > 3 && row[3] != null) ? row[3].toString() : ''
            ..inputSource = (row.length > 4 && row[4] != null && row[4].toString().isNotEmpty) ? row[4].toString() : 'MANUAL'
            ..imagePath = (row.length > 6 && row[6] != null && row[6].toString().isNotEmpty) ? row[6].toString() : null
            ..lastUpdated = (row.length > 7 && row[7] != null && row[7].toString().isNotEmpty) ? (DateTime.tryParse(row[7].toString()) ?? DateTime.now()) : DateTime.now()
            ..isDeleted = (row.length > 8 && row[8] != null && row[8].toString().toUpperCase() == 'TRUE')
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

  /// Full Overwrite: Hapus semua data lalu tulis ulang ke tab 'RawData' dari A2
  Future<void> pushToSheets(List<TransactionModel> pendingTransactions) async {
    final spreadsheetId = await ensureSpreadsheetExists();
    final client = await _getAuthenticatedClient();
    if (client == null) throw Exception("Tidak bisa mendapatkan akses ke akun Google. Coba login ulang.");
    if (spreadsheetId == null) throw Exception("Gagal membuat/mengkopi Spreadsheet.");

    final sheetsApi = sheets.SheetsApi(client);
    try {
      // 1. Tulis Header ke RawData!A1:I1
      final headers = [
        ['Date', 'Category', 'Nominal', 'Note', 'InputSource', 'TransactionId', 'ImagePath', 'LastUpdated', 'IsDeleted']
      ];
      await sheetsApi.spreadsheets.values.update(
        sheets.ValueRange(values: headers),
        spreadsheetId,
        "'RawData'!A1:I1",
        valueInputOption: 'USER_ENTERED',
      );

      if (pendingTransactions.isEmpty) return;

      // 2. Hapus bersih data lama A2:I10000
      await sheetsApi.spreadsheets.values.clear(
        sheets.ClearValuesRequest(),
        spreadsheetId,
        "'RawData'!A2:I10000",
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
      ]).toList();

      // 4. Tulis data mentah ke RawData!A2:I...
      final endRow = allRows.length + 1; // +1 karena mulai dari A2
      final valueRange = sheets.ValueRange(values: allRows);
      await sheetsApi.spreadsheets.values.update(
        valueRange,
        spreadsheetId,
        "'RawData'!A2:I$endRow",
        valueInputOption: 'USER_ENTERED',
      );

    } catch (e) {
      debugPrint("Push to sheets error: $e");
      throw Exception("Gagal sinkronisasi data ke Google Sheets: $e");
    }
  }
}

