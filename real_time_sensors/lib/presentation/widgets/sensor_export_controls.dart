import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/infrastructure/services/csv_export_service.dart';
import 'package:real_time_sensors/infrastructure/services/file_save_service.dart';
import 'package:real_time_sensors/infrastructure/services/screenshot_service.dart';
import 'package:real_time_sensors/presentation/bloc/sensor_bloc_base/sensor_bloc_base.dart';

class SensorExportControls extends StatelessWidget {
  final SensorType sensorType;
  final SensorBlocBase bloc;
  final ScreenshotService screenshotService;
  final CsvExportService csvExportService;
  final FileSaveService fileSaveService;
  final GlobalKey chartKey;

  const SensorExportControls({
    super.key,
    required this.sensorType,
    required this.bloc,
    required this.screenshotService,
    required this.csvExportService,
    required this.fileSaveService,
    required this.chartKey,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopupMenuButton<String>(
      child: Semantics(
        button: true,
        label: 'Export options',
        hint: 'Shows options to export the chart as an image or the data as a CSV file',
        child: OutlinedButton.icon(
          onPressed: null,
          icon: Icon(Icons.download_rounded, color: colorScheme.primary),
          label: Text('Export', style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            side: BorderSide(color: colorScheme.outline),
          ),
        ),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'capture',
          child: Row(
            children: [
              Icon(Icons.camera_alt_rounded, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text('Capture chart', style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'csv',
          child: Row(
            children: [
              Icon(Icons.description_rounded, color: colorScheme.primary),
              const SizedBox(width: 12),
              Text('Export as CSV', style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
      onSelected: (String value) async {
        if (value == 'capture') {
          final image = await screenshotService.captureWidget(chartKey);
          if (image != null) {
            final File? file = await fileSaveService.saveImage(
              image,
              fileName: '${sensorType.name}_screenshot_${DateTime.now().millisecondsSinceEpoch}',
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    file == null ? 'Failed to save screenshot.' : 'Screenshot saved!',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
                  ),
                  backgroundColor: colorScheme.inverseSurface,
                ),
              );
            }
          }
        } else if (value == 'csv') {
          final String? csvValue = await csvExportService.exportSensorData(bloc.state.history, sensorType.name);
          if (context.mounted) {
            if (csvValue == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'No data to export.',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
                  ),
                  backgroundColor: colorScheme.inverseSurface,
                ),
              );
              return;
            }
            final String? path = await fileSaveService.saveCsv(
              csvValue,
              fileName: '${sensorType.name}_data_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now())}',
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  path == null ? 'Failed to export data.' : 'Data exported to CSV!',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
                ),
                backgroundColor: colorScheme.inverseSurface,
              ),
            );
          }
        }
      },
    );
  }
}
