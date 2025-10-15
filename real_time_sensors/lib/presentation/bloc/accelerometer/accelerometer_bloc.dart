import 'package:real_time_sensors/domain/models/sensor_data.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/presentation/bloc/sensor_bloc_base/sensor_bloc_base.dart';

part 'accelerometer_event.dart';
part 'accelerometer_state.dart';

class AccelerometerBloc extends SensorBlocBase<AccelerometerEvent, AccelerometerState> {
  AccelerometerBloc({required super.startSensorStreamUseCase, required super.settingsBloc})
    : super(sensorType: SensorType.accelerometer, initialState: const AccelerometerState());

  @override
  AccelerometerState copyWith({
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
