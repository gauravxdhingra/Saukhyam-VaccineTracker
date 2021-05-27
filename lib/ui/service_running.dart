import 'package:cowintrackerindia/provider/platform_channel_provider.dart';
import 'package:cowintrackerindia/ui/input_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import 'floating_modal.dart';

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
      // await platformChannelProvider!.onDestroy();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  TextStyle _textStyle = TextStyle(fontSize: 15);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFCFDFC),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Image.asset("assets/images/notification_animation.gif",
                      fit: BoxFit.fitWidth),
                ),
                Padding(
                    padding:
                        const EdgeInsets.only(left: 25, right: 25, top: 15),
                    child: Text(
                        "We'll notify you, as soon as a preferred slot is available!",
                        style: _textStyle.copyWith(fontSize: 18),
                        textAlign: TextAlign.center)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(10.0)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextButton(
                            onPressed: () async {
                              await platformChannelProvider!.deleteAlerts();
                              Navigator.pushReplacementNamed(
                                  context, InputDetails.routeName);
                            },
                            child: Text("Stop Alert")),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0)),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextButton(
                            onPressed: () async {
                              await showMoreBottomSheet();
                            },
                            child: Text("More Details",
                                style: TextStyle(color: Colors.white))),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    Share.share(
                        'Never miss a Vaccine Slot again!\nDownload Saukhyam App https://github.com/gauravxdhingra/Saukhyam-VaccineTracker/releases/tag/v1.0 and get Instant updates on Vaccine Availability.\nAyur Arogya Saukhya 🙏\n#IndiaFightsCorona');
                  },
                  child: Container(
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset('assets/images/covid-family.png',
                              fit: BoxFit.cover),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text("Share with your\nFriends and Family",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 20),
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      )),
                )
              ],
            ),
          ),
          Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("An Initiative By ", style: _textStyle),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              child: Text("Gaurav Dhingra",
                                  style: _textStyle.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold)),
                              onTap: () async {
                                await canLaunch(
                                        "https://www.linkedin.com/in/gauravxdhingra/")
                                    ? await launch(
                                        "https://www.linkedin.com/in/gauravxdhingra/")
                                    : print("Can't Launch!");
                              },
                            ),
                            Text(" and ", style: _textStyle),
                            InkWell(
                              child: Text("Rahul Jain",
                                  style: _textStyle.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold)),
                              onTap: () async {
                                await canLaunch("https://bit.ly/mRahulJain")
                                    ? await launch("https://bit.ly/mRahulJain")
                                    : print("Can't Launch!");
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  showMoreBottomSheet() async {
    await showFloatingModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 40),
            Text("More Details",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Table(
              children: [
                TableRow(children: [
                  Text("Vaccine", textAlign: TextAlign.center),
                  Text(vaccine ?? "Any",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis)
                ]),
                if (pincode == 000000)
                  TableRow(children: [
                    Text("District/State", textAlign: TextAlign.center),
                    Text(dist! + ", " + state!, textAlign: TextAlign.center)
                  ]),
                if (pincode != 000000)
                  TableRow(children: [
                    Text("Pin Code", textAlign: TextAlign.center),
                    Text(pincode.toString(), textAlign: TextAlign.center)
                  ]),
                TableRow(children: [
                  Text("Age", textAlign: TextAlign.center),
                  Text(
                      age == 0
                          ? "Any"
                          : age == 1
                              ? "18-45 Years"
                              : "45+ Years",
                      textAlign: TextAlign.center)
                ]),
                TableRow(children: [
                  Text("Dose", textAlign: TextAlign.center),
                  Text(
                      dose == 0
                          ? "Any"
                          : dose == 1
                              ? "First Dose"
                              : "Second Dose",
                      textAlign: TextAlign.center)
                ]),
                TableRow(children: [
                  Text("Cost", textAlign: TextAlign.center),
                  Text(
                      cost == 0
                          ? "Any"
                          : cost == 1
                              ? "Free"
                              : "Paid",
                      textAlign: TextAlign.center)
                ]),
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
