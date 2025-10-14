part of 'sensor_bloc_base.dart';

abstract class SensorEvent extends Equatable {
  const SensorEvent();
  @override
  List<Object?> get props => [];
}

class _SensorDataReceived extends SensorEvent {
  final SensorDataPoint dataPoint;
  const _SensorDataReceived(this.dataPoint);

  @override
  List<Object?> get props => [dataPoint];
}

class _SensorErrorOccurred extends SensorEvent {
  final String message;
  const _SensorErrorOccurred(this.message);

  @override
  List<Object?> get props => [message];
}

class _SensorAvailabilityChecked extends SensorEvent {
  final bool available;
  const _SensorAvailabilityChecked(this.available);

  @override
  List<Object?> get props => [available];
}

class StartSensorCapture extends SensorEvent {}

class PauseSensorCapture extends SensorEvent {}

class ResumeSensorCapture extends SensorEvent {}

class ResetSensorCapture extends SensorEvent {}

class AppLifecycleChanged extends SensorEvent {
  final AppLifecycleState state;
  const AppLifecycleChanged(this.state);

  @override
  List<Object?> get props => [state];
}
