part of 'settings_bloc.dart';

abstract class SettingsEvent {
  const SettingsEvent();
}

class UpdateRefreshRate extends SettingsEvent {
  final int refreshRateHz;
  const UpdateRefreshRate(this.refreshRateHz);
}

class ToggleAxisVisibility extends SettingsEvent {
  final String axis;
  final bool isVisible;
  const ToggleAxisVisibility({required this.axis, required this.isVisible});
}

class UpdateThemeMode extends SettingsEvent {
  final bool isDarkMode;
  const UpdateThemeMode(this.isDarkMode);
}

class UpdateHistorySize extends SettingsEvent {
  final HistorySizeOption historySize;
  const UpdateHistorySize(this.historySize);
}

