import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_sensors/domain/models/sensor_data.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/domain/usecases/start_sensor_stream.dart';
import 'package:real_time_sensors/presentation/bloc/settings/settings_bloc.dart';
import 'package:rxdart/rxdart.dart';

part 'sensor_event.dart';
part 'sensor_state.dart';

abstract class SensorBlocBase<E extends SensorEvent, S extends SensorState> extends Bloc<SensorEvent, S> {
  final StartSensorStreamUseCase _startSensorStreamUseCase;
  final SettingsBloc _settingsBloc;
  final SensorType _sensorType;

  StreamSubscription<SensorDataPoint>? _sensorSubscription;
  StreamSubscription? _settingsSubscription;

  final List<SensorDataPoint> _historyBuffer = [];

  SensorBlocBase({
    required StartSensorStreamUseCase startSensorStreamUseCase,
    required SettingsBloc settingsBloc,
    required SensorType sensorType,
    required S initialState,
  }) : _startSensorStreamUseCase = startSensorStreamUseCase,
       _settingsBloc = settingsBloc,
       _sensorType = sensorType,
       super(initialState) {
    on<StartSensorCapture>(_onStartSensorCapture);
    on<PauseSensorCapture>(_onPauseSensorCapture);
    on<ResumeSensorCapture>(_onResumeSensorCapture);
    on<ResetSensorCapture>(_onResetSensorCapture);
    on<_SensorDataReceived>(_onSensorDataReceived);
    on<_SensorErrorOccurred>(_onSensorErrorOccurred);
    on<_SensorAvailabilityChecked>(_onSensorAvailabilityChecked);
    on<AppLifecycleChanged>(_onAppLifecycleChanged);

    _settingsSubscription = _settingsBloc.stream
        .map((s) => s.settings.refreshRateHz)
        .distinct((prev, next) => prev == next)
        .listen((refreshRateHz) {
          debugPrint('${_sensorType.name} BLoC: Refresh rate changed → $refreshRateHz Hz');
          _restartSensorStream();
        });

    _checkSensorAvailability();
  }

  Future<void> _onStartSensorCapture(StartSensorCapture event, Emitter<S> emit) async {
    if (state.isCapturing) return;

    if (!state.sensorAvailable) {
      emit(copyWith(isCapturing: false, errorMessage: 'Sensor not available on this device.'));
      return;
    }

    _historyBuffer.clear();
    emit(copyWith(isCapturing: true));
    _startListeningToSensor();
  }

  void _onPauseSensorCapture(PauseSensorCapture event, Emitter<S> emit) {
    if (!state.isCapturing) return;
    _sensorSubscription?.pause();
    emit(copyWith(isCapturing: false));
  }

  void _onResumeSensorCapture(ResumeSensorCapture event, Emitter<S> emit) {
    if (state.isCapturing) return;
    if (!state.sensorAvailable) {
      emit(copyWith(isCapturing: false, errorMessage: 'Sensor not available on this device.'));
      return;
    }
    _sensorSubscription?.resume();
    emit(copyWith(isCapturing: true));
  }

  void _onSensorDataReceived(_SensorDataReceived event, Emitter<S> emit) {
    final maxHistory = _effectiveMaxHistory;
    _historyBuffer.add(event.dataPoint);
    if (_historyBuffer.length > maxHistory) {
      _historyBuffer.removeRange(0, _historyBuffer.length - maxHistory);
    }

    emit(copyWith(history: List.unmodifiable(_historyBuffer)));
  }

  void _onSensorErrorOccurred(_SensorErrorOccurred event, Emitter<S> emit) {
    _sensorSubscription?.cancel();
    emit(copyWith(isCapturing: false, errorMessage: event.message));
  }

  void _onSensorAvailabilityChecked(_SensorAvailabilityChecked event, Emitter<S> emit) {
    emit(copyWith(sensorAvailable: event.available));
    if (!event.available) {
      emit(copyWith(isCapturing: false, errorMessage: 'Sensor not available on this device.'));
    }
  }

  void _onAppLifecycleChanged(AppLifecycleChanged event, Emitter<S> emit) {
    debugPrint('${_sensorType.name} lifecycle -> ${event.state}');
    if (event.state == AppLifecycleState.paused) {
      debugPrint('Pausing $_sensorType stream due to app lifecycle change.');
      _sensorSubscription?.cancel();
      _sensorSubscription = null;
    } else if (event.state == AppLifecycleState.resumed) {
      debugPrint('Resuming $_sensorType stream due to app lifecycle change.');
      _startListeningToSensor();
    }
  }

  void _startListeningToSensor() {
    _sensorSubscription?.cancel();
    final refreshHz = _settingsBloc.state.settings.refreshRateHz;
    final intervalMs = (refreshHz > 0) ? (1000 / refreshHz).round() : 100;
    _sensorSubscription = _startSensorStreamUseCase(_sensorType)
        .sampleTime(Duration(milliseconds: intervalMs))
        .listen(
          (data) => add(_SensorDataReceived(data)),
          onError: (error, _) => add(_SensorErrorOccurred(error.toString())),
          onDone: () => add(PauseSensorCapture()),
        );
    debugPrint('${_sensorType.name} stream started @ $intervalMs ms interval.');
  }

  void _restartSensorStream() {
    _sensorSubscription?.cancel();
    _sensorSubscription = null;
    add(ResetSensorCapture());
  }

  void _onResetSensorCapture(ResetSensorCapture event, Emitter<S> emit) {
    if (!state.sensorAvailable) {
      emit(copyWith(isCapturing: false, errorMessage: 'Sensor not available on this device.'));
      return;
    }
    _historyBuffer.clear();
    emit(copyWith(isCapturing: true, history: []));
    _startListeningToSensor();
  }

  Future<void> _checkSensorAvailability() async {
    try {
      final available = await _startSensorStreamUseCase.isAvailable(_sensorType);
      add(_SensorAvailabilityChecked(available));
    } catch (_) {
      add(const _SensorAvailabilityChecked(false));
    }
  }

  int get _effectiveMaxHistory {
    final configured = _settingsBloc.state.settings.historySize;
    if (configured > 0) return configured;
    return 300;
  }

  @override
  Future<void> close() async {
    await _sensorSubscription?.cancel();
    await _settingsSubscription?.cancel();
    debugPrint('${_sensorType.name} BLoC closed.');
    return super.close();
  }

  S copyWith({bool? isCapturing, List<SensorDataPoint>? history, String? errorMessage, bool? sensorAvailable});
}
