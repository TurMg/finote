import 'package:flutter_test/flutter_test.dart';
import 'package:finote/core/utils/category_keyword_helper.dart';

void main() {
  group('CategoryKeywordHelper Unit Tests', () {
    test('suggests food keywords for Makanan or Kuliner category', () {
      final res = CategoryKeywordHelper.getSuggestedKeywords('Makanan & Kuliner');
      expect(res, contains('makan'));
      expect(res, contains('resto'));
      expect(res, contains('warteg'));
      expect(res, contains('gacoan'));
      expect(res, contains('jajan'));
    });

    test('suggests transport & fuel keywords for Bensin / Transport category', () {
      final res = CategoryKeywordHelper.getSuggestedKeywords('Bensin Motor');
      expect(res, contains('bensin'));
      expect(res, contains('pertalite'));
      expect(res, contains('pertamax'));
      expect(res, contains('shell'));
    });

    test('suggests bill keywords for Tagihan Listrik / Wifi category', () {
      final res = CategoryKeywordHelper.getSuggestedKeywords('Tagihan Listrik & Wifi');
      expect(res, contains('tagihan'));
      expect(res, contains('listrik'));
      expect(res, contains('pln'));
      expect(res, contains('wifi'));
      expect(res, contains('indihome'));
    });

    test('suggests salary keywords for Gaji & Bonus category', () {
      final res = CategoryKeywordHelper.getSuggestedKeywords('Gaji Bulanan');
      expect(res, contains('gaji'));
      expect(res, contains('gajian'));
      expect(res, contains('bonus'));
      expect(res, contains('thr'));
    });

    test('suggests pet keywords for Kucing / Petshop category', () {
      final res = CategoryKeywordHelper.getSuggestedKeywords('Kucing Kesayangan');
      expect(res, contains('kucing'));
      expect(res, contains('petshop'));
      expect(res, contains('pakan'));
    });

    test('returns empty string for empty input', () {
      final res = CategoryKeywordHelper.getSuggestedKeywords('');
      expect(res, isEmpty);
    });
  });
}
