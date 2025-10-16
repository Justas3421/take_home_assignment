import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/presentation/bloc/sensor_bloc_base/sensor_bloc_base.dart';

class SensorChartHeader extends StatelessWidget {
  final TransformationController transformationController;
  final SensorBlocBase bloc;
  final SensorType sensorType;
  const SensorChartHeader({
    super.key,
    required this.transformationController,
    required this.bloc,
    required this.sensorType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              sensorType.name,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          BlocBuilder<SensorBlocBase, SensorState>(
            bloc: bloc,
            builder: (context, state) {
              if (state.isCapturing) {
                return const SizedBox();
              } else {
                return Row(
                  children: [
                    Tooltip(
                      message: 'Reset Zoom',
                      child: Semantics(
                        button: true,
                        label: 'Reset zoom',
                        hint: 'Resets chart zoom and pan',
                        child: IconButton(
                          icon: Icon(Icons.zoom_out_map_rounded, color: colorScheme.onSurfaceVariant),
                          onPressed: _resetZoom,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Zoom In',
                      child: Semantics(
                        button: true,
                        label: 'Zoom in',
                        hint: 'Increases chart zoom level',
                        child: IconButton(
                          icon: Icon(Icons.zoom_in_rounded, color: colorScheme.onSurfaceVariant),
                          onPressed: _zoomIn,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Zoom Out',
                      child: Semantics(
                        button: true,
                        label: 'Zoom out',
                        hint: 'Decreases chart zoom level',
                        child: IconButton(
                          icon: Icon(Icons.zoom_out_rounded, color: colorScheme.onSurfaceVariant),
                          onPressed: _zoomOut,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _resetZoom() => transformationController.value = Matrix4.identity();
  void _zoomIn() => transformationController.value *= Matrix4.diagonal3Values(1.1, 1.1, 1);
  void _zoomOut() => transformationController.value *= Matrix4.diagonal3Values(0.9, 0.9, 1);
}
