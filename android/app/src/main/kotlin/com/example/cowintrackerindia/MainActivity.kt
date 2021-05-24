package com.example.cowintrackerindia

import android.app.ActivityManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.os.BatteryManager
import android.os.Build
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.NotificationCompat
import com.example.cowintrackerindia.constants.Constants
import com.example.cowintrackerindia.service.MyService
import io.flutter.plugin.common.MethodCall

class MainActivity: FlutterActivity() {

    private val channel = "platformChannelForFlutter"
    private lateinit var mSharedPreferences: SharedPreferences

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

                    val pincodeService = MyService()
                    if(!isMyServiceRunning(pincodeService::class.java)) {
                        mSharedPreferences = this.getSharedPreferences(
                            Constants().ALERT,
                            MODE_PRIVATE
                        )
                        saveDetails(true, mSharedPreferences, call)

                        val serviceIntent = Intent(this, pincodeService::class.java)
                        this.startService(serviceIntent)
                        notifyUser("Vaccine Alert Set!"
                            ,"We'll notify you as soon as vaccines are available for booking!")
                    } else {
                        Log.d("serviceCheck","Service Already Present")
                        //service already present
                    }

                    result.success(call.arguments.toString())
                }

                "registerWithDistrictId" -> {

                    val districtIDService = MyService()
                    if(!isMyServiceRunning(districtIDService::class.java)) {
                        mSharedPreferences = this.getSharedPreferences(
                            Constants().ALERT,
                            MODE_PRIVATE
                        )
                        saveDetails(false, mSharedPreferences, call)

                        val serviceIntent = Intent(this, districtIDService::class.java)
                        this.startService(serviceIntent)
                        notifyUser("Vaccine Alert Set!"
                            ,"We'll notify you as soon as vaccines are available for booking!")
                    } else {
                        //service already present
                        Log.d("serviceCheck","Service Already Present")
                    }
                    result.success(call.arguments.toString())
                }

                "onDestroy" -> {
                    mSharedPreferences = this.getSharedPreferences(
                        Constants().ALERT,
                        MODE_PRIVATE
                    )
                    if(mSharedPreferences.getString(Constants().TYPE, "") != null  &&
                        mSharedPreferences.getString(Constants().TYPE, "") != "") {
                        val broadcastIntent = Intent()
                        broadcastIntent.action = "RestartService"
                        broadcastIntent.setClass(this, BroadcastReceiver::class.java)
                        this.sendBroadcast(broadcastIntent)
                    }
                }

                "deleteAlerts" -> {
                    try{
                        mSharedPreferences = this.getSharedPreferences(
                            Constants().ALERT,
                            MODE_PRIVATE
                        )
                        deleteDetails(mSharedPreferences)
                        val service = MyService()
                        if (isMyServiceRunning(service::class.java)) {
                            stopService(Intent(this, service::class.java))
                        }

                        result.success(true);
                    } catch (e: Exception){
                        result.error("AlertNotDeleted", "Couldn't delete error", "Error occurred while deleting an alert")
                    }

                }

                else -> result.notImplemented()
            }
        }
    }

    private fun deleteDetails(sharedPreferences: SharedPreferences) {
        sharedPreferences.edit().putString(
            Constants().PINCODE,
            ""
        ).apply()
        sharedPreferences.edit().putString(
            Constants().TYPE,
            ""
        ).apply()

        sharedPreferences.edit().putString(
            Constants().AGE,
            ""
        ).apply()
        sharedPreferences.edit().putString(
            Constants().COST,
            ""
        ).apply()
        sharedPreferences.edit().putString(
            Constants().DOSE,
            ""
        ).apply()
        sharedPreferences.edit().putString(
            Constants().VACCINE,
            ""
        ).apply()
    }

    private fun saveDetails(flag: Boolean, sharedPreferences: SharedPreferences, call: MethodCall) {
        if(flag) {
            sharedPreferences.edit().putString(
                Constants().PINCODE,
                ""+call.argument("pincode")
            ).apply()
            sharedPreferences.edit().putString(
                Constants().TYPE,
                "pincode"
            ).apply()
        } else {
            sharedPreferences.edit().putString(
                Constants().DISTRICTID,
                ""+call.argument("districtId")
            ).apply()
            sharedPreferences.edit().putString(
                Constants().TYPE,
                "districtId"
            ).apply()
        }

        sharedPreferences.edit().putString(
            Constants().AGE,
            ""+call.argument("age")
        ).apply()
        sharedPreferences.edit().putString(
            Constants().COST,
            ""+call.argument("cost")
        ).apply()
        sharedPreferences.edit().putString(
            Constants().DOSE,
            ""+call.argument("dose")
        ).apply()
        sharedPreferences.edit().putString(
            Constants().VACCINE,
            ""+call.argument("vaccine")
        ).apply()
    }

    private fun isMyServiceRunning(serviceClass: Class<*>): Boolean {
        val manager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        for (service in manager.getRunningServices(Int.MAX_VALUE)) {
            if (serviceClass.name == service.service.className) {
                return true
            }
        }
        return false
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

    private fun notifyUser(title:String="", details:String="") {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            nm.createNotificationChannel(NotificationChannel("100","alert", NotificationManager.IMPORTANCE_HIGH))
        }
        val simpleNotification = NotificationCompat.Builder(this, "100")
            .setContentTitle(title)
            .setContentText(details)
            .setSmallIcon(R.drawable.launch_background)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        nm.notify(1, simpleNotification)
    }

//    fun Context.toast(message: CharSequence) =
//        Toast.makeText(this, message, Toast.LENGTH_LONG).show()
}
