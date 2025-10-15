import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/infrastructure/services/csv_export_service.dart';
import 'package:real_time_sensors/infrastructure/services/file_save_service.dart';
import 'package:real_time_sensors/infrastructure/services/screenshot_service.dart';
import 'package:real_time_sensors/presentation/bloc/sensor_bloc_base/sensor_bloc_base.dart';
import 'package:real_time_sensors/presentation/widgets/sensor_chart.dart';
import 'package:real_time_sensors/presentation/widgets/sensor_export_controls.dart';

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
      margin: const EdgeInsets.all(12),
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
                return LayoutBuilder(
                  builder: (context, asyncSnapshot) {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      alignment: WrapAlignment.center,
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
                          child: Icon(
                            state.isCapturing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 24,
                          ),
                        ),

                        OutlinedButton(
                          onPressed: () => bloc.add(ResetSensorCapture()),
                          style: OutlinedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            side: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          child: Icon(
                            Icons.refresh_rounded,
                            size: 24,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                        SensorExportControls(
                          sensorType: sensorType,
                          bloc: bloc,
                          screenshotService: screenshotService,
                          csvExportService: csvExportService,
                          fileSaveService: fileSaveService,
                          chartKey: _chartKey,
                        ),
                      ],
                    );
                  },
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
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
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
