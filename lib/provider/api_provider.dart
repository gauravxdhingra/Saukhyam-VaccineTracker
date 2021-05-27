import 'dart:convert';

import 'package:cowintrackerindia/models/districts/districts.dart';
import 'package:cowintrackerindia/models/states/state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ApiProvider with ChangeNotifier {
  Dio dio = new Dio();
  String baseUrl = "https://cdn-api.co-vin.in/api";

  bool _loading = true;

  userEntry() async {
    String dateTime = DateTime.now().toIso8601String();
    var uuid = Uuid();
    Map<String, String> _data = {dateTime.toString().replaceAll(":", "-").replaceAll(".", "-"): uuid.v4()};
    print(_data);
    try {
      dio.patch(
          "https://saukhyam-4a955-default-rtdb.asia-southeast1.firebasedatabase.app/users.json",
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
          data: jsonEncode(_data));
    } catch (e) {
      print(e.toString());
    }
  }

  Future<StatesList> getStates() async {
    Response x = await dio.get(
      baseUrl + "/v2/admin/location/states",
      options: Options(
        headers: {"accept": "application/json", "Accept-Language": "hi_IN"},
      ),
    );
    return StatesList.fromJson(x.data);
  }

  Future<Districts> getDistrictsByStateId(int id) async {
    Response x = await dio.get(
      baseUrl + "/v2/admin/location/districts/" + id.toString(),
      options: Options(
        headers: {"accept": "application/json", "Accept-Language": "hi_IN"},
      ),
    );
    return Districts.fromJson(x.data);
  }

  set setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  bool get getLoading => _loading;
}
