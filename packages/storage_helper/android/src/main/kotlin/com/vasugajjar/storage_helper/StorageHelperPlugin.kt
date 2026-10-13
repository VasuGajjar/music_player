package com.vasugajjar.storage_helper

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry

class StorageHelperPlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
    PluginRegistry.RequestPermissionsResultListener {
    object Constant {
        const val permissionStorageRequestCode = 101
        const val permissionStorageDeniedErrorCode = "storagePermissionDenied"
    }

    private lateinit var channel: MethodChannel
    private lateinit var activity: Activity
    private lateinit var context: Context
    private var result: MethodChannel.Result? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "storage_helper")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: io.flutter.plugin.common.MethodChannel.Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else if (call.method == "getSongs") {
            this.result = result
            if (checkStoragePermission()) {
                getSongs()
            } else {
                requestStoragePermission()
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(this);
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onDetachedFromActivity() {
    }

    // Android 13+ replaced READ_EXTERNAL_STORAGE with granular media permissions.
    private val storagePermission =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) Manifest.permission.READ_MEDIA_AUDIO
        else Manifest.permission.READ_EXTERNAL_STORAGE

    private fun checkStoragePermission(): Boolean =
        context.checkSelfPermission(storagePermission) == PackageManager.PERMISSION_GRANTED

    private fun requestStoragePermission() {
        activity.requestPermissions(arrayOf(storagePermission), Constant.permissionStorageRequestCode)
    }

    private fun getSongs() {
        try {
            val selection = MediaStore.Audio.Media.IS_MUSIC + " != 0"
            val projection = arrayOf(
                MediaStore.Audio.Media.DATA
            )

            val songs: MutableList<String> = ArrayList()
            context.contentResolver.query(
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                projection,
                selection,
                null,
                null
            )?.use { cursor ->
                while (cursor.moveToNext()) {
                    songs.add(cursor.getString(0))
                }
            }
            result?.success(songs.toList())
        } catch (e: Exception) {
            result?.error(e.message ?: "error", e.localizedMessage, e.stackTraceToString())
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == Constant.permissionStorageRequestCode) {
            val res = grantResults.all { value -> value == PackageManager.PERMISSION_GRANTED }
            if (res) {
                getSongs()
            } else {
                result?.error(
                    Constant.permissionStorageDeniedErrorCode,
                    "Storage Permission Denied",
                    "Grant Storage Permission"
                )
            }
        }
        return false;
    }
}
