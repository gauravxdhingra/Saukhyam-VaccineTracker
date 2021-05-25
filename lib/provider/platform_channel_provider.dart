import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlatformChannelProvider with ChangeNotifier {
  static const platform = const MethodChannel('platformChannelForFlutter');

  int? _pincodeProv;
  int? _districtCodeProv;

  String? _distNameProv;
  String? _stateNameProv;

  Future<void> getBatteryLevel() async {
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      print(result);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> registerWithPinCode(
      String vaccine, int age, int dose, int cost) async {
    //PINCODE: (6 Digit Pincode)
    //VACCINE: (ANY -> ANY) (COVISHIELD) (COVAXIN) (SPUTNIK V)
    //AGE: (0-Any) (1-> 18-45) (2 -> 45+)
    //DOSE: (0-Any) (1-First Dose) (2-Second Dose)
    //COST: (0-Any) (1-Free) (2-Paid)

    try {
      final String result = await platform.invokeMethod('registerWithPinCode', {
        "pincode": getPincodeProv,
        "vaccine": vaccine,
        "age": age,
        "dose": dose,
        "cost": cost
      });
      await setServiceRunning(true);
      await setAge(age);
      await setDistCode(0);
      await setDistName("");
      await setPincode(getPincodeProv!);
      await setStateCode(0);
      await setStateName("");
      await setVaccine(vaccine);
      await setDose(dose);
      await setCost(cost);
      print("Result Fromm Native: " + result);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> registerWithDistrictId(
      String vaccine, int age, int dose, int cost) async {
    //DISTRICTID: (District ID)
    //VACCINE: (ANY -> ANY) (COVISHIELD) (COVAXIN) (SPUTNIK V)
    //AGE: (0-Any) (1-> 18-45) (2 -> 45+)
    //DOSE: (0-Any) (1-First Dose) (2-Second Dose)
    //COST: (0-Any) (1-Free) (2-Paid)

    try {
      final String result =
          await platform.invokeMethod('registerWithDistrictId', {
        "districtId": getDistrictCodeProv,
        "vaccine": vaccine,
        "age": age,
        "dose": dose,
        "cost": cost
      });
      await setServiceRunning(true);
      await setAge(age);
      await setDistCode(getDistrictCodeProv!);
      await setDistName(getStateNameProv!);
      await setPincode(000000);
      await setStateCode(0);
      await setStateName(getStateNameProv!);
      await setVaccine(vaccine);
      await setDose(dose);
      await setCost(cost);

      print("Result Fromm Native: " + result);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<void> onDestroy() async {
    try {
      await platform.invokeMethod('onDestroy');
      print("OnDestroy called on native");
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Future<bool> deleteAlerts() async {
    bool result = false;
    try {
      result = await platform.invokeMethod('deleteAlerts');
      await setServiceRunning(false);
      await setAge(0);
      await setDistCode(0);
      await setDistName("");
      await setPincode(000000);
      await setStateCode(0);
      await setStateName("");
      await setVaccine("ANY");
      await setDose(0);
      await setCost(0);

      print("Alert Deleted");
    } on PlatformException catch (e) {
      print(e.message);
      result = false;
    }
    return result;
  }

  // *******************************SHARED PREFERENCES****************************************
  // *******************************SHARED PREFERENCES****************************************
  // *******************************SHARED PREFERENCES****************************************

  setVisitingFlag() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("alreadyVisited", true);
  }

  getVisitingFlag() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool alreadyVisited = preferences.getBool("alreadyVisited") ?? false;
    return alreadyVisited;
  }

//

  setServiceRunning(bool service) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("serviceRunning", service);
  }

  Future<bool> getServiceRunning() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    bool serviceRunning = preferences.getBool("serviceRunning") ?? false;
    return serviceRunning;
  }

  //

  setPincode(int pincode) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("pincode", pincode);
  }

  Future<int> getPincode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int pincode = preferences.getInt("pincode") ?? 000000;
    return pincode;
  }

//

  setStateCode(int stateCode) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("stateCode", stateCode);
  }

  Future<int> getStateCode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int stateCode = preferences.getInt("stateCode") ?? 0;
    return stateCode;
  }

//

  setStateName(String stateName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("stateName", stateName);
  }

  Future<String> getStateName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String stateName = preferences.getString("stateName") ?? "";
    return stateName;
  }

//

  setDistCode(int distCode) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("distCode", distCode);
  }

  Future<int> getDistCode() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int distCode = preferences.getInt("distCode") ?? 0;
    return distCode;
  }

//

  setDistName(String distName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("distName", distName);
  }

  Future<String> getDistName() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String distName = preferences.getString("distName") ?? "";
    return distName;
  }

//

  setAge(int age) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("age", age);
  }

  Future<int> getAge() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int age = preferences.getInt('age') ?? 0;
    return age;
  }

//

  setVaccine(String vaccine) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("vaccine", vaccine);
  }

  Future<String> getVaccine() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String vaccine = preferences.getString("vaccine") ?? "";
    return vaccine;
  }

  //

  setDose(int dose) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("dose", dose);
  }

  Future<int> getDose() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int dose = preferences.getInt('dose') ?? 0;
    return dose;
  }

  //

  setCost(int cost) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt("cost", cost);
  }

  Future<int> getCost() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int cost = preferences.getInt('cost') ?? 0;
    return cost;
  }

  // *******************************SHARED PREFERENCES****************************************
  // *******************************SHARED PREFERENCES****************************************
  // *******************************SHARED PREFERENCES****************************************

  int? get getPincodeProv => _pincodeProv;
  int? get getDistrictCodeProv => _districtCodeProv;

  set setPincodeProv(int value) {
    _pincodeProv = value;
    notifyListeners();
  }

  set setDistrictCodeProv(int? value) {
    _districtCodeProv = value;
    notifyListeners();
  }

  String? get getDistNameProv => _distNameProv;
  String? get getStateNameProv => _stateNameProv;

  set setDistNameProv(String value) {
    _distNameProv = value;
  }

  set setStateNameProv(String value) {
    _stateNameProv = value;
  }
}
