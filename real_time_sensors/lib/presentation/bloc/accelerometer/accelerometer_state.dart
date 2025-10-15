part of 'accelerometer_bloc.dart';

class AccelerometerState extends SensorState {
  const AccelerometerState({
    super.isCapturing = false,
    super.history = const [],
    super.sensorAvailable = false,
    super.errorMessage,
  });

  @override
  List<Object?> get props => [isCapturing, history, sensorAvailable, errorMessage];

  @override
  AccelerometerState copyWith({
    bool? isCapturing,
    List<SensorDataPoint>? history,
    String? errorMessage,
    bool? sensorAvailable,
  }) {
    return AccelerometerState(
      isCapturing: isCapturing ?? this.isCapturing,
      history: history ?? this.history,
      sensorAvailable: sensorAvailable ?? this.sensorAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
