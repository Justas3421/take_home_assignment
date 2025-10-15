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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: () async {
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
          },
          icon: Icon(Icons.camera_alt_rounded, color: colorScheme.primary),
          label: Text(
            'Capture chart',
            style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            side: BorderSide(color: colorScheme.outline),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () async {
            final String? csvValue = await csvExportService.exportSensorData(
              bloc.state.history,
              sensorType.name,
            );

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

              await fileSaveService.saveCsv(
                csvValue,
                fileName:
                    '${sensorType.name}_data_${DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now())}',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Data exported to CSV!',
                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
                  ),
                  backgroundColor: colorScheme.inverseSurface,
                ),
              );
            }
          },
          icon: Icon(Icons.download_rounded, color: colorScheme.primary),
          label: Text(
            'Export as CSV',
            style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            side: BorderSide(color: colorScheme.outline),
          ),
        ),
      ],
    );
  }
}
