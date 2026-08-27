/// Utility class untuk mengekstrak nominal angka dari teks bahasa Indonesia,
/// baik dalam bentuk digit angka, koma desimal, maupun kata terbilang (misal: "tiga juta setengah", "2,5 juta", "dua puluh lima ribu").
class IndonesianNumberParser {
  static const Map<String, String> _wordToNumber = {
    'nol': '0',
    'satu': '1',
    'dua': '2',
    'tiga': '3',
    'empat': '4',
    'lima': '5',
    'enam': '6',
    'tujuh': '7',
    'delapan': '8',
    'sebilan': '9',
    'sembilan': '9',
    'sepuluh': '10',
    'sebelas': '11',
  };

  // Kamus untuk slang nominal eksak
  static const Map<String, String> _exactSlangToNumber = {
    'gocap': '50',
    'cepek': '100',
    'gopek': '500',
    'seceng': '1000',
    'goceng': '5000',
    'ceban': '10000',
    'gopan': '50000',
  };

  // Kamus untuk prefix awalan "se"
  static const Map<String, String> _sePrefixes = {
    'sejuta': '1 juta',
    'seribu': '1 ribu',
    'seratus': '1 ratus',
  };

  // Kamus untuk belasan dan puluhan
  static const Map<String, String> _tensAndTeens = {
    'dua puluh lima': '25',
    'tiga puluh lima': '35',
    'empat puluh lima': '45',
    'lima puluh lima': '55',
    'dua belas': '12',
    'tiga belas': '13',
    'empat belas': '14',
    'lima belas': '15',
    'enam belas': '16',
    'tujuh belas': '17',
    'delapan belas': '18',
    'sembilan belas': '19',
    'sebilan belas': '19',
    'dua puluh': '20',
    'tiga puluh': '30',
    'empat puluh': '40',
    'lima puluh': '50',
    'enam puluh': '60',
    'tujuh puluh': '70',
    'delapan puluh': '80',
    'sembilan puluh': '90',
    'sebilan puluh': '90',
  };

  // Kamus ratusan
  static const Map<String, String> _hundreds = {
    'dua ratus': '200',
    'tiga ratus': '300',
    'empat ratus': '400',
    'lima ratus': '500',
    'enam ratus': '600',
    'tujuh ratus': '700',
    'delapan ratus': '800',
    'sembilan ratus': '900',
    'sebilan ratus': '900',
  };

  // Slang unit multiplier
  static const Map<String, String> _unitSlang = {
    'jt': 'juta',
    'jeti': 'juta',
    'mio': 'juta',
    'rb': 'ribu',
    'k': 'ribu',
    'ceng': 'ribu',
    'ribuan': 'ribu',
  };

  /// Mengekstrak nominal angka dari string teks.
  /// Mengembalikan `0.0` jika tidak ada nominal yang dapat dikenali.
  static double extractNominal(String text) {
    if (text.isEmpty) return 0.0;

    var lowerText = text.toLowerCase().trim();
    
    // Hapus simbol mata uang (rp, rp.) yang menempel atau terpisah dari angka
    lowerText = lowerText.replaceAll(RegExp(r'\brp\.?\s*'), '');

    // 1. Cek format angka murni dengan titik ribuan (misal: "3.500.000" atau "25.000")
    final pureDotFormatted = _checkPureDotFormatted(lowerText);
    if (pureDotFormatted > 0) {
      return pureDotFormatted;
    }

    // 2. Normalisasi kata terbilang ke bentuk digit terstruktur
    final normalized = _normalizeText(lowerText);

    // 3. Ekstraksi token terintegrasi (digit + kata unit + "setengah")
    return _parseTokens(normalized);
  }

  /// Memeriksa angka murni bersambung dengan pemisah titik ribuan (misal: "3.500.000")
  static double _checkPureDotFormatted(String text) {
    final reg = RegExp(r'\b(\d{1,3}(?:\.\d{3})+)\b');
    final match = reg.firstMatch(text);
    if (match != null) {
      final numStr = match.group(1)!.replaceAll('.', '');
      return double.tryParse(numStr) ?? 0.0;
    }
    return 0.0;
  }

  /// Normalisasi variasi ejaan & terbilang bahasa Indonesia ke angka digit
  static String _normalizeText(String text) {
    var s = text;

    // Normalisasi koma/titik desimal (misal: "3,5" -> "3.5", "1,5" -> "1.5")
    s = s.replaceAllMapped(RegExp(r'(\d+),(\d+)'), (m) => '${m[1]}.${m[2]}');
    s = s.replaceAllMapped(RegExp(r'(\d+)\s*(?:koma|titik)\s*(\d+)'), (m) => '${m[1]}.${m[2]}');

    // Pisahkan digit yang menempel pada huruf unit (misal: "15rb" -> "15 rb", "25k" -> "25 k")
    s = s.replaceAllMapped(RegExp(r'(\d+(?:\.\d+)?)\s*([a-zA-Z]+)'), (m) => '${m[1]} ${m[2]}');

    // 1. Slang Eksak (gopek, ceban)
    _exactSlangToNumber.forEach((word, val) {
      s = s.replaceAll(RegExp(r'\b' + word + r'\b'), val);
    });

    // 2. Awalan "se"
    _sePrefixes.forEach((word, val) {
      s = s.replaceAll(RegExp(r'\b' + word + r'\b'), val);
    });

    // 3. Belasan & Puluhan
    _tensAndTeens.forEach((word, val) {
      s = s.replaceAll(RegExp(r'\b' + word + r'\b'), val);
    });

    // 4. Ratusan
    _hundreds.forEach((word, val) {
      s = s.replaceAll(RegExp(r'\b' + word + r'\b'), val);
    });

    // 5. Angka Satuan 1..9
    _wordToNumber.forEach((word, val) {
      if (word != 'nol') {
        s = s.replaceAll(RegExp(r'\b' + word + r'\b'), val);
      }
    });

    // 6. Singkatan dan Slang Unit Multiplier
    _unitSlang.forEach((word, val) {
      s = s.replaceAll(RegExp(r'\b' + word + r'\b'), val);
    });

    // Menghapus kata perak (biasa muncul di akhir kalimat gaul)
    s = s.replaceAll(RegExp(r'\bperak\b'), '');

    return s;
  }

  /// Parser token serbaguna untuk mengekstrak nominal angka secara akurat
  static double _parseTokens(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^a-z0-9\.\s]'), ' ');
    final tokens = cleaned.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    double total = 0.0;
    double currentNum = 0.0;
    double lastUnitValue = 0.0;

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];

      // Jika token adalah digit angka (misal: "3", "3.5", "25000")
      final parsedNum = double.tryParse(token);
      if (parsedNum != null) {
        currentNum += parsedNum;
        continue;
      }

      // Penanganan kata "setengah"
      if (token == 'setengah') {
        if (i + 1 < tokens.length && _getUnitMultiplier(tokens[i + 1]) > 1) {
          currentNum += 0.5;
        } else if (lastUnitValue > 1) {
          total += (lastUnitValue / 2.0);
          lastUnitValue = 0.0;
        } else if (currentNum > 0) {
          currentNum += 0.5;
        } else {
          currentNum = 0.5;
        }
        continue;
      }

      // Penanganan kata unit (juta, ribu, ratus)
      final unitMultiplier = _getUnitMultiplier(token);
      if (unitMultiplier > 1) {
        if (currentNum == 0.0) {
          currentNum = 1.0;
        }
        final segmentTotal = currentNum * unitMultiplier;
        total += segmentTotal;
        lastUnitValue = unitMultiplier;
        currentNum = 0.0;
        continue;
      }
    }

    if (currentNum > 0) {
      if (lastUnitValue == 1000000 && currentNum < 1000) {
        total += (currentNum * 1000);
      } else {
        total += currentNum;
      }
    }

    return total;
  }

  static double _getUnitMultiplier(String token) {
    if (token == 'juta') return 1000000.0;
    if (token == 'ribu') return 1000.0;
    if (token == 'ratus') return 100.0;
    return 0.0;
  }
}
