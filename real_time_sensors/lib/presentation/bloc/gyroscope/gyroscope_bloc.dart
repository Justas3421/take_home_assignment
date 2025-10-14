import 'package:real_time_sensors/domain/models/sensor_data.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/presentation/bloc/sensor_bloc_base/sensor_bloc_base.dart';

part 'gyroscope_event.dart';
part 'gyroscope_state.dart';

class GyroscopeBloc extends SensorBlocBase<SensorEvent, GyroscopeState> {
  GyroscopeBloc({required super.startSensorStreamUseCase, required super.settingsBloc})
    : super(sensorType: SensorType.gyroscope, initialState: const GyroscopeState(sensorAvailable: true));

  @override
  GyroscopeState copyWith({
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
