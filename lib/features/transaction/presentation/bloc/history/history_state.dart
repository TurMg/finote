import '../../../domain/entities/transaction.dart';

enum FilterMode { semua, harian, mingguan, bulanan }
enum TransactionTypeFilter { semua, pengeluaran, pemasukan }

class HistoryState {
  final List<Transaction> allTransactions;
  final FilterMode filterMode;
  final TransactionTypeFilter typeFilter;
  final String searchQuery;
  final bool isLoading;

  const HistoryState({
    this.allTransactions = const [],
    this.filterMode = FilterMode.semua,
    this.typeFilter = TransactionTypeFilter.semua,
    this.searchQuery = '',
    this.isLoading = true,
  });

  List<Transaction> get filteredTransactions {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    var filtered = allTransactions.where((t) {
      // 1. Filter Berdasarkan Tipe (Pengeluaran vs Pemasukan)
      if (typeFilter == TransactionTypeFilter.pengeluaran && t.type == 'INCOME') {
        return false;
      }
      if (typeFilter == TransactionTypeFilter.pemasukan && t.type != 'INCOME') {
        return false;
      }

      // 2. Filter Berdasarkan Rentang Waktu
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);
      switch (filterMode) {
        case FilterMode.semua:
          return true;
        case FilterMode.harian:
          return tDate.isAtSameMomentAs(today);
        case FilterMode.mingguan:
          final weekStart = today.subtract(Duration(days: today.weekday - 1));
          return !tDate.isBefore(weekStart);
        case FilterMode.bulanan:
          return tDate.year == today.year && tDate.month == today.month;
      }
    }).toList();

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.category.toLowerCase().contains(query) ||
            t.note.toLowerCase().contains(query);
      }).toList();
    }

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  Map<String, Map<String, double>> get chartData {
    final Map<String, Map<String, double>> data = {};

    final uniqueCategories = <String>{};
    for (final t in filteredTransactions) {
      uniqueCategories.add(t.category);
    }
    final chartCategories = uniqueCategories.toList();
    if (chartCategories.isEmpty) {
      chartCategories.addAll(['Makanan', 'Transport', 'Gaji', 'Lainnya']);
    }

    if (filterMode == FilterMode.mingguan) {
      final labels = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      for (var label in labels) {
        data[label] = {for (var cat in chartCategories) cat: 0};
      }
      for (final t in filteredTransactions) {
        final label = labels[t.date.weekday - 1];
        final catKey = chartCategories.contains(t.category) ? t.category : 'Lainnya';
        data[label]?[catKey] = (data[label]?[catKey] ?? 0) + t.nominal;
      }
    } else if (filterMode == FilterMode.bulanan) {
      final labels = ['Mg 1', 'Mg 2', 'Mg 3', 'Mg 4', 'Mg 5'];
      for (var label in labels) {
        data[label] = {for (var cat in chartCategories) cat: 0};
      }
      for (final t in filteredTransactions) {
        int weekIndex = ((t.date.day - 1) / 7).floor();
        if (weekIndex > 4) weekIndex = 4;
        final catKey = chartCategories.contains(t.category) ? t.category : 'Lainnya';
        data[labels[weekIndex]]?[catKey] = (data[labels[weekIndex]]?[catKey] ?? 0) + t.nominal;
      }
    }
    return data;
  }

  HistoryState copyWith({
    List<Transaction>? allTransactions,
    FilterMode? filterMode,
    TransactionTypeFilter? typeFilter,
    String? searchQuery,
    bool? isLoading,
  }) {
    return HistoryState(
      allTransactions: allTransactions ?? this.allTransactions,
      filterMode: filterMode ?? this.filterMode,
      typeFilter: typeFilter ?? this.typeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}