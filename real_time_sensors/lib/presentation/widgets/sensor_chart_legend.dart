import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_sensors/config/app_theme.dart';
import 'package:real_time_sensors/presentation/bloc/settings/settings_bloc.dart';

class SensorChartLegend extends StatelessWidget {
  const SensorChartLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final chartColors = theme.extension<ChartColors>()!;
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (settingsState.settings.showXAxis) _LegendItem(color: chartColors.xAxis!, label: 'X'),
            const SizedBox(width: 12),
            if (settingsState.settings.showYAxis) _LegendItem(color: chartColors.yAxis!, label: 'Y'),
            const SizedBox(width: 12),
            if (settingsState.settings.showZAxis) _LegendItem(color: chartColors.zAxis!, label: 'Z'),
          ],
        );
      },
    );
  }
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
    if (c == Colors.red) return 'red';
    if (c == Colors.green) return 'green';
    if (c == Colors.blue) return 'blue';
    return 'custom color';
  }
}
