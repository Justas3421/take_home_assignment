part of 'gyroscope_bloc.dart';

class GyroscopeState extends SensorState {
  const GyroscopeState({
    super.isCapturing = false,
    super.history = const [],
    super.sensorAvailable = false,
    super.errorMessage,
  });

  @override
  List<Object?> get props => [isCapturing, history, sensorAvailable, errorMessage];
  
  @override
  GyroscopeState copyWith({
    bool? isCapturing,
    List<SensorDataPoint>? history,
    String? errorMessage,
    bool? sensorAvailable,
  }) {
    return GyroscopeState(
      isCapturing: isCapturing ?? this.isCapturing,
      history: history ?? this.history,
      sensorAvailable: sensorAvailable ?? this.sensorAvailable,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
