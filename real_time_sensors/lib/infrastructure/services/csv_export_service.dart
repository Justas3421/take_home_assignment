import 'package:csv/csv.dart';
import 'package:real_time_sensors/domain/models/sensor_data.dart';

class CsvExportService {
  Future<String?> exportSensorData(List<SensorDataPoint> data, String sensorTypeName) async {
    try {
      final rows = [
        ['timestamp', 'x', 'y', 'z'],
        ...data.map((d) => [d.timestamp, d.x, d.y, d.z]),
      ];

      final String csv = const ListToCsvConverter().convert(rows);
      return csv;
    } catch (e) {
      return null;
    }
  }
}
