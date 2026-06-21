import 'package:flutter/material.dart';

class AppConstants {
  // App
  static const String appName = 'QR Scanner Pro';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFF43A047);
  static const Color accentColor = Color(0xFFFF6D00);
  static const Color darkBg = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textLight = Colors.white;
  static const Color textDark = Colors.black87;

  // Zoom
  static const double minZoom = 1.0;
  static const double maxZoom = 10.0;
  static const double initialZoom = 1.0;

  // Database
  static const String dbName = 'qr_scanner_pro.db';
  static const int dbVersion = 1;
  static const String tableName = 'scan_history';
}

class AppStrings {
  static const String scanner = 'QR Scanner';
  static const String history = 'Riwayat Scan';
  static const String settings = 'Pengaturan';
  static const String qrResult = 'QR Result';
  static const String copy = 'Copy';
  static const String copied = 'Disalin ke clipboard';
  static const String openUrl = 'Open URL';
  static const String scanAgain = 'Scan Again';
  static const String noHistory = 'Belum ada riwayat scan';
  static const String deleteHistory = 'Hapus Riwayat';
  static const String deleteHistoryConfirm = 'Yakin ingin menghapus semua riwayat?';
  static const String cancel = 'Batal';
  static const String hapus = 'Hapus';
  static const String autoZoom = 'Auto Zoom';
  static const String autoZoomDesc = 'Otomatis zoom saat QR terlalu kecil/jauh';
}