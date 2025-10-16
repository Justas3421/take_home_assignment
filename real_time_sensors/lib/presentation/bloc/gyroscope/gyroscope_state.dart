part of 'gyroscope_bloc.dart';

class GyroscopeState extends SensorState {
  const GyroscopeState({
    super.isCapturing = false,
    super.history = const [],
    super.errorMessage,
  });

  @override
  List<Object?> get props => [isCapturing, history, errorMessage];
  
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
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
