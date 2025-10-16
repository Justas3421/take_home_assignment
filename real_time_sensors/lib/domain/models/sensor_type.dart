enum SensorType { accelerometer, gyroscope }

extension SensorTypeExtension on SensorType {
  String get name {
    switch (this) {
      case SensorType.accelerometer:
        return 'Accelerometer';
      case SensorType.gyroscope:
        return 'Gyroscope';
    }
  }

  String get unit {
    switch (this) {
      case SensorType.accelerometer:
        return 'm/s²';
      case SensorType.gyroscope:
        return 'rad/s';
    }
  }
}
