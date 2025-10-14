import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_sensors/presentation/bloc/settings/settings_bloc.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visualization Settings',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 28),
                _SectionTitle(
                  title: 'Refresh Rate (Hz)',
                  icon: Icons.refresh_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                Slider(
                  value: state.settings.refreshRateHz.toDouble(),
                  min: 10,
                  max: 50,
                  divisions: 4,
                  label: '${state.settings.refreshRateHz} Hz',
                  activeColor: colorScheme.primary,
                  inactiveColor: colorScheme.surfaceContainerHighest,
                  thumbColor: colorScheme.onPrimary,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(UpdateRefreshRate(value.toInt()));
                  },
                ),
                const SizedBox(height: 24),

                _SectionTitle(
                  title: 'Displayed Axes',
                  icon: Icons.line_axis_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _AxisChoiceChip(
                      label: 'X',
                      color: Colors.red.shade400,
                      value: state.settings.showXAxis,
                      onChanged: (val) =>
                          context.read<SettingsBloc>().add(ToggleAxisVisibility(axis: 'x', isVisible: val)),
                    ),
                    _AxisChoiceChip(
                      label: 'Y',
                      color: Colors.green.shade400,
                      value: state.settings.showYAxis,
                      onChanged: (val) =>
                          context.read<SettingsBloc>().add(ToggleAxisVisibility(axis: 'y', isVisible: val)),
                    ),
                    _AxisChoiceChip(
                      label: 'Z',
                      color: Colors.blue.shade400,
                      value: state.settings.showZAxis,
                      onChanged: (val) =>
                          context.read<SettingsBloc>().add(ToggleAxisVisibility(axis: 'z', isVisible: val)),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                _SectionTitle(
                  title: 'App Theme',
                  icon: Icons.brightness_4_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Dark Mode',
                        style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                      ),
                    ),
                    Switch(
                      value: state.settings.isDarkMode,
                      onChanged: (val) => context.read<SettingsBloc>().add(UpdateThemeMode(val)),
                      activeThumbColor: colorScheme.primary,
                      activeTrackColor: colorScheme.primaryContainer,
                      inactiveThumbColor: colorScheme.onSurfaceVariant,
                      inactiveTrackColor: colorScheme.surfaceContainerHighest,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const SettingsBottomSheet(),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28.0))),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.95),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;

  const _SectionTitle({required this.title, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, color: color ?? colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        ),
      ],
    );
  }
}

class _AxisChoiceChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AxisChoiceChip({required this.label, required this.color, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ChoiceChip(
      label: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: value ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: value,
      onSelected: onChanged,
      selectedColor: color,
      disabledColor: colorScheme.surfaceContainerHighest,
      backgroundColor: colorScheme.surfaceContainerHighest,
      labelStyle: theme.textTheme.labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: value ? color : colorScheme.outlineVariant, width: 1.2),
      ),
      showCheckmark: false,
      elevation: value ? 2 : 0,
      pressElevation: value ? 4 : 0,
      shadowColor: color.withValues(alpha: 0.2),
    );
  }
}
