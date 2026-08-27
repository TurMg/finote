import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:finote/features/transaction/domain/usecases/receipt_scanner_usecase.dart';

void main() {
  group('OCRTextNormalizer Test Cases', () {
    test('Corrects OCR misreads O, S, I, B, g, Z into digits', () {
      expect(OCRTextNormalizer.normalizeNumberString('SO.OOO'), equals('50.000'));
      expect(OCRTextNormalizer.normalizeNumberString('Rp SO.OOO'), equals('50.000'));
      expect(OCRTextNormalizer.normalizeNumberString('15.5OO'), equals('15.500'));
      expect(OCRTextNormalizer.normalizeNumberString('I2.O00'), equals('12.000'));
      expect(OCRTextNormalizer.normalizeNumberString('B0.000'), equals('80.000'));
    });
  });

  group('ReceiptNominalParser Test Cases', () {
    test('Parses standard Indonesian currency strings', () {
      expect(ReceiptNominalParser.parseNominalString('150.000,00'), equals(150000.0));
      expect(ReceiptNominalParser.parseNominalString('Rp 150.000'), equals(150000.0));
      expect(ReceiptNominalParser.parseNominalString('54.500,-'), equals(54500.0));
      expect(ReceiptNominalParser.parseNominalString('25,000.00'), equals(25000.0));
      expect(ReceiptNominalParser.parseNominalString('15500'), equals(15500.0));
    });

    test('Extracts multiple valid nominals from raw text string', () {
      final nominals = ReceiptNominalParser.extractNominals('Total Belanja Rp 150.000');
      expect(nominals, contains(150000.0));
    });

    test('Rejects invalid digit lengths (barcodes / timestamps)', () {
      expect(ReceiptNominalParser.parseNominalString('1234567890123'), isNull); // > 9 digits
      expect(ReceiptNominalParser.parseNominalString('12'), isNull); // < 3 digits
    });
  });

  group('CandidateScorer Test Cases', () {
    test('Scores higher for same row right-aligned nominals in lower region', () {
      final keywordBox = const Rect.fromLTWH(10, 500, 100, 20);
      final nominalBox = const Rect.fromLTWH(200, 500, 80, 20);
      final receiptBounds = const Rect.fromLTWH(0, 0, 400, 800);

      final keywordElement = TextElement(text: 'TOTAL', boundingBox: keywordBox, cornerPoints: [], recognizedLanguages: [], symbols: [], confidence: null, angle: null);
      final nominalElement = TextElement(text: '150.000', boundingBox: nominalBox, cornerPoints: [], recognizedLanguages: [], symbols: [], confidence: null, angle: null);

      final score = CandidateScorer.calculateScore(
        keywordWeight: 100,
        rowText: 'total belanja 150.000',
        nominalRowIndex: 5,
        keywordRowIndex: 5,
        nominalElement: nominalElement,
        keywordElement: keywordElement,
        receiptBounds: receiptBounds,
      );

      // Weight 100 + Spatial same-row 60 + Lower region 35 = 195
      expect(score, equals(195));
    });

    test('Penalizes soft blacklist keywords like tunai or tax', () {
      final keywordBox = const Rect.fromLTWH(10, 500, 100, 20);
      final nominalBox = const Rect.fromLTWH(200, 500, 80, 20);
      final receiptBounds = const Rect.fromLTWH(0, 0, 400, 800);

      final keywordElement = TextElement(text: 'TOTAL', boundingBox: keywordBox, cornerPoints: [], recognizedLanguages: [], symbols: [], confidence: null, angle: null);
      final nominalElement = TextElement(text: '200.000', boundingBox: nominalBox, cornerPoints: [], recognizedLanguages: [], symbols: [], confidence: null, angle: null);

      final score = CandidateScorer.calculateScore(
        keywordWeight: 70,
        rowText: 'total tunai 200.000',
        nominalRowIndex: 6,
        keywordRowIndex: 6,
        nominalElement: nominalElement,
        keywordElement: keywordElement,
        receiptBounds: receiptBounds,
      );

      // Weight 70 - 40 (tunai penalty) + 60 (spatial) + 35 (position) = 125
      expect(score, equals(125));
    });
  });
}
