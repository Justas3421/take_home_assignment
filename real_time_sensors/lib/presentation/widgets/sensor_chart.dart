import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_sensors/config/app_theme.dart';
import 'package:real_time_sensors/domain/models/sensor_data.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/presentation/bloc/sensor_bloc_base/sensor_bloc_base.dart';
import 'package:real_time_sensors/presentation/bloc/settings/settings_bloc.dart';

class SensorChart extends StatefulWidget {
  final SensorBlocBase bloc;
  final SensorType sensorType;

  const SensorChart({super.key, required this.bloc, required this.sensorType});

  @override
  State<SensorChart> createState() => _SensorChartState();
}

class _SensorChartState extends State<SensorChart> {
  late final TransformationController _transformationController;

  @override
  void initState() {
    _transformationController = TransformationController();
    super.initState();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final chartColors = theme.extension<ChartColors>()!;

    return BlocBuilder<SensorBlocBase, SensorState>(
      bloc: widget.bloc,
      builder: (context, sensorState) {
        final data = sensorState.history;
        return BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return SizedBox(
              height: 200,
              width: double.infinity,
              child: Semantics(
                container: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            widget.sensorType.name,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Tooltip(
                            message: 'Reset Zoom',
                            child: Semantics(
                              button: true,
                              label: 'Reset zoom',
                              hint: 'Resets chart zoom and pan',
                              child: IconButton(
                                icon: Icon(Icons.zoom_out_map_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                                onPressed: _resetZoom,
                                style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(36, 36)),
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
                                icon: Icon(Icons.zoom_in_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                                onPressed: _zoomIn,
                                style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(36, 36)),
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
                                icon: Icon(Icons.zoom_out_rounded, size: 20, color: colorScheme.onSurfaceVariant),
                                onPressed: _zoomOut,
                                style: IconButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(36, 36)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Expanded(
                    child: LineChart(
                      transformationConfig: FlTransformationConfig(
                        scaleAxis: FlScaleAxis.horizontal,
                        maxScale: 30.0,
                        transformationController: _transformationController,
                      ),
                      LineChartData(
                        minX: 0,
                        maxX: (data.length - 1).toDouble(),
                        minY: _getMinY(data) - 1,
                        maxY: _getMaxY(data) + 1,
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            tooltipPadding: const EdgeInsets.all(8),
                            getTooltipItems: (spots) => spots.map((spot) {
                              String axisLabel;
                              Color axisColor;
                              switch (spot.barIndex) {
                                case 0:
                                  axisLabel = 'X';
                                  axisColor = chartColors.xAxis!;
                                  break;
                                case 1:
                                  axisLabel = 'Y';
                                  axisColor = chartColors.yAxis!;
                                  break;
                                case 2:
                                  axisLabel = 'Z';
                                  axisColor = chartColors.zAxis!;
                                  break;
                                default:
                                  axisLabel = '';
                                  axisColor = Colors.white;
                              }
                              return LineTooltipItem(
                                '$axisLabel: ${spot.y.toStringAsFixed(2)}',
                                textTheme.bodySmall!.copyWith(
                                color: axisColor,
                                fontWeight: FontWeight.bold,
                              ),
                              );
                            }).toList(),
                          ),
                        ),
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                          strokeWidth: 0.8,
                        ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: data.isNotEmpty,
                              interval: data.isEmpty
                                  ? 1.0
                                  : (data.length / 5).floor().toDouble().clamp(
                                    1.0,
                                    data.length.toDouble(),
                                  ),
                              getTitlesWidget: (value, meta) {
                                if (value == 0 || value == (data.length - 1)) {
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      value.toInt().toString(),
                                      style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) => Text(
                                value.toStringAsFixed(1),
                                style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            reservedSize: 32,
                            ),
                          ),
                          topTitles: const AxisTitles(),
                          rightTitles: const AxisTitles(),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border(
                            left: BorderSide(color: colorScheme.outlineVariant, width: 1.2),
                            bottom: BorderSide(color: colorScheme.outlineVariant, width: 1.2),
                          ),
                        ),
                        lineBarsData: [
                          if (settingsState.settings.showXAxis)
                            _buildLine(data.map((e) => e.x).toList(), chartColors.xAxis!, 'X'),
                          if (settingsState.settings.showYAxis)
                            _buildLine(data.map((e) => e.y).toList(), chartColors.yAxis!, 'Y'),
                          if (settingsState.settings.showZAxis)
                            _buildLine(data.map((e) => e.z).toList(), chartColors.zAxis!, 'Z'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (settingsState.settings.showXAxis)
                      _LegendItem(color: chartColors.xAxis!, label: 'X (Red)'),
                      const SizedBox(width: 12),
                      if (settingsState.settings.showYAxis)
                         
                      _LegendItem(color: chartColors.yAxis!, label: 'Y (Green)'),
                      const SizedBox(width: 12),
                      if (settingsState.settings.showZAxis)
                      _LegendItem(color: chartColors.zAxis!, label: 'Z (Blue)'),
                    ],
                  ),
                ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  LineChartBarData _buildLine(List<double> values, Color color, String axisLabel) {
    final points = List.generate(values.length, (i) => FlSpot(i.toDouble(), values[i]));

    return LineChartBarData(
      spots: points,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: true, color: color.withValues(alpha: 0.15)),
    );
  }

  double _getMinY(List<SensorDataPoint> data) {
    final all = data.expand((e) => [e.x, e.y, e.z]);
    return all.isEmpty ? 0 : all.reduce((a, b) => a < b ? a : b);
  }

  double _getMaxY(List<SensorDataPoint> data) {
    final all = data.expand((e) => [e.x, e.y, e.z]);
    return all.isEmpty ? 0 : all.reduce((a, b) => a > b ? a : b);
  }

  void _resetZoom() => _transformationController.value = Matrix4.identity();
  void _zoomIn() => _transformationController.value *= Matrix4.diagonal3Values(1.1, 1.1, 1);
  void _zoomOut() => _transformationController.value *= Matrix4.diagonal3Values(0.9, 0.9, 1);
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Semantics(
      container: true,
      label: '$label legend',
      value: 'Color ${_colorToName(color)}',
      child: Row(
        children: [
          Container(
            width: 24,
            height: 8,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: color),
          ),
          const SizedBox(width: 8),
          Text(label, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  String _colorToName(Color c) {
    if (c == Colors.red ) return 'red';
    if (c == Colors.green) return 'green';
    if (c == Colors.blue) return 'blue';
    return 'custom color';
  }
}
