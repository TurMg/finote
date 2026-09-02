import 'package:isar/isar.dart';
import 'package:flutter/foundation.dart';
import '../../features/transaction/data/models/transaction_model.dart';
import 'google_sheets_service.dart';

class SyncService {
  final GoogleSheetsService _sheetsService;
  final Isar _isar;

  SyncService(this._sheetsService, this._isar);

  Future<void> syncNow() async {
    final user = _sheetsService.currentUser ?? await _sheetsService.signInSilently();
    if (user == null) {
      // Belum login, skip sync diam-diam (jangan ganggu user)
      return;
    }

    try {
      // STAGE 1: PULL (Tarik seluruh data dari Google Sheets)
      final cloudTransactions = await _sheetsService.pullFromSheets();

      // STAGE 2: MERGE (Penggabungan 2 arah dengan Isar lokal DB)
      await _isar.writeTxn(() async {
        for (var cloudItem in cloudTransactions) {
          final existingLocal = await _isar.transactionModels
              .filter()
              .transactionIdEqualTo(cloudItem.transactionId)
              .findFirst();

          if (existingLocal == null) {
            // Data baru dari Cloud -> Masukkan ke HP lokal
            cloudItem.isSynced = true;
            await _isar.transactionModels.put(cloudItem);
          } else {
            // Data sudah ada di HP lokal -> Bandingkan timestamp lastUpdated
            if (cloudItem.lastUpdated.isAfter(existingLocal.lastUpdated)) {
              existingLocal
                ..date = cloudItem.date
                ..category = cloudItem.category
                ..nominal = cloudItem.nominal
                ..note = cloudItem.note
                ..inputSource = cloudItem.inputSource
                ..imagePath = cloudItem.imagePath
                ..lastUpdated = cloudItem.lastUpdated
                ..isDeleted = cloudItem.isDeleted
                ..type = cloudItem.type
                ..isSynced = true;
              await _isar.transactionModels.put(existingLocal);
            } else {
              // Jika lokal type masih 'EXPENSE' padahal kategorinya Pemasukan (akibat bug terdahulu), perbaiki otomatis
              final lowerCat = existingLocal.category.toLowerCase();
              if (existingLocal.type == 'EXPENSE' && 
                  (lowerCat.contains('gaji') || lowerCat.contains('bonus') || lowerCat.contains('pemasukan') || lowerCat.contains('income') || lowerCat.contains('investasi') || lowerCat.contains('hibah') || lowerCat.contains('freelance'))) {
                existingLocal
                  ..type = 'INCOME'
                  ..isSynced = false;
                await _isar.transactionModels.put(existingLocal);
              }
            }
          }
        }
      });

      // STAGE 3: PUSH (Unggah seluruh data hasil merger utuh ke Google Sheets)
      final allMergedLocal = await _isar.transactionModels.where().findAll();

      if (allMergedLocal.isNotEmpty) {
        await _sheetsService.pushToSheets(allMergedLocal);

        // Tandai semua data lokal sebagai isSynced = true
        await _isar.writeTxn(() async {
          for (var t in allMergedLocal) {
            if (!t.isSynced) {
              t.isSynced = true;
              await _isar.transactionModels.put(t);
            }
          }
        });
      }
    } catch (e) {
      debugPrint("SyncService error: $e");
      throw Exception("Sinkronisasi gagal: $e");
    }
  }
}

