import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_sensors/domain/models/sensor_type.dart';
import 'package:real_time_sensors/infrastructure/services/csv_export_service.dart';
import 'package:real_time_sensors/infrastructure/services/file_save_service.dart';
import 'package:real_time_sensors/infrastructure/services/screenshot_service.dart';
import 'package:real_time_sensors/presentation/bloc/accelerometer/accelerometer_bloc.dart';
import 'package:real_time_sensors/presentation/bloc/gyroscope/gyroscope_bloc.dart';
import 'package:real_time_sensors/presentation/bloc/sensor_bloc_base/sensor_bloc_base.dart';
import 'package:real_time_sensors/presentation/screens/settings_screen.dart';
import 'package:real_time_sensors/presentation/widgets/app_lifecycle_handler.dart';
import 'package:real_time_sensors/presentation/widgets/error_warning.dart';
import 'package:real_time_sensors/presentation/widgets/sensor_panel.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SensorType _selectedView = SensorType.accelerometer;

  final screenshotService = ScreenshotService();
  final csvExportService = CsvExportService();
  final fileSaveService = FileSaveService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: SensorType.values.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    context.read<AccelerometerBloc>().add(const StartSensorCapture());
    context.read<GyroscopeBloc>().add(const StartSensorCapture());
    context.read<GyroscopeBloc>().add(const PauseSensorCapture());
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppLifecycleHandler(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sensor Visualization'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings_rounded, color: colorScheme.onSurfaceVariant),
              tooltip: 'Settings',
              onPressed: () => SettingsBottomSheet.show(context),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: SegmentedButton<SensorType>(
                  segments: const <ButtonSegment<SensorType>>[
                    ButtonSegment<SensorType>(
                      value: SensorType.accelerometer,
                      label: Text('Accelerometer'),
                      icon: Icon(Icons.speed_rounded),
                    ),
                    ButtonSegment<SensorType>(
                      value: SensorType.gyroscope,
                      label: Text('Gyroscope'),
                      icon: Icon(Icons.rotate_right_rounded),
                    ),
                  ],
                  selected: <SensorType>{_selectedView},
                  onSelectionChanged: (Set<SensorType> newSelection) {
                    if (newSelection.isNotEmpty) {
                      final selected = newSelection.first;
                      _setSelectedView(selected);
                    }
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    AccelerometerTab(
                      screenshotService: screenshotService,
                      csvExportService: csvExportService,
                      fileSaveService: fileSaveService,
                    ),
                    GyroscopeTab(
                      screenshotService: screenshotService,
                      csvExportService: csvExportService,
                      fileSaveService: fileSaveService,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;

    final newView = SensorType.values[_tabController.index];
    if (newView == _selectedView) return;

    _setSelectedView(newView);
  }

  void _setSelectedView(SensorType newView) {
    if (newView == _selectedView) return;

    final accelBloc = context.read<AccelerometerBloc>();
    final gyroBloc = context.read<GyroscopeBloc>();

    switch (newView) {
      case SensorType.accelerometer:
        if (gyroBloc.state.isCapturing) {
          gyroBloc.add(const PauseSensorCapture());
        }
        if (accelBloc.state.isCapturing == false) {
          accelBloc.add(const ResumeSensorCapture());
        }
        break;
      case SensorType.gyroscope:
        if (accelBloc.state.isCapturing) {
          accelBloc.add(const PauseSensorCapture());
        }
        if (gyroBloc.state.isCapturing == false) {
          gyroBloc.add(const ResumeSensorCapture());
        }
        break;
    }

    setState(() {
      _selectedView = newView;
    });
    if (_tabController.index != newView.index) {
      _tabController.animateTo(newView.index);
    }
  }
}

class AccelerometerTab extends StatelessWidget {
  final ScreenshotService screenshotService;
  final CsvExportService csvExportService;
  final FileSaveService fileSaveService;

  const AccelerometerTab({
    super.key,
    required this.screenshotService,
    required this.csvExportService,
    required this.fileSaveService,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Theme.of(context).cardTheme.margin ?? const EdgeInsets.all(0),
      child: BlocBuilder<AccelerometerBloc, AccelerometerState>(
        builder: (context, state) {
          if (state.errorMessage != null) {
            return ErrorWarning(message: state.errorMessage!);
          }

          return SensorPanel(
            sensorType: SensorType.accelerometer,
            bloc: context.read<AccelerometerBloc>(),
            screenshotService: screenshotService,
            csvExportService: csvExportService,
            fileSaveService: fileSaveService,
          );
        },
      ),
    );
  }
}

class GyroscopeTab extends StatelessWidget {
  final ScreenshotService screenshotService;
  final CsvExportService csvExportService;
  final FileSaveService fileSaveService;

  const GyroscopeTab({
    super.key,
    required this.screenshotService,
    required this.csvExportService,
    required this.fileSaveService,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Theme.of(context).cardTheme.margin ?? const EdgeInsets.all(0),
      child: BlocBuilder<GyroscopeBloc, GyroscopeState>(
        builder: (context, state) {
          if (state.errorMessage != null) {
            return ErrorWarning(message: state.errorMessage!);
          }
          return SensorPanel(
            sensorType: SensorType.gyroscope,
            bloc: context.read<GyroscopeBloc>(),
            screenshotService: screenshotService,
            csvExportService: csvExportService,
            fileSaveService: fileSaveService,
          );
        },
      ),
    );
  }
}
