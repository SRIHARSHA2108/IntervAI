package com.example.ai_interview

import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "ai_interview/device_settings"
        ).setMethodCallHandler { call, result ->
            if (call.method != "openInternetSettings") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val action = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                Settings.Panel.ACTION_INTERNET_CONNECTIVITY
            } else {
                Settings.ACTION_WIRELESS_SETTINGS
            }
            startActivity(Intent(action))
            result.success(null)
        }
    }
}
