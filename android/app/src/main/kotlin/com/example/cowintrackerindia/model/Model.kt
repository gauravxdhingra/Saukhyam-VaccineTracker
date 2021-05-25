package com.example.cowintrackerindia.model

import androidx.annotation.Keep

@Keep
data class Model(
    val centers: ArrayList<Center>
);


@Keep
data class Center(
    val center_id: Int,
    val name: String,
    val address: String,
    val state_name: String,
    val district_name: String,
    val block_name: String,
    val pincode: Int,
    val from: String,
    val to: String,
    val fee_type: String,
    val sessions: ArrayList<Session>
);


@Keep
data class Session(
    val session_id: String,
    val date: String,
    val available_capacity: Int,
    val min_age_limit: Int,
    val vaccine: String,
    val slots: ArrayList<String>,
    val available_capacity_dose1: Int,
    val available_capacity_dose2: Int
);