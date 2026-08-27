import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Preprocessor citra untuk foto struk belanja
/// Meningkatkan kontras dan mengonversi gambar ke Grayscale
/// sebelum dikirim ke Google ML Kit Text Recognizer.
class ReceiptImagePreprocessor {
  /// Memproses gambar di [inputPath] dan mengembalikan path berkas temporary hasil preprocessing.
  /// Jika terjadi kegagalan/error, mengembalikan [inputPath] asli sebagai fallback.
  static Future<String> processImage(String inputPath) async {
    try {
      final file = File(inputPath);
      if (!await file.exists()) return inputPath;

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return inputPath;

      final decoded = img.decodeImage(bytes);
      if (decoded == null) return inputPath;

      // 1. Ubah ke Grayscale
      final grayscale = img.grayscale(decoded);

      // 2. Tingkatkan Kontras (Contrast 1.35x, Brightness 1.05x)
      final enhanced = img.adjustColor(
        grayscale,
        contrast: 1.35,
        brightness: 1.05,
      );

      // 3. Simpan ke berkas temporary
      final tempDir = await getTemporaryDirectory();
      final tempFileName = 'prep_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final tempFile = File('${tempDir.path}/$tempFileName');

      final encodedBytes = img.encodeJpg(enhanced, quality: 90);
      await tempFile.writeAsBytes(encodedBytes);

      return tempFile.path;
    } catch (e) {
      debugPrint('ReceiptImagePreprocessor error: $e');
      return inputPath;
    }
  }

  /// Menghapus berkas temporary hasil preprocessing jika ada
  static Future<void> cleanupTempFile(String tempPath, String originalPath) async {
    if (tempPath == originalPath) return;
    try {
      final file = File(tempPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
