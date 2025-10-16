import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:real_time_sensors/domain/models/sensor_data.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/domain/repositories/sensor_repository.dart';
import 'package:sensors_plus/sensors_plus.dart';

class DeviceSensorRepositoryImpl implements SensorRepository {
  static const _channel = MethodChannel('com.example.real_time_sensors/sensor');

  @override
  Stream<SensorDataPoint> getSensorStream(SensorType type) {
    switch (type) {
      case SensorType.accelerometer:
        return SensorsPlatform.instance
            .userAccelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
            .map(
              (event) =>
                  SensorDataPoint(timestamp: event.timestamp, x: event.x, y: event.y, z: event.z),
            );
      case SensorType.gyroscope:
        return SensorsPlatform.instance
            .gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval)
            .map(
              (event) =>
                  SensorDataPoint(timestamp: event.timestamp, x: event.x, y: event.y, z: event.z),
            );
    }
  }

  @override
  Future<bool> isSensorAvailable(SensorType type) async {
    try {
      final result = await _channel.invokeMethod<bool>('isSensorAvailable', {'sensor': type.name});
      debugPrint('Sensor availability for ${type.name}: $result');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
