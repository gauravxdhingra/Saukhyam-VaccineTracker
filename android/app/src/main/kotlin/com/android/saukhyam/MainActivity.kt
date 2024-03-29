package com.android.saukhyam

import android.app.ActivityManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.*
import android.net.ConnectivityManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.os.BatteryManager
import android.os.Build
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Bundle
import android.os.PowerManager
import android.util.Log
import androidx.annotation.NonNull
import androidx.core.app.NotificationCompat
import com.android.saukhyam.constants.Constants
import com.android.saukhyam.service.MyService
import io.flutter.plugin.common.MethodCall

class MainActivity: FlutterActivity() {

    private val channel = "platformChannelForFlutter"
    private lateinit var mSharedPreferences: SharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mSharedPreferences = this.getSharedPreferences(
            Constants().ALERT,
            MODE_PRIVATE
        )
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
         MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
                call, result ->
            when(call.method){
                "isConnected"->{
                    val connectionStatus = isConnected(this)
                    if(connectionStatus)
                    result.success(true) else result.success(false)
                }

                "isIgnoringBatteryOptimizations"->{
                    val res = isIgnoringBatteryOptimizations(this)
                    if(res) result.success(true) else result.success(false)
                }

                "isServiceRunningNatively"->{
                    try{
                        val service = MyService()
                        if (isMyServiceRunning(service::class.java)) {
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } catch(e:Exception){
                        result.error("failed", "Couldn't check running service", "couldn't resolve service")
                    }
                }

                "registerWithPinCode" -> {
                    // Accessing arguments-> call.arguments returns a map/object with the passes arguments as described in above comments
                    Log.v("myCHECK", "pincode-main")
                    val pincodeService = MyService()
                    if(!isMyServiceRunning(pincodeService::class.java)) {
                        saveDetails(true, mSharedPreferences, call)

                        val serviceIntent = Intent(this, pincodeService::class.java)
                        this.startService(serviceIntent)
                    } else {
                        Log.d("serviceCheck","Service Already Present")
                        //service already present
                    }

                    result.success(call.arguments.toString())
                }

                "registerWithDistrictId" -> {

                    Log.v("myCHECK", "district-main")
                    val districtIDService = MyService()
                    if(!isMyServiceRunning(districtIDService::class.java)) {
                        saveDetails(false, mSharedPreferences, call)

                        val serviceIntent = Intent(this, districtIDService::class.java)
                        this.startService(serviceIntent)
                    } else {
                        //service already present
                        Log.d("serviceCheck","Service Already Present")
                    }
                    result.success(call.arguments.toString())
                }

                "onDestroy" -> {
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


    override fun onDestroy() {
        super.onDestroy()
        if(mSharedPreferences.getString(Constants().TYPE, "") != null  &&
            mSharedPreferences.getString(Constants().TYPE, "") != "") {
            val broadcastIntent = Intent()
            broadcastIntent.action = "RestartService"
            broadcastIntent.setClass(this, BroadcastReceiver::class.java)
            this.sendBroadcast(broadcastIntent)
        }
    }

    private fun isConnected(context: Context) : Boolean {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val netInfo = cm.activeNetworkInfo

        return if(netInfo != null && netInfo.isConnectedOrConnecting) {
            val wifi = cm.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
            val mobile = cm.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
            (mobile != null && mobile.isConnectedOrConnecting) || (wifi != null && wifi.isConnectedOrConnecting)
        } else {
            false
        }
    }

    private fun isIgnoringBatteryOptimizations(context: Context): Boolean {
        val powerManager = context.applicationContext.getSystemService(Context.POWER_SERVICE) as PowerManager
        val name = context.applicationContext.packageName
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return powerManager.isIgnoringBatteryOptimizations(name)
        }
        return true
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
