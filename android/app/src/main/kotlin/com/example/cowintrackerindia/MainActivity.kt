package com.example.cowintrackerindia

import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.widget.Toast
import androidx.annotation.NonNull

class MainActivity: FlutterActivity() {

    private val channel = "platformChannelForFlutter"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
                call, result ->
            when(call.method){
                "getBatteryLevel"->{
                    val batteryLevel = getBatteryLevel()
                    if (batteryLevel != -1) {
                        result.success(batteryLevel)
                    } else {
                        result.error("UNAVAILABLE", "Battery level not available.", null)
                    }
                }

//                TODO: Some Notes about data sharing
                //Date: Use System Data for Calls

//                With Pincode
                //PINCODE: int(6 Digit Pincode)
                //VACCINE: String (ANY -> ANY) (COVISHIELD) (COVAXIN) (SPUTNIK V)
                //AGE: int (0-Any) (1-> 18-45) (2 -> 45+)
                //DOSE: int (0-Any) (1-First Dose) (2-Second Dose)
                //COST: int (0-Any) (1-Free) (2-Paid)

//                With DistrictId
                //DISTRICTID: int (District ID)
                //VACCINE: String (ANY -> ANY) (COVISHIELD) (COVAXIN) (SPUTNIK V)
                //AGE: int (0-Any) (1-> 18-45) (2 -> 45+)
                //DOSE: int (0-Any) (1-First Dose) (2-Second Dose)
                //COST: int (0-Any) (1-Free) (2-Paid)

//                TODO: Implement: Both functions can return String(for now) (if necessary), else return ""

                "registerWithPinCode" -> {
                    // Accessing arguments-> call.arguments returns a map/object with the passes arguments as described in above comments
                    result.success(call.arguments.toString())
                }

                "registerWithDistrictId" -> {
                    result.success(call.arguments.toString())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): Int {

        return if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(
                null,
                IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            )
            intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(
                BatteryManager.EXTRA_SCALE,
                -1
            )
        }
    }

//    fun Context.toast(message: CharSequence) =
//        Toast.makeText(this, message, Toast.LENGTH_LONG).show()
}
