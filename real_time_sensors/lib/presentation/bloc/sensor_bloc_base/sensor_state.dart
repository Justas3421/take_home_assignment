part of 'sensor_bloc_base.dart';

abstract class SensorState extends Equatable {
  final bool isCapturing;
  final List<SensorDataPoint> history;
  final String? errorMessage;
  final bool sensorAvailable;

  const SensorState({
    required this.isCapturing,
    required this.history,
    this.errorMessage,
    required this.sensorAvailable,
  });

  @override
  List<Object?> get props => [isCapturing, history, errorMessage, sensorAvailable];
}
