import UIKit
import Flutter
import CoreMotion

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  let motionManager = CMMotionManager()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.example.real_time_sensors/sensor", binaryMessenger: controller.binaryMessenger)
    
    channel.setMethodCallHandler { call, result in
      if call.method == "isSensorAvailable" {
        if let args = call.arguments as? [String: Any],
           let sensor = args["sensor"] as? String {
          let available = self.isSensorAvailable(sensor: sensor)
          result(available)
        } else {
          result(false)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func isSensorAvailable(sensor: String) -> Bool {
    switch sensor {
    case "Accelerometer":
      return motionManager.isAccelerometerAvailable
    case "Gyroscope":
      return motionManager.isGyroAvailable
    default:
      return false
    }
  }
}
