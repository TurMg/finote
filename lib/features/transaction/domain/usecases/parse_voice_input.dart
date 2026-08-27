import '../../../../core/utils/indonesian_number_parser.dart';
import '../entities/voice_parsed_data.dart';
import '../../../category/domain/entities/category.dart';

class ParseVoiceInput {
  /// Eksekusi parsing suara (Local Parser)
  Future<VoiceParsedData> execute(String rawText, {List<Category> categories = const []}) async {
    final text = rawText.toLowerCase().trim();
    return _parseLocally(rawText, text, categories);
  }

  /// Synchronous fallback (kompatibilitas bawaan)
  VoiceParsedData call(String rawText, {List<Category> categories = const []}) {
    final text = rawText.toLowerCase().trim();
    return _parseLocally(rawText, text, categories);
  }

  /// Algoritma Parsing Lokal (Layer 1)
  VoiceParsedData _parseLocally(String rawText, String text, List<Category> categories) {
    // 1. Ekstrak Nominal menggunakan IndonesianNumberParser
    final nominal = IndonesianNumberParser.extractNominal(text);

    // 2. Deteksi Kategori dan Tipe dari Keyword Custom Kategori
    String category = '';
    String type = '';

    if (categories.isNotEmpty) {
      for (final cat in categories) {
        if (cat.keywords.isEmpty) continue;

        final pattern = cat.keywords
            .map((k) => RegExp.escape(k.toLowerCase()))
            .join('|');

        if (RegExp('($pattern)').hasMatch(text)) {
          category = cat.name;
          type = cat.type;
          break;
        }
      }
    }

    // 3. Fallback Tipe jika belum terdeteksi
    if (type.isEmpty) {
      final incomePattern = RegExp(
          r'\b(gaji|terima|dapat|pemasukan|masuk|bonus|insentif|dividen|investasi|jual|omset|dapet)\b');
      if (incomePattern.hasMatch(text)) {
        type = 'INCOME';
      } else {
        type = 'EXPENSE';
      }
    }

    // 4. Fallback Kategori jika belum terdeteksi
    if (category.isEmpty) {
      if (categories.isNotEmpty) {
        final matchingTypeCategories = categories.where((c) => c.type == type).toList();
        category = matchingTypeCategories.isNotEmpty ? matchingTypeCategories.first.name : categories.first.name;
      } else {
        if (type == 'INCOME') {
          category = 'Gaji';
        } else if (RegExp(r'\b(makan|nasi|warteg|roti|camilan|sarapan|bakso|mie|food)\b').hasMatch(text)) {
          category = 'Makanan';
        } else if (RegExp(r'\b(minum|kopi|es|teh|susu|boba|cafe)\b').hasMatch(text)) {
          category = 'Minuman';
        } else if (RegExp(r'\b(transport|bensin|parkir|ojek|gojek|grab|tol|kereta|bus|angkot)\b').hasMatch(text)) {
          category = 'Transport';
        } else {
          category = 'Lainnya';
        }
      }
    }

    // 5. Ekstrak Catatan (Pembersihan Teks)
    String cleanNote = rawText.toLowerCase();
    cleanNote = cleanNote.replaceAll(RegExp(r'\d+[\.,]?\d*'), '');
    cleanNote = cleanNote.replaceAll(RegExp(r'\b(rp|ribu|ratus|juta|rupiah|perak|rb|jt|k|sejutaan|ribuan)\b'), '');
    cleanNote = cleanNote.replaceAll(RegExp(r'\b(satu|dua|tiga|empat|lima|enam|tujuh|delapan|sebilan|sepuluh|sebelas|setengah)\b'), '');
    cleanNote = cleanNote.trim().replaceAll(RegExp(r'\s+'), ' ');

    final note = _capitalizeFirstLetter(cleanNote.isEmpty ? rawText : cleanNote);

    return VoiceParsedData(
      nominal: nominal,
      category: category,
      note: note,
      type: type,
    );
  }

  String _capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}