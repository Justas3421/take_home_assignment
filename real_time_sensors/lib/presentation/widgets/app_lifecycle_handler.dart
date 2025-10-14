import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_time_sensors/presentation/bloc/accelerometer/accelerometer_bloc.dart';
import 'package:real_time_sensors/presentation/bloc/gyroscope/gyroscope_bloc.dart';
import 'package:real_time_sensors/presentation/bloc/sensor_bloc_base/sensor_bloc_base.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;

  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<GyroscopeBloc>().add(AppLifecycleChanged(state));
    context.read<AccelerometerBloc>().add(AppLifecycleChanged(state));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
