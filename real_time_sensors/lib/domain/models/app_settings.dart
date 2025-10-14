import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final int refreshRateHz;
  final double chartScale;
  final bool autoScale;
  final bool showXAxis;
  final bool showYAxis;
  final bool showZAxis;
  final int historySize;
  final bool isDarkMode;

  const AppSettings({
    this.refreshRateHz = 30,
    this.chartScale = 10.0,
    this.autoScale = true,
    this.showXAxis = true,
    this.showYAxis = true,
    this.showZAxis = true,
    this.historySize = 300,
    this.isDarkMode = true,
  });

  AppSettings copyWith({
    int? refreshRateHz,
    double? chartScale,
    bool? autoScale,
    bool? showXAxis,
    bool? showYAxis,
    bool? showZAxis,
    int? historySize,
    bool? isDarkMode,
  }) {
    return AppSettings(
      refreshRateHz: refreshRateHz ?? this.refreshRateHz,
      chartScale: chartScale ?? this.chartScale,
      autoScale: autoScale ?? this.autoScale,
      showXAxis: showXAxis ?? this.showXAxis,
      showYAxis: showYAxis ?? this.showYAxis,
      showZAxis: showZAxis ?? this.showZAxis,
      historySize: historySize ?? this.historySize,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [
    refreshRateHz,
    chartScale,
    autoScale,
    showXAxis,
    showYAxis,
    showZAxis,
    historySize,
    isDarkMode,
  ];
}
