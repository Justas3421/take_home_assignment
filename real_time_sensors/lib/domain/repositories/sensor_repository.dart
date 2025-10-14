import 'dart:async';

import 'package:real_time_sensors/domain/models/sensor_data.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';

abstract class SensorRepository {
  Stream<SensorDataPoint> getSensorStream(SensorType type);

  Future<bool> isSensorAvailable(SensorType type);
}
