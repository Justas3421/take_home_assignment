import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color _primarySeedColor = Color.fromARGB(255, 8, 114, 212);

  static final Color _chartXAxis = Colors.red.shade400;
  static final Color _chartYAxis = Colors.green.shade400;
  static final Color _chartZAxis = Colors.blue.shade400;

  static final ThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    seedColor: _primarySeedColor,
    chartX: _chartXAxis,
    chartY: _chartYAxis,
    chartZ: _chartZAxis,
  );

  static final ThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    seedColor: _primarySeedColor,
    chartX: _chartXAxis,
    chartY: _chartYAxis,
    chartZ: _chartZAxis,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color seedColor,
    required Color chartX,
    required Color chartY,
    required Color chartZ,
  }) {
    final colorScheme = ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      textTheme: _buildTextTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: _buildTextTheme(
          colorScheme,
        ).headlineMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
        systemOverlayStyle: brightness == Brightness.light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _buildTextTheme(colorScheme).labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: _buildTextTheme(colorScheme).labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: _buildTextTheme(colorScheme).labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: _buildTextTheme(colorScheme).labelLarge,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primaryContainer.withValues(alpha: 0.5),
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
        trackHeight: 4.0,
        valueIndicatorTextStyle: _buildTextTheme(colorScheme).labelSmall?.copyWith(color: colorScheme.onInverseSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: colorScheme.surfaceContainerHigh,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.primary.withValues(alpha: 0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return colorScheme.primary.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.pressed)) {
            return colorScheme.primary.withValues(alpha: 0.12);
          }
          return null;
        }),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          selectedForegroundColor: colorScheme.onPrimaryContainer,
          selectedBackgroundColor: colorScheme.primaryContainer,
          side: BorderSide(color: colorScheme.outlineVariant),
          textStyle: _buildTextTheme(colorScheme).labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: _buildTextTheme(colorScheme).bodyMedium?.copyWith(color: colorScheme.onInverseSurface),
        actionTextColor: colorScheme.inversePrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        modalBackgroundColor: colorScheme.surfaceContainerHigh,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28.0))),
        showDragHandle: true,
        elevation: 2,
      ),
      extensions: <ThemeExtension<dynamic>>[ChartColors(xAxis: chartX, yAxis: chartY, zAxis: chartZ)],
    );
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: TextStyle(fontFamily: 'Roboto', fontSize: 57, color: colorScheme.onSurface),
      displayMedium: TextStyle(fontFamily: 'Roboto', fontSize: 45, color: colorScheme.onSurface),
      displaySmall: TextStyle(fontFamily: 'Roboto', fontSize: 36, color: colorScheme.onSurface),
      headlineLarge: TextStyle(fontFamily: 'Roboto', fontSize: 32, color: colorScheme.onSurface),
      headlineMedium: TextStyle(fontFamily: 'Roboto', fontSize: 28, color: colorScheme.onSurface),
      headlineSmall: TextStyle(fontFamily: 'Roboto', fontSize: 24, color: colorScheme.onSurface),
      titleLarge: TextStyle(fontFamily: 'Roboto', fontSize: 22, color: colorScheme.onSurface),
      titleMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 16, color: colorScheme.onSurface),
      bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 14, color: colorScheme.onSurface),
      bodySmall: TextStyle(fontFamily: 'Roboto', fontSize: 12, color: colorScheme.onSurfaceVariant),
      labelLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

@immutable
class ChartColors extends ThemeExtension<ChartColors> {
  const ChartColors({required this.xAxis, required this.yAxis, required this.zAxis});

  final Color? xAxis;
  final Color? yAxis;
  final Color? zAxis;

  @override
  ChartColors copyWith({Color? xAxis, Color? yAxis, Color? zAxis}) {
    return ChartColors(xAxis: xAxis ?? this.xAxis, yAxis: yAxis ?? this.yAxis, zAxis: zAxis ?? this.zAxis);
  }

  @override
  ChartColors lerp(ThemeExtension<ChartColors>? other, double t) {
    if (other is! ChartColors) {
      return this;
    }
    return ChartColors(
      xAxis: Color.lerp(xAxis, other.xAxis, t),
      yAxis: Color.lerp(yAxis, other.yAxis, t),
      zAxis: Color.lerp(zAxis, other.zAxis, t),
    );
  }
}
