import 'package:cowintrackerindia/provider/api_provider.dart';
import 'package:cowintrackerindia/provider/platform_channel_provider.dart';
import 'package:cowintrackerindia/ui/input_details.dart';
import 'package:cowintrackerindia/ui/service_running.dart';
import 'package:cowintrackerindia/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

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
        title: 'Flutter Demo',
        theme: ThemeData(
          fontFamily: 'Calibri',
          primaryColor: Color(0xFF742C63),
          accentColor: Colors.blueGrey,
          bottomSheetTheme:
              BottomSheetThemeData(backgroundColor: Colors.black54),
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) =>
              // ServiceAlreadyRunningPage(),
              SplashScreen(),
          InputDetails.routeName: (context) => InputDetails(),
          ServiceAlreadyRunningPage.routeName: (context) =>
              ServiceAlreadyRunningPage(),
        },
      ),
    );
  }
}

// TODO: Platform Channel Test
// TODO: Beautify State and District Choser

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key, required this.title}) : super(key: key);
//
//   final String title;
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   static const platform = const MethodChannel('platformChannelForFlutter');
//
//   // Get battery level.
//   String _batteryLevel = 'Unknown battery level.';
//
//   Future<void> _getBatteryLevel() async {
//     String batteryLevel;
//     try {
//       final int result = await platform.invokeMethod('getBatteryLevel');
//       batteryLevel = 'Battery level at $result % .';
//     } on PlatformException catch (e) {
//       batteryLevel = "Failed to get battery level: '${e.message}'.";
//     }
//
//     setState(() {
//       _batteryLevel = batteryLevel;
//     });
//   }
//
//   int _counter = 0;
//
//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             ElevatedButton(
//               child: Text('Get Battery Level'),
//               onPressed: _getBatteryLevel,
//             ),
//             Text(_batteryLevel),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
