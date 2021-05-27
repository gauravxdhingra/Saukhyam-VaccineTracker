import 'package:cowintrackerindia/provider/api_provider.dart';
import 'package:cowintrackerindia/provider/platform_channel_provider.dart';
import 'package:cowintrackerindia/ui/battery_optimization_permission.dart';
import 'package:cowintrackerindia/ui/input_details.dart';
import 'package:cowintrackerindia/ui/service_running.dart';
import 'package:cowintrackerindia/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ApiProvider>.value(value: ApiProvider()),
        ChangeNotifierProvider<PlatformChannelProvider>.value(
            value: PlatformChannelProvider()),
      ],
      child: MaterialApp(
        title: 'Saukhyam',
        theme: ThemeData(
          fontFamily: 'Calibri',
          primaryColor: Color(0xFF742C63),
          accentColor: Colors.blueGrey,
        ),
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => SplashScreen(),
          // BatteryOptimizationPermissionPage(),
          InputDetails.routeName: (context) => InputDetails(),
          ServiceAlreadyRunningPage.routeName: (context) =>
              ServiceAlreadyRunningPage(),
          BatteryOptimizationPermissionPage.routeName: (context) =>
              BatteryOptimizationPermissionPage()
        },
      ),
    );
  }
}
