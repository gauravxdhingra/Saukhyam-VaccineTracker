import 'package:cowintrackerindia/provider/platform_channel_provider.dart';
import 'package:cowintrackerindia/ui/service_running.dart';
import 'package:flutter/material.dart';
import 'package:open_settings/open_settings.dart';
import 'package:provider/provider.dart';

import 'input_details.dart';

class BatteryOptimizationPermissionPage extends StatefulWidget {
  const BatteryOptimizationPermissionPage({Key? key}) : super(key: key);
  static const routeName = 'battery_optimization_Permission_page';
  @override
  _BatteryOptimizationPermissionPageState createState() =>
      _BatteryOptimizationPermissionPageState();
}

class _BatteryOptimizationPermissionPageState
    extends State<BatteryOptimizationPermissionPage>
    with WidgetsBindingObserver {
  bool _init = false;
  PlatformChannelProvider? platformChannelProvider;

  bool _flag = true;
  bool isIgnoring = false;

  @override
  void didChangeDependencies() {
    if (!_init) {
      platformChannelProvider = Provider.of<PlatformChannelProvider>(context);
      WidgetsBinding.instance!.addObserver(this);
      ValueNotifier(_flag).addListener(() {
        print("***********");
      });
      setState(() {
        _init = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      isIgnoring =
          await platformChannelProvider!.isIgnoringBatteryOptimizations();
      setState(() {});
      print("resumed");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/battery_optimization.gif'),
                  SizedBox(height: 20),
                  Text("Permission Needed",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 23,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text(
                      "In order to serve you the best user experience, we need you to turn off Battery Optimization Settings for this app, so that we can deliver notifications timely.",
                      textAlign: TextAlign.center),
                  SizedBox(height: 40),
                  GestureDetector(
                    onTap: () async {
                      isIgnoring = await platformChannelProvider!
                          .isIgnoringBatteryOptimizations();
                      if (isIgnoring) {
                        bool isServiceAlreadyRunning =
                            await platformChannelProvider!.getServiceRunning();
                        if (isServiceAlreadyRunning) {
                          Navigator.pushReplacementNamed(
                              context, ServiceAlreadyRunningPage.routeName);
                        } else {
                          Navigator.pushReplacementNamed(
                              context, InputDetails.routeName);
                        }
                      } else {
                        await OpenSettings
                            .openIgnoreBatteryOptimizationSetting();
                      }
                      // if (_flag) {
                      //   await OpenSettings
                      //       .openIgnoreBatteryOptimizationSetting();
                      //   setState(() {
                      //     _flag = false;
                      //     isIgnoring = true;
                      //   });
                      // }
                      //
                      // if (!_flag) {
                      //   isIgnoring = await platformChannelProvider!
                      //       .isIgnoringBatteryOptimizations();
                      //   if (isIgnoring) {
                      //     bool isServiceAlreadyRunning =
                      //         await platformChannelProvider!
                      //             .getServiceRunning();
                      //     if (isServiceAlreadyRunning) {
                      //       await Future.delayed(Duration(milliseconds: 700));
                      //       Navigator.pushReplacementNamed(
                      //           context, ServiceAlreadyRunningPage.routeName);
                      //     } else {
                      //       Future.delayed(Duration(milliseconds: 700));
                      //       Navigator.pushReplacementNamed(
                      //           context, InputDetails.routeName);
                      //     }
                      //   } else {
                      //     setState(() {
                      //       _flag = true;
                      //     });
                      //   }
                      // }
                    },
                    child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                            color: !isIgnoring
                                ? Theme.of(context).primaryColor
                                : Colors.green,
                            borderRadius: BorderRadius.circular(15.0)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Center(
                          child: Text(
                              !isIgnoring
                                  ? "Open Battery Optimization Settings"
                                  : "Proceed",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15)),
                        )),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: TextButton(
                  child: Text(
                      "I acknowledge that I may miss crucial notifications and wish to skip",
                      textAlign: TextAlign.center),
                  onPressed: () async {
                    await platformChannelProvider!
                        .setBatteryOptimization(false);
                    bool isServiceAlreadyRunning =
                        await platformChannelProvider!.getServiceRunning();
                    if (isServiceAlreadyRunning) {
                      await Future.delayed(Duration(milliseconds: 700));
                      Navigator.pushReplacementNamed(
                          context, ServiceAlreadyRunningPage.routeName);
                    } else {
                      Future.delayed(Duration(milliseconds: 700));
                      Navigator.pushReplacementNamed(
                          context, InputDetails.routeName);
                    }
                  },
                ),
              ))
        ],
      ),
    );
  }
}
