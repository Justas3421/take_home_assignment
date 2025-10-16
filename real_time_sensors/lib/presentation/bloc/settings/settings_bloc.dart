import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:real_time_sensors/domain/models/app_settings.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsState.initial()) {
    on<UpdateRefreshRate>((event, emit) {
      emit(state.copyWith(settings: state.settings.copyWith(refreshRateHz: event.refreshRateHz)));
    });

    on<ToggleAxisVisibility>((event, emit) {
      AppSettings updatedSettings = state.settings;
      if (event.axis == 'x') {
        updatedSettings = updatedSettings.copyWith(showXAxis: event.isVisible);
      } else if (event.axis == 'y') {
        updatedSettings = updatedSettings.copyWith(showYAxis: event.isVisible);
      } else if (event.axis == 'z') {
        updatedSettings = updatedSettings.copyWith(showZAxis: event.isVisible);
      }
      emit(state.copyWith(settings: updatedSettings));
    });

    on<UpdateThemeMode>((event, emit) {
      emit(state.copyWith(settings: state.settings.copyWith(isDarkMode: event.isDarkMode)));
    });

    on<UpdateHistorySize>((event, emit) {
      emit(state.copyWith(settings: state.settings.copyWith(historySize: event.historySize)));
    });
  }
}
