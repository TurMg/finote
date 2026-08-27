import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final int selectionIndexFromRight = newValue.text.length - newValue.selection.end;
    
    // Hapus semua karakter selain angka
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Kalau kosong setelah dibersihkan, kembalikan kosong
    if (cleanText.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    // Parse jadi angka
    double value = double.tryParse(cleanText) ?? 0;
    
    // Format jadi ribuan (pisahkan dengan titik ala Indonesia)
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0);
    String formattedText = formatter.format(value).trim();

    // Hitung posisi kursor dari kanan agar tidak loncat
    int newSelectionEnd = formattedText.length - selectionIndexFromRight;
    if (newSelectionEnd < 0) {
      newSelectionEnd = 0;
    } else if (newSelectionEnd > formattedText.length) {
      newSelectionEnd = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: newSelectionEnd,
      ),
    );
  }
}
