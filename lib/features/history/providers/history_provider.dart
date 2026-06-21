import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../../../models/scan_history.dart';

class HistoryState {
  final List<ScanHistory> scans;
  final bool isLoading;
  final String? error;

  HistoryState({
    this.scans = const [],
    this.isLoading = false,
    this.error,
  });

  HistoryState copyWith({
    List<ScanHistory>? scans,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      scans: scans ?? this.scans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final DatabaseHelper _dbHelper;

  HistoryNotifier(this._dbHelper) : super(HistoryState()) {
    loadScans();
  }

  Future<void> loadScans() async {
    state = state.copyWith(isLoading: true);
    try {
      final scans = await _dbHelper.getAllScans();
      state = state.copyWith(scans: scans, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal memuat riwayat: $e',
      );
    }
  }

  Future<void> addScan(ScanHistory scan) async {
    try {
      await _dbHelper.insertScan(scan);
      await loadScans();
    } catch (e) {
      state = state.copyWith(error: 'Gagal menyimpan scan: $e');
    }
  }

  Future<void> deleteScan(int id) async {
    try {
      await _dbHelper.deleteScan(id);
      await loadScans();
    } catch (e) {
      state = state.copyWith(error: 'Gagal menghapus scan: $e');
    }
  }

  Future<void> deleteAllScans() async {
    try {
      await _dbHelper.deleteAllScans();
      await loadScans();
    } catch (e) {
      state = state.copyWith(error: 'Gagal menghapus riwayat: $e');
    }
  }
}

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return HistoryNotifier(dbHelper);
});