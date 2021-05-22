package com.example.cowintrackerindia.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.ConnectivityManager
import android.os.Build
import android.os.IBinder
import android.util.Log
import android.webkit.WebSettings
import androidx.core.app.NotificationCompat
import com.example.cowintrackerindia.R
import com.example.cowintrackerindia.api.API
import com.example.cowintrackerindia.constants.Constants
import com.example.cowintrackerindia.model.Center
import com.example.cowintrackerindia.model.Model
import com.example.cowintrackerindia.model.Session
import okhttp3.OkHttpClient
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.text.SimpleDateFormat
import java.util.*

class MyService : Service() {

    private lateinit var mSharedPreferences: SharedPreferences

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        stopTimerTask()
        createBS()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startTimer()
        return super.onStartCommand(intent, flags, startId)
    }

    private var timer: Timer? = null
    private var timerTask: TimerTask? = null

    private fun startTimer() {
        timer = Timer()
        timerTask = object : TimerTask() {
            override fun run() {
                check()
            }
        }
        timer!!.schedule(timerTask, 3000, 15 * 60 * 1000)
    }

    private fun stopTimerTask() {
        if (timer != null) {
            timer!!.cancel()
            timer = null
        }
    }

    private fun createBS() {
        val broadcastIntent = Intent()
        broadcastIntent.action = "RestartService"
        broadcastIntent.setClass(this, BroadcastReceiver::class.java)
        this.sendBroadcast(broadcastIntent)
    }

    private fun check() {
        if(!isConnected(this)) {
            return
        }

        mSharedPreferences = this.getSharedPreferences(
            Constants().ALERT,
            MODE_PRIVATE
        )
        if(mSharedPreferences.getString(Constants().TYPE, "") == null
            || mSharedPreferences.getString(Constants().TYPE, "") == "") {
            return
        }

        val retrofit: Retrofit = Retrofit.Builder()
            .client(getOkHttpClient())
            .baseUrl("https://cdn-api.co-vin.in/api/")
            .addConverterFactory(GsonConverterFactory.create())
            .build()
        val service = retrofit.create(API::class.java)


        if(mSharedPreferences.getString(Constants().TYPE, "")!! == "pincode") {
            callPincodeAPI(service, mSharedPreferences)
        } else {
            callDistrictIdAPI(service, mSharedPreferences)
        }

    }

    private fun callPincodeAPI(service: API, sharedPreferences: SharedPreferences) {
        val pincode = sharedPreferences.getString(Constants().PINCODE, "")!!

        service.getCalendarByPIN(pincode, getDateString()).enqueue(object : Callback<Model> {
            override fun onResponse(call: Call<Model>, response: Response<Model>) {
                if (response.isSuccessful) {
                    val model = response.body()!!
                    for(center in model.centers) {
                        var flag = false
                        for(session in center.sessions) {
                            if(isPreferred(sharedPreferences, session, center)) {
                                notifyUser()
                                flag = true
                                break
                            }
                        }
                        if(flag) {
                            break
                        }
                    }
                } else {
                    Log.d("myCHECK", "response not successful --> " + response.raw())
                }
            }

            override fun onFailure(call: Call<Model>, t: Throwable) {
                Log.d("myCHECK", t.localizedMessage)
            }
        })
    }

    private fun callDistrictIdAPI(service: API, sharedPreferences: SharedPreferences) {
        val districtId = sharedPreferences.getString(Constants().DISTRICTID, "")!!

        service.getCalendarByDISTRICT(districtId, getDateString()).enqueue(object : Callback<Model> {
            override fun onResponse(call: Call<Model>, response: Response<Model>) {
                if (response.isSuccessful) {
                    val model = response.body()!!
                    for(center in model.centers) {
                        var flag = false
                        for(session in center.sessions) {
                            if(isPreferred(sharedPreferences, session, center)) {
                                notifyUser()
                                flag = true
                                break
                            }
                        }
                        if(flag) {
                            break
                        }
                    }
                } else {
                    Log.d("myCHECK", "response not successful --> " + response.raw())
                }
            }

            override fun onFailure(call: Call<Model>, t: Throwable) {
                Log.d("myCHECK", t.localizedMessage)
            }
        })
    }

    private fun notifyUser() {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            nm.createNotificationChannel(NotificationChannel("100","alert", NotificationManager.IMPORTANCE_HIGH))
        }
        val simpleNotification = NotificationCompat.Builder(this, "100")
            .setContentTitle("Vaccine Available!!")
            .setContentText("Check the Co-Win website ASAP to confirm your slot")
            .setSmallIcon(R.drawable.launch_background)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .build()

        nm.notify(1, simpleNotification)
    }

    private fun isPreferred(sharedPreferences: SharedPreferences, session: Session, center: Center) : Boolean {
        if(session.available_capacity == 0) {
            return false
        }

        val vaccine = sharedPreferences.getString(Constants().VACCINE, "")!!
        val dose = sharedPreferences.getString(Constants().DOSE, "")!!.toInt()
        val cost = sharedPreferences.getString(Constants().COST, "")!!.toInt()
        val age = sharedPreferences.getString(Constants().AGE, "")!!.toInt()

        if(vaccine == "ANY" && dose == 0 && cost == 0 && age == 0) {
            return true
        }

        //check Vaccine
        if(vaccine != "ANY" && session.vaccine != vaccine) {
            return false
        }

        //check Dose
        if(dose != 0) {
            if(dose == 1) {
                if(session.available_capacity_dose1 == 0) {
                    return false
                }
            } else {
                if(session.available_capacity_dose2 == 0) {
                    return false
                }
            }
        }

        //check Cost
        if(cost != 0) {
            if(cost == 1) {
                if(center.fee_type != "Free") {
                    return false
                }
            } else {
                if(center.fee_type == "Free") {
                    return false
                }
            }
        }

        //check Age
        if(age != 0) {
            if(age == 1) {
                if(session.min_age_limit != 18) {
                    return false
                }
            } else {
                if(session.min_age_limit != 45) {
                    return false
                }
            }
        }

        return true
    }

    private fun getDateString() : String {
        val date = Date()
        val sdf = SimpleDateFormat("dd-MM-yyyy")
        val myDate = sdf.format(date)
        Log.d("myCHECK", "DATE --> $myDate")
        return myDate
    }

    private fun getOkHttpClient(): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor { chain ->
                val request = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                    chain.request()
                        .newBuilder()
                        .removeHeader("User-Agent")
                        .addHeader("User-Agent", WebSettings.getDefaultUserAgent(this@MyService))
                        .build()
                } else {
                    TODO("VERSION.SDK_INT < JELLY_BEAN_MR1")
                }
                chain.proceed(request)
            }.build()
    }

    private fun isConnected(context: Context) : Boolean {
        val cm = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val netInfo = cm.activeNetworkInfo

        if(netInfo != null && netInfo.isConnectedOrConnecting) {
            val wifi = cm.getNetworkInfo(ConnectivityManager.TYPE_WIFI)
            val mobile = cm.getNetworkInfo(ConnectivityManager.TYPE_MOBILE)
            return (mobile != null && mobile.isConnectedOrConnecting) || (wifi != null && wifi.isConnectedOrConnecting)
        } else {
            return false
        }
    }

}