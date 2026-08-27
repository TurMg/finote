import 'package:shared_preferences/shared_preferences.dart';

class ColorHistoryManager {
  static const String _key = 'color_history';
  static const int _maxHistoryLength = 10;

  /// Get the list of color integers from history.
  static Future<List<int>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? historyStrings = prefs.getStringList(_key);

    if (historyStrings == null || historyStrings.isEmpty) {
      // Default initial colors if history is empty
      return [
        0xFF927C6F, // Primary Finote Color
        0xFF15803D, // Income Green
        0xFFC93B3B, // Expense Red
        0xFFE05263, // Merah Pink
        0xFF4A90E2, // Biru
        0xFFF5A623, // Kuning Orange
      ];
    }

    return historyStrings.map((s) => int.parse(s)).toList();
  }

  /// Add a new color to history. Moves it to the front if it already exists.
  static Future<void> addColor(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    final List<int> currentHistory = await getHistory();

    // Remove if it already exists to avoid duplicates
    currentHistory.remove(colorValue);

    // Add to the front of the list
    currentHistory.insert(0, colorValue);

    // Keep only the latest 10 colors
    if (currentHistory.length > _maxHistoryLength) {
      currentHistory.removeRange(_maxHistoryLength, currentHistory.length);
    }

    // Save back to SharedPreferences as List<String>
    final historyStrings = currentHistory.map((c) => c.toString()).toList();
    await prefs.setStringList(_key, historyStrings);
  }
}
