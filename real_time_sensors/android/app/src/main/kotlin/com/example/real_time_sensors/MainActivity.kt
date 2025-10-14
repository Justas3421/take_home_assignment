package com.example.real_time_sensors

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.real_time_sensors/sensor"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "isSensorAvailable") {
                val sensorType = call.argument<String>("sensor")
                val available = isSensorAvailable(sensorType)
                result.success(available)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isSensorAvailable(sensorType: String?): Boolean {
        val sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        return when (sensorType) {
            "Accelerometer" -> sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) != null
            "Gyroscope" -> sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE) != null
            else -> false
        }
    }
}
