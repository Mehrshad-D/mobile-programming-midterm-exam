package ir.sharifmp.encrypted_bank_card_app.s401105689_401105912_401170604

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val channelName =
        "ir.sharifmp.encrypted_bank_card_app.s401105689_401105912_401170604/installed_apps"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isAppInstalled" -> {
                        val packageName = call.argument<String>("package_name")
                        if (packageName.isNullOrBlank()) {
                            result.error("INVALID", "package_name is required", null)
                            return@setMethodCallHandler
                        }
                        result.success(isAppInstalled(packageName))
                    }
                    "getAppVersion" -> {
                        val packageName = call.argument<String>("package_name")
                        if (packageName.isNullOrBlank()) {
                            result.error("INVALID", "package_name is required", null)
                            return@setMethodCallHandler
                        }
                        result.success(getAppVersion(packageName))
                    }
                    "startApp" -> {
                        val packageName = call.argument<String>("package_name")
                        if (packageName.isNullOrBlank()) {
                            result.error("INVALID", "package_name is required", null)
                            return@setMethodCallHandler
                        }
                        result.success(startApp(packageName))
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isAppInstalled(packageName: String): Boolean {
        return try {
            getPackageInfo(packageName)
            true
        } catch (_: PackageManager.NameNotFoundException) {
            false
        }
    }

    private fun getAppVersion(packageName: String): String? {
        return try {
            getPackageInfo(packageName).versionName
        } catch (_: PackageManager.NameNotFoundException) {
            null
        }
    }

    private fun startApp(packageName: String): Boolean {
        return try {
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            if (launchIntent != null) {
                startActivity(launchIntent)
                true
            } else {
                false
            }
        } catch (_: Exception) {
            false
        }
    }

    @Suppress("DEPRECATION")
    private fun getPackageInfo(packageName: String): android.content.pm.PackageInfo {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packageManager.getPackageInfo(
                packageName,
                PackageManager.PackageInfoFlags.of(0),
            )
        } else {
            packageManager.getPackageInfo(packageName, 0)
        }
    }
}
