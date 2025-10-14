import 'package:equatable/equatable.dart';

class SensorDataPoint extends Equatable {
  final DateTime timestamp;
  final double x;
  final double y;
  final double z;

  const SensorDataPoint({
    required this.timestamp,
    required this.x,
    required this.y,
    required this.z,
  });

  factory SensorDataPoint.fromList(List<double> values) {
    assert(values.length >= 3);
    return SensorDataPoint(
      timestamp: DateTime.now(),
      x: values[0],
      y: values[1],
      z: values[2],
    );
  }

  @override
  List<Object> get props => [timestamp, x, y, z];

  @override
  String toString() {
    return 'SensorDataPoint(timestamp: $timestamp, x: ${x.toStringAsFixed(2)}, y: ${y.toStringAsFixed(2)}, z: ${z.toStringAsFixed(2)})';
  }
}