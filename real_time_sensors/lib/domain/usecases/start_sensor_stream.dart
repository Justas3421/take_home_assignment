import 'package:real_time_sensors/domain/models/sensor_data.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/domain/repositories/sensor_repository.dart';

class StartSensorStreamUseCase {
  final SensorRepository _repository;

  StartSensorStreamUseCase(this._repository);

  Stream<SensorDataPoint> call(SensorType type) {
    return _repository.getSensorStream(type);
  }

  Future<bool> isAvailable(SensorType type) {
    return _repository.isSensorAvailable(type);
  }
}
