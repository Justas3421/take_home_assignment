part of 'accelerometer_bloc.dart';

class AccelerometerState extends SensorState {
  const AccelerometerState({
    super.isCapturing = false,
    super.history = const [],
    super.errorMessage,
  });

  @override
  List<Object?> get props => [isCapturing, history, errorMessage];

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
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
