class VoiceParsedData {
  final double nominal;
  final String category;
  final String note;
  final String type; // 'EXPENSE' or 'INCOME'

  VoiceParsedData({
    required this.nominal,
    required this.category,
    required this.note,
    this.type = 'EXPENSE',
  });
}