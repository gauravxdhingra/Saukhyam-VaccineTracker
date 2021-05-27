package com.android.saukhyam.service

import android.app.*
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.ConnectivityManager
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import android.util.Log
import android.webkit.WebSettings
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import com.android.saukhyam.MainActivity
import com.android.saukhyam.R
import com.android.saukhyam.api.API
import com.android.saukhyam.constants.Constants
import com.android.saukhyam.model.Center
import com.android.saukhyam.model.Model
import com.android.saukhyam.model.Session
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
    private var wakeLock: PowerManager.WakeLock? = null

    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.O)
            startMyOwnForeground()
        else
            startForeground(1, persistentNotification())
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun startMyOwnForeground() {
        startForeground(2, persistentNotification())
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        stopTimerTask()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startTimer()
        return super.onStartCommand(intent, flags, startId)
    }

    private var toStop = false
    private var timer: Timer? = null
    private var timerTask: TimerTask? = null

    private fun startTimer() {

        wakeLock =
            (getSystemService(Context.POWER_SERVICE) as PowerManager).run {
                newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "MyService::lock").apply {
                    acquire()
                }
            }

        timer = Timer()
        timerTask = object : TimerTask() {
            override fun run() {
                if(toStop) {
                    wakeLock?.let {
                        if (it.isHeld) {
                            it.release()
                        }
                    }
                    timerTask = null
                    timer = null
                    return
                }
                check()
            }
        }
//        TODO: TIMER -> RELEASE
        timer!!.schedule(timerTask, Constants().TIME, Constants().TIME)
    }

    private fun stopTimerTask() {
        if (timer != null) {
            toStop=true
            wakeLock?.let {
                if (it.isHeld) {
                    it.release()
                }
            }
            timer!!.cancel()
            timer = null
        }
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
                    Log.d("myCHECK", "response successful --> ")

                    val model = response.body()!!
                    if(model.centers == null) {
                        Log.d("myCHECK", "centers null")
                        return
                    }
                    for(center in model.centers) {
                        var flag = false
                        if(center.sessions == null) {
                            Log.d("myCHECK", "sessions null")
                            continue
                        }
                        for(session in center.sessions) {
                            if(isPreferred(sharedPreferences, session, center)) {
                                notifyUser("Vaccines Available!", "Tap to book your slot on CoWIN Portal ASAP!")
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
                                notifyUser("Vaccines Available!", "Tap to book your slot on CoWIN Portal ASAP!")
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

    private fun notifyUser(title:String="", details:String="") {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            nm.createNotificationChannel(NotificationChannel("100","alert", NotificationManager.IMPORTANCE_HIGH))
        }

        val intent = Intent(Intent.ACTION_VIEW)
        intent.data = Uri.parse("https://selfregistration.cowin.gov.in/")

        val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)

        val simpleNotification = NotificationCompat.Builder(this, "100")
            .setContentTitle(title)
            .setContentText(details)
            .setSmallIcon(R.drawable.ic_launcher_transparent)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setDefaults(Notification.DEFAULT_VIBRATE)
            .setAutoCancel(true)
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

    private fun persistentNotification(): Notification {
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            nm.createNotificationChannel(
                NotificationChannel(
                    "101",
                    "background-service",
                    NotificationManager.IMPORTANCE_HIGH
                )
            )
        }

        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT)

        return NotificationCompat.Builder(this, "101")
            .setOngoing(true)
            .setContentTitle("Vaccine Alert Set")
            .setContentText("We will notify you as soon as vaccines are available!")
            .setSmallIcon(R.drawable.ic_launcher_transparent)
            .setContentIntent(pendingIntent)
            .build()
    }

}