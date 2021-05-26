import 'package:cowintrackerindia/provider/platform_channel_provider.dart';
import 'package:cowintrackerindia/ui/service_running.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'battery_optimization_permission.dart';
import 'input_details.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const routeName = "splash_screen";
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _init = false;
  PlatformChannelProvider? platformChannelProvider;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (!_init) {
      _init = true;
      platformChannelProvider = Provider.of<PlatformChannelProvider>(context);
      bool isServiceAlreadyRunning =
          await platformChannelProvider!.getServiceRunning();

      bool isIgnoringBatteryOptimizations =
          await platformChannelProvider!.isIgnoringBatteryOptimizations();

      bool? batteryOptimizationsIgnoredUser =
          await platformChannelProvider!.getBatteryOptimization();
      // True: battery Optimization: off, False: Battery Optimization: on

      if (batteryOptimizationsIgnoredUser == null)
        batteryOptimizationsIgnoredUser = true;

      if (isIgnoringBatteryOptimizations || !batteryOptimizationsIgnoredUser) {
        if (isServiceAlreadyRunning) {
          await Future.delayed(Duration(milliseconds: 700));
          Navigator.pushReplacementNamed(
              context, ServiceAlreadyRunningPage.routeName);
        } else {
          Future.delayed(Duration(milliseconds: 700));
          Navigator.pushReplacementNamed(context, InputDetails.routeName);
        }
      } else {
        await Future.delayed(Duration(milliseconds: 700));
        Navigator.pushReplacementNamed(
            context, BatteryOptimizationPermissionPage.routeName);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child:
              Image.asset('assets/images/logo.png', width: 150, height: 150)),
    );
  }
}
