import 'dart:math';
import 'dart:ui';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'receipt_image_preprocessor.dart';

/// Class pengolah ekstraksi total dari foto struk belanja/transaksi
/// Menggunakan kombinasi Image Preprocessing, OCR Normalization, Bounding Box Spatial Alignment,
/// Rupiah Currency Parsing, dan Multi-Factor Candidate Scoring.
class ReceiptScannerUseCase {
  /// Entry point utama untuk memproses gambar dari file path
  Future<double> execute(String imagePath) async {
    final processedPath = await ReceiptImagePreprocessor.processImage(imagePath);

    try {
      // Pass 1: Memindai foto hasil pre-processing kontras & grayscale
      double amount = await _scanSingleImage(processedPath);

      // Pass 2 Fallback: Jika Pass 1 bernilai 0.0, pindai ulang foto asli
      if (amount <= 0 && processedPath != imagePath) {
        amount = await _scanSingleImage(imagePath);
      }

      return amount;
    } finally {
      await ReceiptImagePreprocessor.cleanupTempFile(processedPath, imagePath);
    }
  }

  Future<double> _scanSingleImage(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      return extractTotalFromRecognizedText(recognizedText);
    } finally {
      textRecognizer.close();
    }
  }

  /// Ekstraksi nilai total dari objek [RecognizedText] ML Kit.
  /// Method ini dibuat publik & terpisah dari IO file agar mudah di-unit-test.
  double extractTotalFromRecognizedText(RecognizedText recognizedText) {
    if (recognizedText.blocks.isEmpty) return 0.0;

    // 1. Ekstrak seluruh elemen teks beserta Bounding Box-nya
    final allElements = _extractAllElements(recognizedText.blocks);
    if (allElements.isEmpty) return 0.0;

    // 2. Hitung statistik tata letak struk (tinggi total struk)
    final receiptBounds = _calculateBounds(allElements);
    final groupedRows = _groupElementsIntoRows(allElements);

    // 3. Evaluasi kandidat total menggunakan Candidate Scorer
    final candidates = <TotalCandidate>[];

    for (int rowIndex = 0; rowIndex < groupedRows.length; rowIndex++) {
      final row = groupedRows[rowIndex];
      final rowText = row.map((e) => e.text).join(' ').toLowerCase();

      // Cek apakah baris ini mengandung kata kunci negatif (blacklist) yang fatal
      if (_hasFatalBlacklist(rowText)) continue;

      final keywordMatch = _findKeywordMatch(rowText);
      if (keywordMatch == null) continue;

      // Ekstrak nominal di baris yang sama, 1 baris di bawah, atau 2 baris di bawah
      final targetNominals = _findNominalsInRows(groupedRows, rowIndex);

      for (var nominalMatch in targetNominals) {
        final score = CandidateScorer.calculateScore(
          keywordWeight: keywordMatch.weight,
          rowText: rowText,
          nominalRowIndex: nominalMatch.rowIndex,
          keywordRowIndex: rowIndex,
          nominalElement: nominalMatch.element,
          keywordElement: row.first,
          receiptBounds: receiptBounds,
        );

        if (score > 0) {
          candidates.add(TotalCandidate(
            amount: nominalMatch.amount,
            score: score,
            rowIndex: nominalMatch.rowIndex,
          ));
        }
      }
    }

    // 4. Pilih kandidat terbaik berdasarkan skor tertinggi
    if (candidates.isNotEmpty) {
      candidates.sort((a, b) {
        final scoreCmp = b.score.compareTo(a.score);
        if (scoreCmp != 0) return scoreCmp;
        final amountCmp = b.amount.compareTo(a.amount);
        if (amountCmp != 0) return amountCmp;
        return b.rowIndex.compareTo(a.rowIndex);
      });

      return candidates.first.amount;
    }

    // 5. FALLBACK MECHANISM: Jika kata kunci buram/pudar total,
    // cari nominal logis terbesar di 35% area paling bawah struk
    return _fallbackExtractFromBottomRegion(groupedRows, receiptBounds);
  }

  List<TextElement> _extractAllElements(List<TextBlock> blocks) {
    final elements = <TextElement>[];
    for (var block in blocks) {
      for (var line in block.lines) {
        elements.addAll(line.elements);
      }
    }
    return elements;
  }

  Rect _calculateBounds(List<TextElement> elements) {
    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;

    for (var e in elements) {
      final box = e.boundingBox;
      if (box.left < minX) minX = box.left.toDouble();
      if (box.top < minY) minY = box.top.toDouble();
      if (box.right > maxX) maxX = box.right.toDouble();
      if (box.bottom > maxY) maxY = box.bottom.toDouble();
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  List<List<TextElement>> _groupElementsIntoRows(List<TextElement> elements) {
    final sorted = List<TextElement>.from(elements)
      ..sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    final rows = <List<TextElement>>[];
    for (var element in sorted) {
      if (rows.isEmpty) {
        rows.add([element]);
      } else {
        final lastRow = rows.last;
        final avgY = lastRow
                .map((e) => e.boundingBox.top)
                .reduce((a, b) => a + b) /
            lastRow.length;
        final avgHeight = lastRow
                .map((e) => e.boundingBox.height)
                .reduce((a, b) => a + b) /
            lastRow.length;
        final threshold = avgHeight * 0.55;

        if ((element.boundingBox.top - avgY).abs() <= threshold) {
          lastRow.add(element);
        } else {
          rows.add([element]);
        }
      }
    }

    for (var row in rows) {
      row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
    }
    return rows;
  }

  bool _hasFatalBlacklist(String text) {
    final blacklists = [
      'subtotal',
      'sub total',
      'sub-total',
      'kembali',
      'change',
      'total item',
      'total qty',
      'total disc',
      'total diskon',
      'total saving',
      'total hemat',
    ];
    return blacklists.any((kw) => text.contains(kw));
  }

  _KeywordMatch? _findKeywordMatch(String rowText) {
    final targets = [
      const _KeywordDef(['grand total', 'total bayar', 'total pembayaran', 'total belanja', 'total harga', 'total keseluruhan'], 100),
      const _KeywordDef(['total', 'tagihan', 'jumlah bayar', 'jumlah total'], 70),
      const _KeywordDef(['jumlah', 'amount', 'nett', 'net total'], 40),
    ];

    for (var target in targets) {
      for (var kw in target.keywords) {
        if (_isMatch(rowText, kw)) {
          return _KeywordMatch(keyword: kw, weight: target.weight);
        }
      }
    }
    return null;
  }

  bool _isMatch(String text, String keyword) {
    final cleanText = text.replaceAll(RegExp(r'[^a-z\s]'), '').trim();
    final words = cleanText.split(RegExp(r'\s+'));
    final key = keyword.toLowerCase();

    int maxDistance = key.length <= 5 ? 1 : 2;

    for (var word in words) {
      if (_levenshtein(word, key) <= maxDistance) return true;
    }

    final combinedText = cleanText.replaceAll(' ', '');
    final combinedKey = key.replaceAll(' ', '');

    if (combinedText.contains(combinedKey)) return true;
    if (_levenshtein(combinedText, combinedKey) <= maxDistance) return true;

    return false;
  }

  int _levenshtein(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    var v0 = List<int>.generate(s2.length + 1, (i) => i);
    var v1 = List<int>.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < s2.length; j++) {
        final cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = [
          v1[j] + 1,
          v0[j + 1] + 1,
          v0[j] + cost,
        ].reduce(min);
      }
      final temp = v0;
      v0 = v1;
      v1 = temp;
    }
    return v0[s2.length];
  }

  List<_NominalElementMatch> _findNominalsInRows(
      List<List<TextElement>> groupedRows, int startRowIndex) {
    final matches = <_NominalElementMatch>[];

    for (int offset = 0; offset <= 2; offset++) {
      final idx = startRowIndex + offset;
      if (idx >= groupedRows.length) break;

      for (var element in groupedRows[idx]) {
        final amounts = ReceiptNominalParser.extractNominals(element.text);
        for (var amount in amounts) {
          matches.add(_NominalElementMatch(
            amount: amount,
            rowIndex: idx,
            element: element,
          ));
        }
      }
    }
    return matches;
  }

  double _fallbackExtractFromBottomRegion(
      List<List<TextElement>> groupedRows, Rect receiptBounds) {
    final bottomCutoff = receiptBounds.top + (receiptBounds.height * 0.65);
    double maxNominal = 0.0;

    for (var row in groupedRows) {
      final rowY = row.first.boundingBox.top;
      if (rowY < bottomCutoff) continue;

      final rowText = row.map((e) => e.text).join(' ').toLowerCase();

      // Abaikan kata kunci yang tidak diinginkan di bagian bawah
      if (rowText.contains('kembali') ||
          rowText.contains('change') ||
          rowText.contains('tunai') ||
          rowText.contains('cash') ||
          rowText.contains('item')) {
        continue;
      }

      for (var element in row) {
        final amounts = ReceiptNominalParser.extractNominals(element.text);
        for (var val in amounts) {
          if (val > maxNominal && val <= 999999999) {
            maxNominal = val;
          }
        }
      }
    }

    return maxNominal;
  }
}

// ============================================================================
// HELPER COMPONENTS (CLEAN & DRY ARCHITECTURE)
// ============================================================================

/// Normalisasi karakter OCR untuk mengatasi salah baca angka pada struk thermal
class OCRTextNormalizer {
  /// Mengoreksi karakter yang sering salah dibaca OCR menjadi angka murni
  static String normalizeNumberString(String text) {
    if (text.isEmpty) return text;

    // Bersihkan prefix mata uang seperti Rp, Rp., RP
    String s = text.replaceAll(RegExp(r'^[Rr][Pp]\.?\s*'), '');

    // Kamus penggantian karakter OCR ke digit
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final char = s[i];
      switch (char) {
        case 'O':
        case 'o':
        case 'Q':
          buffer.write('0');
          break;
        case 'I':
        case 'l':
        case 'i':
        case '|':
          buffer.write('1');
          break;
        case 'S':
        case 's':
          buffer.write('5');
          break;
        case 'B':
          buffer.write('8');
          break;
        case 'g':
        case 'q':
          buffer.write('9');
          break;
        case 'Z':
        case 'z':
          buffer.write('2');
          break;
        default:
          buffer.write(char);
      }
    }
    return buffer.toString();
  }
}

/// Parser nominal mata uang Rupiah Indonesia
class ReceiptNominalParser {
  /// Mengesktrak daftar nominal angka yang valid dari teks
  static List<double> extractNominals(String rawText) {
    if (rawText.trim().isEmpty) return [];

    final normalized = OCRTextNormalizer.normalizeNumberString(rawText.trim());
    final matches = RegExp(r'\b\d[\d.,]*\d\b').allMatches(normalized);
    final results = <double>[];

    for (var match in matches) {
      final val = parseNominalString(match.group(0)!);
      if (val != null && val > 0) {
        results.add(val);
      }
    }

    return results;
  }

  /// Mengonversi string berformat angka rupiah menjadi double
  static double? parseNominalString(String numStr) {
    String str = numStr.trim();

    // Hapus akhiran rupiah seperti ,- / .- / ,00 / .00
    if (RegExp(r'[,-]-$').hasMatch(str)) {
      str = str.substring(0, str.length - 2);
    } else if (RegExp(r'[,.]00$').hasMatch(str)) {
      str = str.substring(0, str.length - 3);
    } else if (RegExp(r'[,.]0$').hasMatch(str)) {
      str = str.substring(0, str.length - 2);
    }

    // Jika memiliki desimal sen (misal 150.000,50 -> 150000)
    if (RegExp(r',\d{1,2}$').hasMatch(str)) {
      str = str.split(',').first;
    } else if (RegExp(r'\.\d{1,2}$').hasMatch(str)) {
      final parts = str.split('.');
      if (parts.length == 2 && parts.last.length <= 2) {
        str = parts.first;
      }
    }

    // Hapus semua karakter non-digit
    final digitsOnly = str.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return null;

    // Filter kewarasan nominal rupiah:
    // Angka harus antara 100 rupiah s.d 999 juta rupiah (3 sampai 9 digit)
    if (digitsOnly.length >= 3 && digitsOnly.length <= 9) {
      return double.tryParse(digitsOnly);
    }

    return null;
  }
}

/// Penilai skor bobot kandidat total (Candidate Scorer)
class CandidateScorer {
  /// Menghitung total skor kandidat berdasarkan berbagai indikator
  static int calculateScore({
    required int keywordWeight,
    required String rowText,
    required int nominalRowIndex,
    required int keywordRowIndex,
    required TextElement nominalElement,
    required TextElement keywordElement,
    required Rect receiptBounds,
  }) {
    int score = keywordWeight;

    // 1. Penalti kata kunci sekunder (Soft Blacklists)
    if (rowText.contains('tunai') || rowText.contains('cash')) {
      score -= 40;
    }
    if (rowText.contains('debit') || rowText.contains('qris') || rowText.contains('card')) {
      score -= 30;
    }
    if (rowText.contains('pajak') || rowText.contains('tax') || rowText.contains('pb1')) {
      score -= 50;
    }

    // 2. Evaluasi Geometri / Spatial Alignment
    final kBox = keywordElement.boundingBox;
    final nBox = nominalElement.boundingBox;

    // Jika di baris yang sama dan nominal di sebelah kanan kata kunci
    if (nominalRowIndex == keywordRowIndex && nBox.left >= kBox.left) {
      score += 60;
    }
    // Jika nominal tepat bertumpuk di bawah kata kunci
    else if (nominalRowIndex > keywordRowIndex && (nBox.left - kBox.left).abs() < (kBox.width * 1.5)) {
      score += 40;
    }

    // 3. Evaluasi Posisi Vertikal Struk
    final relativeY = (nBox.top - receiptBounds.top) / receiptBounds.height;
    if (relativeY >= 0.50) {
      score += 35; // Paruh bawah struk
    } else if (relativeY >= 0.35) {
      score += 15;
    } else {
      score -= 25; // Paruh atas struk jarang berupa Total Belanja
    }

    return score;
  }
}

// Data models internal
class TotalCandidate {
  final double amount;
  final int score;
  final int rowIndex;

  const TotalCandidate({
    required this.amount,
    required this.score,
    required this.rowIndex,
  });
}

class _KeywordDef {
  final List<String> keywords;
  final int weight;

  const _KeywordDef(this.keywords, this.weight);
}

class _KeywordMatch {
  final String keyword;
  final int weight;

  const _KeywordMatch({required this.keyword, required this.weight});
}

class _NominalElementMatch {
  final double amount;
  final int rowIndex;
  final TextElement element;

  const _NominalElementMatch({
    required this.amount,
    required this.rowIndex,
    required this.element,
  });
}

