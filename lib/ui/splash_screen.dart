import 'package:cowintrackerindia/provider/platform_channel_provider.dart';
import 'package:cowintrackerindia/ui/input_details.dart';
import 'package:cowintrackerindia/ui/service_running.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const routeName = "splash_screen";
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  PlatformChannelProvider? platformChannelProvider;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    platformChannelProvider = Provider.of<PlatformChannelProvider>(context);
    bool isServiceAlreadyRunning =
        await platformChannelProvider!.getServiceRunning();
    // platformChannelProvider!.dispose();
    if (isServiceAlreadyRunning) {
      Future.delayed(Duration(milliseconds: 700)).then((value) =>
          Navigator.pushReplacementNamed(
              context, ServiceAlreadyRunningPage.routeName));
    } else {
      Future.delayed(Duration(milliseconds: 700)).then((value) =>
          Navigator.pushReplacementNamed(context, InputDetails.routeName));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          "CoWIN Notifier",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
