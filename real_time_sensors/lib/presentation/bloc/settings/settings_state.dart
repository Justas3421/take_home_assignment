part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  final AppSettings settings;

  const SettingsState({required this.settings});

  factory SettingsState.initial() => const SettingsState(settings: AppSettings());

  SettingsState copyWith({AppSettings? settings}) {
    return SettingsState(settings: settings ?? this.settings);
  }

  @override
  List<Object> get props => [settings];
}
