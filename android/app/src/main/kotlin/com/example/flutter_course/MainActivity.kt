package com.example.flutter_course

import android.content.Context
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // 与 Dart 端 DeviceChannel 的通道名保持一致（lib/widgets/工程化/engineering_widgets.dart）
    private val channelName = "flutter_course/device"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryLevel" -> {
                        val level = batteryLevel()
                        if (level >= 0) {
                            result.success(level)
                        } else {
                            result.error("UNAVAILABLE", "无法获取电量", null)
                        }
                    }
                    "getDeviceInfo" -> result.success(
                        mapOf(
                            "os" to "Android",
                            "version" to Build.VERSION.RELEASE,
                            "model" to "${Build.MANUFACTURER} ${Build.MODEL}",
                        )
                    )
                    else -> result.notImplemented()
                }
            }
    }

    private fun batteryLevel(): Int {
        val manager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return manager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }
}
