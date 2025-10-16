import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_sensors/config/app_theme.dart';
import 'package:real_time_sensors/domain/repositories/device_sensor_repository_impl.dart';
import 'package:real_time_sensors/domain/repositories/sensor_repository.dart';
import 'package:real_time_sensors/domain/usecases/start_sensor_stream.dart';
import 'package:real_time_sensors/presentation/bloc/accelerometer/accelerometer_bloc.dart';
import 'package:real_time_sensors/presentation/bloc/gyroscope/gyroscope_bloc.dart';
import 'package:real_time_sensors/presentation/bloc/settings/settings_bloc.dart';
import 'package:real_time_sensors/presentation/screens/sensor_screen.dart';

class SensorApp extends StatelessWidget {
  const SensorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SensorRepository repository = DeviceSensorRepositoryImpl();
    final StartSensorStreamUseCase startSensorStreamUseCase = StartSensorStreamUseCase(repository);
    final SettingsBloc settingsBloc = SettingsBloc();
    return RepositoryProvider<SensorRepository>(
      create: (context) => DeviceSensorRepositoryImpl(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => settingsBloc),
          BlocProvider(
            create: (_) =>
                AccelerometerBloc(startSensorStreamUseCase: startSensorStreamUseCase, settingsBloc: settingsBloc),
            lazy: false,
          ),
          BlocProvider(
            create: (_) =>
                GyroscopeBloc(startSensorStreamUseCase: startSensorStreamUseCase, settingsBloc: settingsBloc),
            lazy: false,
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return MaterialApp(
              title: 'Sensor Visualization',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state.settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const SensorScreen(),
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
