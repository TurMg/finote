import 'package:flutter_test/flutter_test.dart';
import 'package:finote/core/utils/indonesian_number_parser.dart';

void main() {
  group('IndonesianNumberParser Test Cases', () {
    test('Parse "tiga juta setengah" -> 3.500.000', () {
      expect(IndonesianNumberParser.extractNominal('gaji tiga juta setengah'), equals(3500000.0));
    });

    test('Parse "3 juta setengah" -> 3.500.000', () {
      expect(IndonesianNumberParser.extractNominal('gaji 3 juta setengah'), equals(3500000.0));
    });

    test('Parse "tiga setengah juta" -> 3.500.000', () {
      expect(IndonesianNumberParser.extractNominal('3 setengah juta'), equals(3500000.0));
    });

    test('Parse "dua setengah juta" -> 2.500.000', () {
      expect(IndonesianNumberParser.extractNominal('dua setengah juta'), equals(2500000.0));
    });

    test('Parse "2,5 juta" -> 2.500.000', () {
      expect(IndonesianNumberParser.extractNominal('2,5 juta'), equals(2500000.0));
    });

    test('Parse "sejuta setengah" -> 1.500.000', () {
      expect(IndonesianNumberParser.extractNominal('sejuta setengah'), equals(1500000.0));
    });

    test('Parse "setengah juta" -> 500.000', () {
      expect(IndonesianNumberParser.extractNominal('setengah juta'), equals(500000.0));
    });

    test('Parse "lima belas ribu setengah" -> 15.500', () {
      expect(IndonesianNumberParser.extractNominal('lima belas ribu setengah'), equals(15500.0));
    });

    test('Parse "15rb setengah" -> 15.500', () {
      expect(IndonesianNumberParser.extractNominal('15rb setengah'), equals(15500.0));
    });

    test('Parse "3.500.000" -> 3.500.000', () {
      expect(IndonesianNumberParser.extractNominal('3.500.000'), equals(3500000.0));
    });

    test('Parse "dua puluh lima ribu" -> 25.000', () {
      expect(IndonesianNumberParser.extractNominal('dua puluh lima ribu'), equals(25000.0));
    });

    test('Parse "gajian rp3.500.000" -> 3.500.000', () {
      expect(IndonesianNumberParser.extractNominal('gajian rp3.500.000'), equals(3500000.0));
    });

    test('Parse Slang: "cepek" -> 100', () {
      expect(IndonesianNumberParser.extractNominal('bayar parkir cepek'), equals(100.0));
    });

    test('Parse Slang: "gopek" -> 500', () {
      expect(IndonesianNumberParser.extractNominal('beli gorengan gopek'), equals(500.0));
    });

    test('Parse Slang: "goceng" -> 5000', () {
      expect(IndonesianNumberParser.extractNominal('jajan goceng'), equals(5000.0));
    });

    test('Parse Slang: "ceban" -> 10000', () {
      expect(IndonesianNumberParser.extractNominal('bayar ceban'), equals(10000.0));
    });

    test('Parse Slang: "dua ceng" -> 2000', () {
      expect(IndonesianNumberParser.extractNominal('dua ceng'), equals(2000.0));
    });

    test('Parse Slang: "5 jeti" -> 5.000.000', () {
      expect(IndonesianNumberParser.extractNominal('dapat gaji 5 jeti'), equals(5000000.0));
    });

    test('Parse Slang: "selembar gopan" -> 50000', () {
      expect(IndonesianNumberParser.extractNominal('gopan'), equals(50000.0));
    });
  });
}
