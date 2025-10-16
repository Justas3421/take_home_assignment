import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:real_time_sensors/domain/models/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:real_time_sensors/domain/models/sensor_data.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/domain/usecases/start_sensor_stream.dart';
import 'package:real_time_sensors/presentation/bloc/sensor_bloc_base/sensor_bloc_base.dart';
import 'package:real_time_sensors/presentation/bloc/settings/settings_bloc.dart';

class MockStartSensorStreamUseCase extends Mock implements StartSensorStreamUseCase {}

class MockSettingsBloc extends Mock implements SettingsBloc {}

class MockStreamSubscription<T> extends Mock implements StreamSubscription<T> {}

class MockSensorStream extends Mock implements Stream<SensorDataPoint> {}

class TestSensorState extends SensorState {
  const TestSensorState({required super.isCapturing, required super.history, super.errorMessage});

  @override
  List<Object?> get props => [...super.props];

  @override
  SensorState copyWith({bool? isCapturing, List<SensorDataPoint>? history, String? errorMessage}) {
    return TestSensorState(
      isCapturing: isCapturing ?? this.isCapturing,
      history: history ?? this.history,
      errorMessage: errorMessage,
    );
  }
}

class TestSensorBloc extends SensorBlocBase<SensorEvent, TestSensorState> {
  TestSensorBloc({
    required super.startSensorStreamUseCase,
    required super.settingsBloc,
    required super.sensorType,
  }) : super(
         initialState: const TestSensorState(isCapturing: false, history: []),
       );

  @override
  TestSensorState copyWith({
    bool? isCapturing,
    List<SensorDataPoint>? history,
    String? errorMessage,
    bool? sensorAvailable,
  }) {
    return TestSensorState(
      isCapturing: isCapturing ?? state.isCapturing,
      history: history ?? state.history,
      errorMessage: errorMessage ?? state.errorMessage,
    );
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(SensorType.accelerometer);
  });

  group('SensorBlocBase', () {
    late MockStartSensorStreamUseCase mockUseCase;
    late MockSettingsBloc mockSettingsBloc;
    late StreamController<SensorDataPoint> sensorStreamController;
    late StreamController<SettingsState> settingsStreamController;
    late MockSensorStream mockSensorStream;
    late MockStreamSubscription<SensorDataPoint> mockSensorSubscription;
    const testSensorType = SensorType.accelerometer;
    final testDataPoint = SensorDataPoint(timestamp: DateTime.now(), x: 1, y: 1, z: 1);
    const initialSettings = AppSettings(refreshRateHz: 10);

    setUp(() {
      mockUseCase = MockStartSensorStreamUseCase();
      mockSettingsBloc = MockSettingsBloc();
      sensorStreamController = StreamController<SensorDataPoint>.broadcast();
      settingsStreamController = StreamController<SettingsState>.broadcast();
      mockSensorStream = MockSensorStream();
      mockSensorSubscription = MockStreamSubscription<SensorDataPoint>();

      when(() => mockSettingsBloc.state).thenReturn(const SettingsState(settings: initialSettings));
      when(() => mockSettingsBloc.stream).thenAnswer((_) => settingsStreamController.stream);
      when(() => mockUseCase.isAvailable(any())).thenAnswer((_) async => true);
      when(() => mockUseCase.isAvailable(any())).thenAnswer((_) async => true);

      when(() => mockUseCase.call(any())).thenAnswer((_) => mockSensorStream);

      when(
        () => mockSensorStream.listen(
          any(),
          onError: any(named: 'onError'),
          onDone: any(named: 'onDone'),
          cancelOnError: any(named: 'cancelOnError'),
        ),
      ).thenAnswer((invocation) => mockSensorSubscription);
      when(
        () => mockSensorStream.listen(
          any(),
          onError: any(named: 'onError'),
          onDone: any(named: 'onDone'),
          cancelOnError: any(named: 'cancelOnError'),
        ),
      ).thenAnswer((_) => mockSensorSubscription);

      when(() => mockUseCase.call(any())).thenAnswer((_) => sensorStreamController.stream);
    });

    tearDown(() {
      sensorStreamController.close();
      settingsStreamController.close();
    });

    TestSensorBloc buildBloc() {
      return TestSensorBloc(
        startSensorStreamUseCase: mockUseCase,
        settingsBloc: mockSettingsBloc,
        sensorType: testSensorType,
      );
    }

    test('initial state is correct', () {
      expect(buildBloc().state, const TestSensorState(isCapturing: false, history: []));
    });

    group('General Behavior Tests', () {
      blocTest<TestSensorBloc, TestSensorState>(
        'emits [capturing, data] when sensor is available and data is received',
        build: buildBloc,
        act: (bloc) async {
          bloc.add(const StartSensorCapture());

          await bloc.stream.firstWhere((s) => s.isCapturing == true);

          sensorStreamController.add(testDataPoint);
        },
        skip: 1,
        wait: const Duration(milliseconds: 500),
        expect: () => [
          const TestSensorState(isCapturing: true, history: []),
          TestSensorState(isCapturing: true, history: [testDataPoint]),
        ],
        verify: (_) {
          verify(() => mockUseCase.isAvailable(testSensorType)).called(1);
          verify(() => mockUseCase.call(testSensorType)).called(1);
        },
      );

      blocTest<TestSensorBloc, TestSensorState>(
        'emits [error message] when sensor is not available',
        build: () {
          when(() => mockUseCase.isAvailable(any())).thenAnswer((_) async => false);
          return buildBloc();
        },
        act: (bloc) => bloc.add(const StartSensorCapture()),
        expect: () => [
          const TestSensorState(isCapturing: false, history: []),
          const TestSensorState(
            isCapturing: false,
            history: [],
            errorMessage: 'Sensor not available on this device.',
          ),
        ],
        verify: (_) {
          verifyNever(() => mockUseCase.call(any()));
        },
      );

      blocTest<TestSensorBloc, TestSensorState>(
        'emits error and stops capturing on stream error',
        build: () {
          when(() => mockUseCase.call(any())).thenAnswer((_) => sensorStreamController.stream);
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(const StartSensorCapture());
          await bloc.stream.firstWhere((s) => s.isCapturing);
          sensorStreamController.addError('boom');
        },
        skip: 1,
        expect: () => [
          const TestSensorState(isCapturing: true, history: []),
          const TestSensorState(isCapturing: false, history: [], errorMessage: 'boom'),
        ],
      );

      blocTest<TestSensorBloc, TestSensorState>(
        'pauses when stream completes',
        build: () {
          when(() => mockUseCase.call(any())).thenAnswer((_) => sensorStreamController.stream);
          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(const StartSensorCapture());
          await bloc.stream.firstWhere((s) => s.isCapturing);
          await sensorStreamController.close();
        },
        skip: 1,
        expect: () => [
          const TestSensorState(isCapturing: true, history: []),
          const TestSensorState(isCapturing: false, history: []),
        ],
      );

      blocTest<TestSensorBloc, TestSensorState>(
        'restarts stream when refreshRateHz changes',
        build: () {
          final s1 = MockSensorStream();
          final s2 = MockSensorStream();
          final sub1 = MockStreamSubscription<SensorDataPoint>();
          final sub2 = MockStreamSubscription<SensorDataPoint>();

          when(
            () => s1.listen(
              any(),
              onError: any(named: 'onError'),
              onDone: any(named: 'onDone'),
              cancelOnError: any(named: 'cancelOnError'),
            ),
          ).thenReturn(sub1);
          when(
            () => s2.listen(
              any(),
              onError: any(named: 'onError'),
              onDone: any(named: 'onDone'),
              cancelOnError: any(named: 'cancelOnError'),
            ),
          ).thenReturn(sub2);

          return buildBloc();
        },
        act: (bloc) async {
          bloc.add(const StartSensorCapture());
          await bloc.stream.firstWhere((s) => s.isCapturing);
          settingsStreamController.add(
            const SettingsState(settings: AppSettings(refreshRateHz: 20)),
          );
        },
        skip: 1,
        expect: () => [const TestSensorState(isCapturing: true, history: [])],
        verify: (_) {},
      );
    });

    group('Pause and Resume', () {
      blocTest<TestSensorBloc, TestSensorState>(
        'emits [not capturing] on PauseSensorCapture and pauses subscription',
        build: buildBloc,
        act: (bloc) async {
          bloc.add(const StartSensorCapture());
          await bloc.stream.firstWhere((s) => s.isCapturing == true);

          bloc.add(const PauseSensorCapture());
        },

        skip: 1,
        expect: () => [
          const TestSensorState(isCapturing: true, history: []),
          const TestSensorState(isCapturing: false, history: []),
        ],
        verify: (_) {
          verify(() => mockUseCase.isAvailable(testSensorType)).called(1);
          verify(() => mockUseCase.call(testSensorType)).called(1);
        },
      );
    });

    group('ResetSensorCapture', () {
      final initialHistory = [testDataPoint];
      blocTest<TestSensorBloc, TestSensorState>(
        'clears history and restarts the stream',
        build: buildBloc,
        seed: () => TestSensorState(isCapturing: true, history: initialHistory),
        act: (bloc) => bloc.add(const ResetSensorCapture()),
        expect: () => [const TestSensorState(isCapturing: true, history: [])],
        verify: (_) {
          verify(() => mockUseCase.isAvailable(testSensorType)).called(1);
          verify(() => mockUseCase.call(testSensorType)).called(1);
        },
      );
    });
  });
}
