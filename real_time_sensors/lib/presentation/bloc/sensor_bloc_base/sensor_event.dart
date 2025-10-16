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

class StartSensorCapture extends SensorEvent {
  final bool clearHistory;
  final bool forceRestart;
  const StartSensorCapture({this.clearHistory = true, this.forceRestart = false});
}

class PauseSensorCapture extends SensorEvent {
  const PauseSensorCapture();
}

class ResumeSensorCapture extends SensorEvent {
  const ResumeSensorCapture();
}

class ResetSensorCapture extends SensorEvent {
  const ResetSensorCapture();
}

class AppLifecycleChanged extends SensorEvent {
  final AppLifecycleState state;
  const AppLifecycleChanged(this.state);

  @override
  List<Object?> get props => [state];
}
