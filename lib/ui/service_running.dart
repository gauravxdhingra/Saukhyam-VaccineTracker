import 'package:cowintrackerindia/provider/platform_channel_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServiceAlreadyRunningPage extends StatefulWidget {
  const ServiceAlreadyRunningPage({Key? key}) : super(key: key);
  static const routeName = "service_Already_running_page";
  @override
  _ServiceAlreadyRunningPageState createState() =>
      _ServiceAlreadyRunningPageState();
}

class _ServiceAlreadyRunningPageState extends State<ServiceAlreadyRunningPage>
    with WidgetsBindingObserver {
  bool _init = false;

  PlatformChannelProvider? platformChannelProvider;
  bool? usingSharedPrefs;

  int? pincode;
  String? vaccine;
  int? age;
  int? cost;
  int? dose;
  String? dist;
  String? state;

  @override
  void didChangeDependencies() async {
    if (!_init) {
      WidgetsBinding.instance!.addObserver(this);
      platformChannelProvider = Provider.of<PlatformChannelProvider>(context);
      if (ModalRoute.of(context)!.settings.arguments == null) {
        usingSharedPrefs = true;
        bool isServiceRunning =
            await platformChannelProvider!.getServiceRunning();

        if (isServiceRunning) {
          pincode = await platformChannelProvider!.getPincode();
          vaccine = await platformChannelProvider!.getVaccine();
          age = await platformChannelProvider!.getAge();
          cost = await platformChannelProvider!.getCost();
          dose = await platformChannelProvider!.getDose();
          if (pincode == 000000) {
            dist = await platformChannelProvider!.getDistName();
            state = await platformChannelProvider!.getStateName();
          }
        }
      } else {
        usingSharedPrefs = false;
        Map args = ModalRoute.of(context)!.settings.arguments as Map;
        pincode = args["pincode"];
        vaccine = args["vaccine"];
        age = args["age"];
        cost = args["cost"];
        dose = args["dose"];
        if (pincode == 000000) {
          dist = args["district"];
          state = args["state"];
        }
      }
      setState(() {
        _init = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.detached) {
      await platformChannelProvider!.onDestroy();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  static Color clayColor = Color(0xFFF2F2F2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await platformChannelProvider!.deleteAlerts();
          },
          child: Icon(Icons.delete)),
      backgroundColor: clayColor,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 170),
              child: Icon(Icons.notifications_none, size: 100),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
                  child: Text(
                      pincode == 000000
                          ? 'Alert set for ${cost == 0 ? "" : cost == 1 ? "Free" : "Paid"} ${vaccine == "ANY" ? "COVID Vaccine" : vaccine} in $dist, $state for ${dose == 0 ? "" : dose == 1 ? "First Dose" : "Second Dose"} ${age == 0 ? "" : age == 1 ? "for Ages 18-45 Years" : "for Ages 45+ Years"}'
                          : 'Alert set for ${cost == 0 ? "" : cost == 1 ? "Free" : "Paid"} ${vaccine == "ANY" ? "COVID Vaccine" : vaccine} for your Pin Code $pincode for ${dose == 0 ? "" : dose == 1 ? "First Dose" : "Second Dose"} ${age == 0 ? "" : age == 1 ? "for Ages 18-45 Years" : "for Ages 45+ Years"}',
                      textAlign: TextAlign.center),
                ),
                Container(
                  color: Colors.grey.withOpacity(0.6),
                  height: 100,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                      child: Text("Share With Your Friends and Family",
                          textAlign: TextAlign.center)),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Text(
                  "We'll Notify You, As Soon As A Preferred Slot Is Available!",
                  textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}
