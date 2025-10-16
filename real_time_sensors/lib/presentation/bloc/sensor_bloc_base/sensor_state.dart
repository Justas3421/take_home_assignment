part of 'sensor_bloc_base.dart';

abstract class SensorState extends Equatable {
  final bool isCapturing;
  final List<SensorDataPoint> history;
  final String? errorMessage;

  const SensorState({
    required this.isCapturing,
    required this.history,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isCapturing, history, errorMessage];

  SensorState copyWith({
    bool? isCapturing,
    List<SensorDataPoint>? history,
    String? errorMessage,
  });
}
