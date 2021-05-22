import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlatformChannelProvider with ChangeNotifier {
  static const platform = const MethodChannel('platformChannelForFlutter');

  int? _pincodeProv;
  int? _districtCodeProv;

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
      print(result);
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
      print(result);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  int? get getPincodeProv => _pincodeProv;
  int? get getDistrictCodeProv => _districtCodeProv;

  set setPincodeProv(int value) {
    _pincodeProv = value;
    notifyListeners();
  }

  set setDistrictCodeProv(int value) {
    _districtCodeProv = value;
    notifyListeners();
  }
}
