import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final int refreshRateHz;
  final bool showXAxis;
  final bool showYAxis;
  final bool showZAxis;
  final int historySize;
  final bool isDarkMode;

  const AppSettings({
    this.refreshRateHz = 30,
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
    showXAxis,
    showYAxis,
    showZAxis,
    historySize,
    isDarkMode,
  ];
}
