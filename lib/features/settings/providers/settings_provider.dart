import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final bool autoZoomEnabled;

  SettingsState({
    this.autoZoomEnabled = true,
  });

  SettingsState copyWith({
    bool? autoZoomEnabled,
  }) {
    return SettingsState(
      autoZoomEnabled: autoZoomEnabled ?? this.autoZoomEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState());

  void toggleAutoZoom() {
    state = state.copyWith(autoZoomEnabled: !state.autoZoomEnabled);
  }

  void setAutoZoom(bool enabled) {
    state = state.copyWith(autoZoomEnabled: enabled);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});