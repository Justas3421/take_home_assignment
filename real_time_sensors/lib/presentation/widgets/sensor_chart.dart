import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_sensors/config/app_theme.dart';
import 'package:real_time_sensors/domain/models/sensor_data.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/presentation/bloc/sensor_bloc_base/sensor_bloc_base.dart';
import 'package:real_time_sensors/presentation/bloc/settings/settings_bloc.dart';
import 'package:real_time_sensors/presentation/widgets/sensor_chart_header.dart';
import 'package:real_time_sensors/presentation/widgets/sensor_chart_legend.dart';

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
            final min = _getMinY(data);
            final max = _getMaxY(data);
            final range = (max - min).abs();
            final pad = range == 0 ? 1.0 : range * 0.1;
            final minY = min - pad;
            final maxY = max + pad;
            final yInterval = _calculateYInterval(minY, maxY);
            return Semantics(
              container: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SensorChartHeader(
                    transformationController: _transformationController,
                    sensorType: widget.sensorType,
                    bloc: widget.bloc,
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
                        minY: minY,
                        maxY: maxY,
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
                                textTheme.bodySmall!.copyWith(color: axisColor, fontWeight: FontWeight.bold),
                              );
                            }).toList(),
                          ),
                        ),
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) =>
                              FlLine(color: colorScheme.outlineVariant.withValues(alpha: 0.3), strokeWidth: 0.8),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: data.isNotEmpty,
                              interval: data.isEmpty
                                  ? 1.0
                                  : (data.length / 5).floor().toDouble().clamp(1.0, data.length.toDouble()),
                              getTitlesWidget: (value, meta) {
                                if (value == 0 || value == (data.length - 1)) {
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      value.toInt().toString(),
                                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
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
                              interval: yInterval,
                              getTitlesWidget: (value, meta) => Text(
                                value.toStringAsFixed(1),
                                style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
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
                  const SensorChartLegend(),
                  const SizedBox(height: 16),
                ],
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

  double _calculateYInterval(double minY, double maxY, {int targetTicks = 5}) {
    final raw = (maxY - minY).abs() / targetTicks;
    final pow10 = math.pow(10, (math.log(raw) / math.ln10).floor());
    final candidates = [1, 2, 2.5, 5, 10].map((m) => m * pow10);
    return candidates.firstWhere((c) => c >= raw, orElse: () => 10 * pow10).toDouble();
  }
}
