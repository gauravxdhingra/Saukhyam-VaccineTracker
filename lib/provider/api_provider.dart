import 'package:cowintrackerindia/models/districts/districts.dart';
import 'package:cowintrackerindia/models/states/state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiProvider with ChangeNotifier {
  Dio dio = new Dio();
  String baseUrl = "https://cdn-api.co-vin.in/api";

  bool _loading = true;

  // Future<VaccineData> getVaccineCalender() async {
  //   // TODO: Shared Prefs
  //   // String pincode = await getPincode();
  //   // String stateCode = await getStateCode();
  //   // String distCode = await getDistCode();
  //   String pincode = "";
  //
  //   Response x = await dio.get(
  //     baseUrl + "/v2/appointment/sessions/public/calendarByPin",
  //     queryParameters: {
  //       "pincode": pincode == "" ? "125001" : pincode,
  //       "date": DateFormat('dd-MM-yyyy').format(DateTime.now())
  //     },
  //     options: Options(
  //       headers: {"accept": "application/json", "Accept-Language": "hi_IN"},
  //     ),
  //   );
  //   // print(x.data);
  //   VaccineData vdata = VaccineData.fromJson(x.data);
  //   print(vdata.centers);
  //   return vdata;
  // }

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
