package ir.sharifmp.secure_banking_app.s401105912

import android.content.pm.PackageManager
import android.os.Build
import android.os.Debug
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.MessageDigest

/**
 * Platform-specific security checks, app signature retrieval, and FLAG_SECURE.
 * Required for: signature verification, root detection, debug detection,
 * screenshot blocking (replaces flutter_windowmanager for AGP compatibility).
 */
class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val SECURITY_CHANNEL =
            "ir.sharifmp.secure_banking_app.s401105912/security"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            SECURITY_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAppSignatureSha256" -> {
                    try {
                        result.success(getSigningCertificateSha256())
                    } catch (e: Exception) {
                        result.error("SIGNATURE_ERROR", e.message, null)
                    }
                }
                "isDeviceRooted" -> {
                    result.success(isDeviceRooted())
                }
                "isDebuggerAttached" -> {
                    result.success(Debug.isDebuggerConnected())
                }
                "enableScreenshotProtection" -> {
                    runOnUiThread {
                        try {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("FLAG_SECURE_ERROR", e.message, null)
                        }
                    }
                }
                "disableScreenshotProtection" -> {
                    runOnUiThread {
                        try {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("FLAG_SECURE_ERROR", e.message, null)
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun getSigningCertificateSha256(): String {
        val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageManager.getPackageInfo(
                packageName,
                PackageManager.GET_SIGNING_CERTIFICATES,
            )
        } else {
            packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
        }

        val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            packageInfo.signingInfo?.apkContentsSigners
        } else {
            packageInfo.signatures
        }

        if (signatures.isNullOrEmpty()) {
            return ""
        }

        val digest = MessageDigest.getInstance("SHA-256")
        val hash = digest.digest(signatures[0].toByteArray())
        return hash.joinToString("") { "%02x".format(it) }
    }

    private fun isDeviceRooted(): Boolean {
        val rootPaths = listOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su",
            "/su/bin/su",
        )

        if (rootPaths.any { File(it).exists() }) {
            return true
        }

        val buildTags = Build.TAGS
        if (buildTags != null && buildTags.contains("test-keys")) {
            return true
        }

        return canExecuteSuCommand()
    }

    private fun canExecuteSuCommand(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec(arrayOf("/system/xbin/which", "su"))
            val reader = process.inputStream.bufferedReader()
            val line = reader.readLine()
            reader.close()
            line != null
        } catch (_: Exception) {
            false
        }
    }
}
