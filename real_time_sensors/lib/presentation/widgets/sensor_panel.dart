import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/infrastructure/services/csv_export_service.dart';
import 'package:real_time_sensors/infrastructure/services/file_save_service.dart';
import 'package:real_time_sensors/infrastructure/services/screenshot_service.dart';
import 'package:real_time_sensors/presentation/bloc/sensor_bloc_base/sensor_bloc_base.dart';
import 'package:real_time_sensors/presentation/widgets/sensor_chart.dart';

class SensorPanel extends StatelessWidget {
  final SensorType sensorType;
  final SensorBlocBase bloc;
  final ScreenshotService screenshotService;
  final CsvExportService csvExportService;
  final FileSaveService fileSaveService;

  SensorPanel({
    super.key,
    required this.sensorType,
    required this.bloc,
    required this.screenshotService,
    required this.csvExportService,
    required this.fileSaveService,
  });

  final _chartKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: RepaintBoundary(
                key: _chartKey,
                child: SensorChart(sensorType: sensorType, bloc: bloc),
              ),
            ),
            const SizedBox(height: 20),

            BlocBuilder<SensorBlocBase, SensorState>(
              bloc: bloc,
              builder: (context, state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton.tonal(
                      onPressed: () {
                        if (state.isCapturing) {
                          bloc.add(PauseSensorCapture());
                        } else {
                          bloc.add(ResumeSensorCapture());
                        }
                      },
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: state.isCapturing
                            ? colorScheme.tertiaryContainer
                            : colorScheme.primaryContainer,
                        foregroundColor: state.isCapturing
                            ? colorScheme.onTertiaryContainer
                            : colorScheme.onPrimaryContainer,
                      ),
                      child: Icon(state.isCapturing ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 32),
                    ),

                    const SizedBox(width: 16),

                    OutlinedButton(
                      onPressed: () => bloc.add(ResetSensorCapture()),
                      style: OutlinedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        side: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      child: Icon(Icons.refresh_rounded, size: 28, color: colorScheme.onSurfaceVariant),
                    ),

                    const SizedBox(width: 12),
                    VerticalDivider(color: colorScheme.outlineVariant, thickness: 1, width: 1, indent: 8, endIndent: 8),
                    const SizedBox(width: 12),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () async {
                            final image = await screenshotService.captureWidget(_chartKey);
                            if (image != null) {
                              final File? file = await fileSaveService.saveImage(
                                image,
                                fileName: '${sensorType.name}_screenshot_${DateTime.now().millisecondsSinceEpoch}',
                              );
                              if (context.mounted) {
                                if (file == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to save screenshot.',
                                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
                                      ),
                                      backgroundColor: colorScheme.inverseSurface,
                                    ),
                                  );
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Screenshot saved!',
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
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
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
                            'Export data to CSV',
                            style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            BlocBuilder<SensorBlocBase, SensorState>(
              bloc: bloc,
              builder: (context, state) {
                if (state.errorMessage != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      state.errorMessage!,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.error, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
