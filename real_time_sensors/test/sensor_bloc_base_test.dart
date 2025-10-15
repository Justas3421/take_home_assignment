import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_time_sensors/domain/models/app_settings.dart';
import 'package:real_time_sensors/domain/models/sensor_data.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/domain/usecases/start_sensor_stream.dart';
import 'package:real_time_sensors/presentation/bloc/sensor_bloc_base/sensor_bloc_base.dart';
import 'package:real_time_sensors/presentation/bloc/settings/settings_bloc.dart';

class TestSensorState extends SensorState {
  const TestSensorState({
    required super.isCapturing,
    required super.history,
    super.errorMessage,
    required super.sensorAvailable,
  });

  @override
  TestSensorState copyWith({
    bool? isCapturing,
    List<SensorDataPoint>? history,
    String? errorMessage,
    bool? sensorAvailable,
  }) {
    return TestSensorState(
      isCapturing: isCapturing ?? this.isCapturing,
      history: history ?? this.history,
      errorMessage: errorMessage ?? this.errorMessage,
      sensorAvailable: sensorAvailable ?? this.sensorAvailable,
    );
  }
}

class TestSensorBloc extends SensorBlocBase<SensorEvent, TestSensorState> {
  TestSensorBloc({required super.startSensorStreamUseCase, required super.settingsBloc})
    : super(
        sensorType: SensorType.accelerometer,
        initialState: const TestSensorState(isCapturing: false, history: [], sensorAvailable: false),
      );

  @override
  TestSensorState copyWith({
    bool? isCapturing,
    List<SensorDataPoint>? history,
    String? errorMessage,
    bool? sensorAvailable,
  }) {
    return state.copyWith(
      isCapturing: isCapturing,
      history: history,
      errorMessage: errorMessage,
      sensorAvailable: sensorAvailable,
    );
  }
}


class MockStartSensorStreamUseCase extends Mock implements StartSensorStreamUseCase {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState> implements SettingsBloc {}

class MockSettingsState extends Mock implements SettingsState {}

class MockSettings extends Mock implements AppSettings {}

void main() {
  setUpAll(() {
    registerFallbackValue(SensorType.accelerometer);
  });

  group('SensorBlocBase Tests', () {
    late MockStartSensorStreamUseCase mockStartSensorStreamUseCase;
    late MockSettingsBloc mockSettingsBloc;
    late MockSettingsState mockSettingsState;
    late MockSettings mockSettings;

    late StreamController<SensorDataPoint> sensorDataController;

    setUp(() {
      mockStartSensorStreamUseCase = MockStartSensorStreamUseCase();
      mockSettingsBloc = MockSettingsBloc();
      mockSettingsState = MockSettingsState();
      mockSettings = MockSettings();
      sensorDataController = StreamController<SensorDataPoint>();

      when(() => mockSettingsBloc.stream).thenAnswer((_) => const Stream.empty());

      when(() => mockSettingsBloc.close()).thenAnswer((_) async {});

      when(() => mockSettings.refreshRateHz).thenReturn(10);
      when(() => mockSettings.historySize).thenReturn(100);
      when(() => mockSettingsState.settings).thenReturn(mockSettings);
      when(() => mockSettingsBloc.state).thenReturn(mockSettingsState);

      when(() => mockStartSensorStreamUseCase.call(any())).thenAnswer((_) => sensorDataController.stream);
    });

    tearDown(() {
      sensorDataController.close();
      mockSettingsBloc.close();
    });

    const initialState = TestSensorState(isCapturing: false, history: [], sensorAvailable: false);

    test('initial state is correct', () {
      when(() => mockStartSensorStreamUseCase.isAvailable(any())).thenAnswer((_) async => false);

      expect(
        TestSensorBloc(startSensorStreamUseCase: mockStartSensorStreamUseCase, settingsBloc: mockSettingsBloc).state,
        initialState,
      );
    });

    blocTest<TestSensorBloc, TestSensorState>(
      'emits [sensorAvailable: true] when sensor is available on initialization',
      setUp: () {
        when(() => mockStartSensorStreamUseCase.isAvailable(any())).thenAnswer((_) async => true);
      },
      build: () =>
          TestSensorBloc(startSensorStreamUseCase: mockStartSensorStreamUseCase, settingsBloc: mockSettingsBloc),
      expect: () => [initialState.copyWith(sensorAvailable: true)],
    );

    blocTest<TestSensorBloc, TestSensorState>(
      'emits [sensorAvailable: false, errorMessage] when sensor is unavailable on initialization',
      setUp: () {
        when(() => mockStartSensorStreamUseCase.isAvailable(any())).thenAnswer((_) async => false);
      },
      build: () =>
          TestSensorBloc(startSensorStreamUseCase: mockStartSensorStreamUseCase, settingsBloc: mockSettingsBloc),
      expect: () => [
        initialState.copyWith(
          sensorAvailable: false,
          isCapturing: false,
          errorMessage: 'Sensor not available on this device.',
        ),
      ],
    );

    group('StartSensorCapture Event', () {
      blocTest<TestSensorBloc, TestSensorState>(
        'starts capturing and receives data when sensor is available',
        setUp: () {
          when(() => mockStartSensorStreamUseCase.isAvailable(any())).thenAnswer((_) async => true);
        },
        build: () =>
            TestSensorBloc(startSensorStreamUseCase: mockStartSensorStreamUseCase, settingsBloc: mockSettingsBloc),
        act: (bloc) async {
          bloc.add(StartSensorCapture());
          await Future.delayed(Duration.zero);
          sensorDataController.add(SensorDataPoint(x: 1, y: 1, z: 1, timestamp: DateTime.now()));
        },
        expect: () => [
          initialState.copyWith(sensorAvailable: true),
          initialState.copyWith(sensorAvailable: true, isCapturing: true),
          initialState.copyWith(
            sensorAvailable: true,
            isCapturing: true,
            history: [SensorDataPoint(x: 1, y: 1, z: 1, timestamp: DateTime.now())],
          ),
        ],
      );
    });

    group('Lifecycle: Pause and Resume', () {
      blocTest<TestSensorBloc, TestSensorState>(
        'pauses and resumes data capture correctly',
        setUp: () {
          when(() => mockStartSensorStreamUseCase.isAvailable(any())).thenAnswer((_) async => true);
        },
        build: () =>
            TestSensorBloc(startSensorStreamUseCase: mockStartSensorStreamUseCase, settingsBloc: mockSettingsBloc),
        act: (bloc) => bloc
          ..add(StartSensorCapture())
          ..add(PauseSensorCapture())
          ..add(ResumeSensorCapture()),
        skip: 1, // Skip initial state from availability check.
        expect: () => [
          initialState.copyWith(sensorAvailable: true, isCapturing: true),
          initialState.copyWith(sensorAvailable: true, isCapturing: false),
          initialState.copyWith(sensorAvailable: true, isCapturing: true),
        ],
      );
    });

    group('Error Handling', () {
      blocTest<TestSensorBloc, TestSensorState>(
        'emits error state when sensor stream produces an error',
        setUp: () {
          when(() => mockStartSensorStreamUseCase.isAvailable(any())).thenAnswer((_) async => true);
        },
        build: () =>
            TestSensorBloc(startSensorStreamUseCase: mockStartSensorStreamUseCase, settingsBloc: mockSettingsBloc),
        act: (bloc) async {
          bloc.add(StartSensorCapture());
          await Future.delayed(Duration.zero);
          sensorDataController.addError('Sensor hardware failure');
        },
        skip: 2,
        expect: () => [
          isA<TestSensorState>()
              .having((s) => s.isCapturing, 'isCapturing', false)
              .having((s) => s.errorMessage, 'errorMessage', 'Sensor hardware failure'),
        ],
      );
    });

    group('App Lifecycle', () {
      blocTest<TestSensorBloc, TestSensorState>(
        'pauses stream on app pause and resumes on app resume',
        setUp: () {
          when(() => mockStartSensorStreamUseCase.isAvailable(any())).thenAnswer((_) async => true);
        },
        build: () =>
            TestSensorBloc(startSensorStreamUseCase: mockStartSensorStreamUseCase, settingsBloc: mockSettingsBloc),
        act: (bloc) async {
          bloc.add(StartSensorCapture());
          await Future.delayed(Duration.zero);
          bloc.add(const AppLifecycleChanged(AppLifecycleState.paused));
          await Future.delayed(Duration.zero);
          bloc.add(const AppLifecycleChanged(AppLifecycleState.resumed));
        },
        expect: () => [
          initialState.copyWith(sensorAvailable: true),
          initialState.copyWith(sensorAvailable: true, isCapturing: true),
        ],
        verify: (_) {
          verify(() => mockStartSensorStreamUseCase(any())).called(2);
        },
      );
    });
  });
}
