import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScannerState {
  final double currentZoom;
  final bool isFlashOn;
  final bool isAutoZoomEnabled;
  final bool isScanning;
  final int? selectedLensIndex;

  ScannerState({
    this.currentZoom = 1.0,
    this.isFlashOn = false,
    this.isAutoZoomEnabled = true,
    this.isScanning = true,
    this.selectedLensIndex,
  });

  ScannerState copyWith({
    double? currentZoom,
    bool? isFlashOn,
    bool? isAutoZoomEnabled,
    bool? isScanning,
    int? selectedLensIndex,
    bool clearLensIndex = false,
  }) {
    return ScannerState(
      currentZoom: currentZoom ?? this.currentZoom,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      isAutoZoomEnabled: isAutoZoomEnabled ?? this.isAutoZoomEnabled,
      isScanning: isScanning ?? this.isScanning,
      selectedLensIndex:
          clearLensIndex ? null : (selectedLensIndex ?? this.selectedLensIndex),
    );
  }
}

class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier() : super(ScannerState());

  void setZoom(double zoom) {
    state = state.copyWith(currentZoom: zoom);
  }

  void toggleFlash() {
    state = state.copyWith(isFlashOn: !state.isFlashOn);
  }

  void setFlash(bool on) {
    state = state.copyWith(isFlashOn: on);
  }

  void toggleAutoZoom() {
    state = state.copyWith(isAutoZoomEnabled: !state.isAutoZoomEnabled);
  }

  void setAutoZoom(bool enabled) {
    state = state.copyWith(isAutoZoomEnabled: enabled);
  }

  void setScanning(bool scanning) {
    state = state.copyWith(isScanning: scanning);
  }

  void setLensIndex(int? index) {
    state = state.copyWith(selectedLensIndex: index);
  }

  void reset() {
    state = ScannerState();
  }
}

final scannerProvider =
    StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
  return ScannerNotifier();
});