import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // MethodChannel 示例：与 Dart 端 DeviceChannel 的通道名保持一致
    // （lib/widgets/工程化/engineering_widgets.dart）
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "FlutterCourseDeviceChannel") {
      let channel = FlutterMethodChannel(
        name: "flutter_course/device", binaryMessenger: registrar.messenger())
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "getBatteryLevel":
          let device = UIDevice.current
          device.isBatteryMonitoringEnabled = true
          if device.batteryState == .unknown {
            // 模拟器上拿不到电量
            result(FlutterError(code: "UNAVAILABLE", message: "无法获取电量（模拟器不支持）", details: nil))
          } else {
            result(Int(device.batteryLevel * 100))
          }
        case "getDeviceInfo":
          let device = UIDevice.current
          result([
            "os": device.systemName,
            "version": device.systemVersion,
            "model": device.model,
          ])
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
  }
}
