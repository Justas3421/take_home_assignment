import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_sensors/domain/repositories/device_sensor_repository_impl.dart';
import 'package:sensors_plus_platform_interface/sensors_plus_platform_interface.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';

class FakeSensorsPlatform extends SensorsPlatform {
  Stream<UserAccelerometerEvent>? userAccelerometerStream;
  Stream<GyroscopeEvent>? gyroscopeStream;

  @override
  Stream<UserAccelerometerEvent> userAccelerometerEventStream({
    Duration samplingPeriod = SensorInterval.normalInterval,
  }) {
    return userAccelerometerStream ?? const Stream.empty();
  }

  @override
  Stream<GyroscopeEvent> gyroscopeEventStream({Duration samplingPeriod = SensorInterval.normalInterval}) {
    return gyroscopeStream ?? const Stream.empty();
  }
}

void main() {
  late FakeSensorsPlatform fakePlatform;
  late DeviceSensorRepositoryImpl repository;

  setUp(() {
    fakePlatform = FakeSensorsPlatform();

    SensorsPlatform.instance = fakePlatform;

    repository = DeviceSensorRepositoryImpl();
  });

  tearDown(() {
    SensorsPlatform.instance = fakePlatform;
  });

  group('DeviceSensorRepositoryImpl', () {
    group('getSensorStream', () {
      test('maps accelerometer events to SensorDataPoint correctly', () async {
        final DateTime fixedTime = DateTime.fromMillisecondsSinceEpoch(123456789);
        final fakeEvent = UserAccelerometerEvent(1.0, 2.0, 3.0, fixedTime);
        fakePlatform.userAccelerometerStream = Stream.value(fakeEvent);

        final result = await repository.getSensorStream(SensorType.accelerometer).first;

        expect(result.x, 1.0);
        expect(result.y, 2.0);
        expect(result.z, 3.0);
        expect(result.timestamp, fixedTime);
      });

      test('maps gyroscope events to SensorDataPoint correctly', () async {
        final DateTime fixedTime = DateTime.fromMillisecondsSinceEpoch(888888);
        final fakeEvent = GyroscopeEvent(0.5, -0.5, 1.2, fixedTime);
        fakePlatform.gyroscopeStream = Stream.value(fakeEvent);

        final result = await repository.getSensorStream(SensorType.gyroscope).first;

        expect(result.x, 0.5);
        expect(result.y, -0.5);
        expect(result.z, 1.2);
        expect(result.timestamp, fixedTime);
      });
    });
  });
}
