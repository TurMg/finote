// core/utils/icon_resolver.dart

import 'package:flutter/material.dart';

/// Helper class untuk mengkonversi string nama icon ke IconData dan sebaliknya.
/// Berisi predefined set ~30 icon Material yang tersedia untuk dipilih user.
class IconResolver {
  IconResolver._();

  /// Map dari nama icon ke IconData
  static const Map<String, IconData> availableIcons = {
    // Makanan & Minuman
    'restaurant_rounded': Icons.restaurant_rounded,
    'local_cafe_rounded': Icons.local_cafe_rounded,
    'fastfood_rounded': Icons.fastfood_rounded,
    'local_pizza_rounded': Icons.local_pizza_rounded,
    'icecream_rounded': Icons.icecream_rounded,
    'cake_rounded': Icons.cake_rounded,
    'local_bar_rounded': Icons.local_bar_rounded,
    'coffee_rounded': Icons.coffee_rounded,

    // Transport
    'directions_bus_rounded': Icons.directions_bus_rounded,
    'directions_car_rounded': Icons.directions_car_rounded,
    'two_wheeler_rounded': Icons.two_wheeler_rounded,
    'train_rounded': Icons.train_rounded,
    'flight_rounded': Icons.flight_rounded,
    'local_gas_station_rounded': Icons.local_gas_station_rounded,

    // Keuangan & Tagihan & Pemasukan
    'receipt_long_rounded': Icons.receipt_long_rounded,
    'payments_rounded': Icons.payments_rounded,
    'account_balance_wallet_rounded': Icons.account_balance_wallet_rounded,
    'credit_card_rounded': Icons.credit_card_rounded,
    'savings_rounded': Icons.savings_rounded,
    'card_giftcard_rounded': Icons.card_giftcard_rounded,
    'trending_up_rounded': Icons.trending_up_rounded,
    'storefront_rounded': Icons.storefront_rounded,

    // Belanja & Gaya Hidup
    'shopping_bag_rounded': Icons.shopping_bag_rounded,
    'shopping_cart_rounded': Icons.shopping_cart_rounded,
    'checkroom_rounded': Icons.checkroom_rounded,
    'redeem_rounded': Icons.redeem_rounded,

    // Kesehatan & Pendidikan
    'local_hospital_rounded': Icons.local_hospital_rounded,
    'school_rounded': Icons.school_rounded,
    'menu_book_rounded': Icons.menu_book_rounded,
    'fitness_center_rounded': Icons.fitness_center_rounded,

    // Hiburan & Lainnya
    'sports_esports_rounded': Icons.sports_esports_rounded,
    'movie_rounded': Icons.movie_rounded,
    'home_rounded': Icons.home_rounded,
    'wifi_rounded': Icons.wifi_rounded,
    'phone_android_rounded': Icons.phone_android_rounded,
    'pets_rounded': Icons.pets_rounded,
    'child_care_rounded': Icons.child_care_rounded,
    'more_horiz_rounded': Icons.more_horiz_rounded,
  };

  /// Konversi nama icon string ke IconData
  /// Fallback ke receipt_long_rounded jika tidak ditemukan
  static IconData resolve(String iconName) {
    return availableIcons[iconName] ?? Icons.receipt_long_rounded;
  }

  /// Ambil semua nama icon yang tersedia
  static List<String> get allIconNames => availableIcons.keys.toList();

  /// Helper untuk cek tipe icon
  static bool isEmoji(String iconName) => iconName.startsWith('emoji:');
  static bool isImage(String iconName) => iconName.startsWith('image:');
  static bool isVector(String iconName) => !isEmoji(iconName) && !isImage(iconName);
}

/// Predefined color palette untuk kategori
class CategoryColorPalette {
  CategoryColorPalette._();

  /// Pasangan warna (icon color, background color) yang sudah dikurasi
  static const List<Map<String, int>> colors = [
    {'color': 0xFFE05263, 'bg': 0xFFFAB5C7},  // Merah Pink
    {'color': 0xFF4A90E2, 'bg': 0xFF96DCFF},  // Biru
    {'color': 0xFFF5A623, 'bg': 0xFFFFFDB4},  // Kuning Orange
    {'color': 0xFF006B2C, 'bg': 0xFF88F9B7},  // Hijau Tua
    {'color': 0xFF9B59B6, 'bg': 0xFFE8D5F5},  // Ungu
    {'color': 0xFFE67E22, 'bg': 0xFFFDE8D0},  // Orange
    {'color': 0xFF1ABC9C, 'bg': 0xFFD0F5ED},  // Teal
    {'color': 0xFFC0392B, 'bg': 0xFFF5CECE},  // Merah Tua
    {'color': 0xFF2980B9, 'bg': 0xFFD4EEFF},  // Biru Tua
    {'color': 0xFF27AE60, 'bg': 0xFFD4F5E0},  // Hijau
    {'color': 0xFF8E44AD, 'bg': 0xFFE8CFFA},  // Purple Tua
    {'color': 0xFFD4AC0D, 'bg': 0xFFF9F0C5},  // Gold
    {'color': 0xFF16A085, 'bg': 0xFFCCF2E8},  // Dark Teal
    {'color': 0xFFE74C3C, 'bg': 0xFFFCDEDB},  // Coral
    {'color': 0xFF3498DB, 'bg': 0xFFD6ECFB},  // Light Blue
    {'color': 0xFF2ECC71, 'bg': 0xFFD5F5E3},  // Emerald
    {'color': 0xFF10B981, 'bg': 0xFFA7F3D0},  // Green (Gaji)
    {'color': 0xFF8B5CF6, 'bg': 0xFFDDD6FE},  // Purple (Bonus)
    {'color': 0xFF3B82F6, 'bg': 0xFFBFDBFE},  // Blue (Investasi)
    {'color': 0xFFF59E0B, 'bg': 0xFFFDE68A},  // Amber (Penjualan)
  ];
}
