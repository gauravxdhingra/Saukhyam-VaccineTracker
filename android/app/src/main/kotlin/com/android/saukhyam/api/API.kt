package com.android.saukhyam.api

import com.android.saukhyam.model.Model
import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Query

interface API {

    @GET("v2/appointment/sessions/public/calendarByPin")
    fun getCalendarByPIN(
        @Query("pincode") pincode: String,
        @Query("date") date: String
    ) : Call<Model>

    @GET("v2/appointment/sessions/public/calendarByDistrict")
    fun getCalendarByDISTRICT(
        @Query("district_id") district_id: String,
        @Query("date") date: String
    ) : Call<Model>

}