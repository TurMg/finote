/// Utility helper untuk menyarankan kata kunci voice secara kontekstual & pintar
/// berdasarkan nama kategori Bahasa Indonesia yang diinput pengguna.
class CategoryKeywordHelper {
  CategoryKeywordHelper._();

  static const Map<String, List<String>> _domainKeywordsMap = {
    // 1. Makanan & Kuliner
    'makan': [
      'makan',
      'makanan',
      'kuliner',
      'resto',
      'restoran',
      'warteg',
      'gacoan',
      'jajan',
      'cemilan',
      'snack',
      'cafe',
      'katering',
      'sarapan',
      'makan siang',
      'makan malam',
      'bakery',
      'roti',
      'seblak',
      'bakso',
      'mie',
      'sate',
      'ayam',
      'kopi',
      'boba',
      'jus',
      'es'
    ],
    'minum': ['minum', 'minuman', 'kopi', 'boba', 'jus', 'es', 'tea', 'teh', 'cafe'],
    'kuliner': ['makan', 'makanan', 'kuliner', 'resto', 'warteg', 'gacoan', 'jajan', 'cafe'],
    'jajan': ['jajan', 'snack', 'cemilan', 'boba', 'kopi', 'seblak', 'bakso', 'mie'],
    'kopi': ['kopi', 'coffee', 'cafe', 'boba', 'minuman', 'jajan', 'nongkrong'],
    'resto': ['resto', 'restoran', 'makan', 'makanan', 'kuliner', 'dinner', 'lunch'],

    // 2. Transportasi & Otomotif
    'transport': [
      'transport',
      'transportasi',
      'bensin',
      'pertalite',
      'pertamax',
      'solar',
      'shell',
      'ojek',
      'ojol',
      'gojek',
      'goride',
      'gocar',
      'grab',
      'grabbike',
      'grabcar',
      'maxim',
      'angkot',
      'bus',
      'krl',
      'mrt',
      'kereta',
      'tiket',
      'pesawat',
      'parkir',
      'tol',
      'e-toll',
      'emoney',
      'flazz',
      'cuci motor',
      'servis',
      'oli',
      'bengkel'
    ],
    'bensin': ['bensin', 'pertalite', 'pertamax', 'solar', 'shell', 'bp', 'bbm', 'isi bensin'],
    'ojek': ['ojek', 'ojol', 'gojek', 'goride', 'gocar', 'grab', 'grabbike', 'grabcar', 'maxim'],
    'parkir': ['parkir', 'e-toll', 'emoney', 'flazz', 'tol'],
    'bengkel': ['bengkel', 'servis', 'oli', 'cuci motor', 'cuci mobil', 'sparepart', 'ban'],

    // 3. Belanja & Kebutuhan Rumah
    'belanja': [
      'belanja',
      'bulanan',
      'harian',
      'supermarket',
      'minimarket',
      'alfamart',
      'indomaret',
      'superindo',
      'hypermart',
      'pasar',
      'sembako',
      'beras',
      'minyak',
      'sabun',
      'shampoo',
      'pampers',
      'deterjen',
      'tisu',
      'galon',
      'gas'
    ],
    'sembako': ['sembako', 'beras', 'minyak', 'gula', 'telur', 'sabun', 'deterjen', 'pasar'],
    'pasar': ['pasar', 'sembako', 'sayur', 'buah', 'daging', 'ikan', 'bumbu'],

    // 4. Tagihan & Komunikasi
    'tagihan': [
      'tagihan',
      'listrik',
      'pln',
      'token',
      'air',
      'pdam',
      'wifi',
      'internet',
      'indihome',
      'biznet',
      'myrepublic',
      'firstmedia',
      'xl',
      'telkomsel',
      'indosat',
      'tri',
      'kuota',
      'paket data',
      'pulsa',
      'tv kabel',
      'iuran'
    ],
    'listrik': ['listrik', 'pln', 'token', 'iuran', 'tagihan'],
    'air': ['air', 'pdam', 'tagihan', 'iuran'],
    'internet': ['wifi', 'internet', 'indihome', 'biznet', 'myrepublic', 'kuota', 'pulsa'],
    'pulsa': ['pulsa', 'kuota', 'paket data', 'telkomsel', 'xl', 'indosat', 'tri', 'smartfren'],

    // 5. Gaji & Pendapatan
    'gaji': [
      'gaji',
      'gajian',
      'salary',
      'payroll',
      'bonus',
      'thr',
      'dividen',
      'insentif',
      'omset',
      'omzet',
      'komisi',
      'profit',
      'honor',
      'royalti',
      'cashback',
      'refund',
      'jualan'
    ],
    'bonus': ['bonus', 'thr', 'insentif', 'komisi', 'omset', 'profit', 'reward'],
    'pendapatan': ['gaji', 'gajian', 'bonus', 'omset', 'profit', 'jualan', 'hasil dagang'],

    // 6. Hiburan & Media
    'hiburan': [
      'hiburan',
      'nonton',
      'bioskop',
      'xx1',
      'cgv',
      'tiket',
      'konser',
      'game',
      'steam',
      'ps',
      'mobile legends',
      'pubg',
      'topup',
      'voucher',
      'spotify',
      'netflix',
      'youtube',
      'liburan',
      'staycation',
      'hotel'
    ],
    'game': ['game', 'gaming', 'steam', 'topup', 'voucher', 'mobile legends', 'pubg', 'free fire'],
    'nonton': ['nonton', 'bioskop', 'xx1', 'cgv', 'netflix', 'disney', 'youtube', 'spotify'],
    'liburan': ['liburan', 'vacation', 'staycation', 'hotel', 'penginapan', 'travel', 'piknik'],

    // 7. Kesehatan & Perawatan
    'kesehatan': [
      'kesehatan',
      'sehat',
      'obat',
      'apotek',
      'kimia farma',
      'k24',
      'dokter',
      'rumah sakit',
      'rs',
      'klinik',
      'puskesmas',
      'bpjs',
      'asuransi',
      'vitamin',
      'skincare',
      'salon',
      'barbershop',
      'gym',
      'fitnes'
    ],
    'obat': ['obat', 'apotek', 'k24', 'kimia farma', 'dokter', 'vitamin', 'suplemen'],
    'skincare': ['skincare', 'salon', 'barbershop', 'potong rambut', 'spa', 'perawatan', 'makeup'],
    'gym': ['gym', 'fitnes', 'olahraga', 'sehat', 'kesehatan'],

    // 8. Pendidikan & Kursus
    'pendidikan': [
      'pendidikan',
      'sekolah',
      'spp',
      'kuliah',
      'ukt',
      'les',
      'kursus',
      'bimbel',
      'ruangguru',
      'bootcamp',
      'sertifikasi',
      'seminar',
      'workshop',
      'buku',
      'alat tulis',
      'seragam'
    ],
    'buku': ['buku', 'alat tulis', 'atk', 'fotokopi', 'novel', 'modul'],

    // 9. Investasi & Keuangan
    'investasi': [
      'investasi',
      'invest',
      'tabungan',
      'reksadana',
      'saham',
      'crypto',
      'kripto',
      'bitcoin',
      'eth',
      'emas',
      'antam',
      'bibit',
      'ajaib',
      'stockbit',
      'deposito'
    ],
    'tabungan': ['tabungan', 'simpanan', 'deposito', 'investasi', 'reksadana', 'emas'],

    // 10. Sedekah & Donasi
    'sedekah': [
      'sedekah',
      'zakat',
      'infaq',
      'infak',
      'donasi',
      'baksos',
      'panti',
      'sumbangan',
      'persembahan',
      'hadiah',
      'kado',
      'umroh',
      'qurban'
    ],
    'zakat': ['zakat', 'sedekah', 'infaq', 'donasi', 'panti'],

    // 11. Pakaian & Fashion
    'pakaian': [
      'pakaian',
      'baju',
      'celana',
      'kaos',
      'kemeja',
      'jaket',
      'sepatu',
      'sandal',
      'tas',
      'dompet',
      'jam tangan',
      'hijab',
      'fashion',
      'distro',
      'laundry'
    ],
    'laundry': ['laundry', 'cuci baju', 'setrika', 'pakaian'],

    // 12. Cicilan & Kredit
    'cicilan': [
      'cicilan',
      'angsuran',
      'kredit',
      'kpr',
      'multifinance',
      'leasing',
      'pinjol',
      'paylater',
      'kartu kredit',
      'cc',
      'bayar utang'
    ],

    // 13. Hewan Peliharaan
    'kucing': ['kucing', 'pet', 'hewan', 'petshop', 'pakan', 'makanan kucing', 'pasir', 'grooming', 'vet'],
    'hewan': ['hewan', 'pet', 'petshop', 'pakan', 'dokter hewan', 'vet', 'grooming'],
    'pet': ['pet', 'petshop', 'hewan', 'pakan', 'makanan kucing', 'pasir', 'grooming']
  };

  /// Mengembalikan saran kata kunci yang terpisah koma berdasarkan kemiripan nama kategori.
  static String getSuggestedKeywords(String categoryName) {
    final cleanInput = categoryName.trim().toLowerCase();
    if (cleanInput.isEmpty) return '';

    final Set<String> suggestedKeywords = {};

    // 1. Masukkan kata-kata bersih dari nama kategori itu sendiri
    final words = cleanInput
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 1)
        .toList();

    for (var w in words) {
      suggestedKeywords.add(w);
    }

    // 2. Cari kemiripan kata kunci berdasarkan kamus domain
    _domainKeywordsMap.forEach((key, list) {
      if (cleanInput.contains(key) || key.contains(cleanInput)) {
        suggestedKeywords.addAll(list);
      } else {
        for (var w in words) {
          if (w.contains(key) || key.contains(w)) {
            suggestedKeywords.addAll(list);
          }
        }
      }
    });

    return suggestedKeywords.join(', ');
  }
}
