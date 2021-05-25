import 'package:cowintrackerindia/models/districts/districts.dart';
import 'package:cowintrackerindia/models/states/state.dart';
import 'package:cowintrackerindia/provider/api_provider.dart';
import 'package:cowintrackerindia/provider/platform_channel_provider.dart';
import 'package:cowintrackerindia/ui/service_running.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import 'floating_modal.dart';

enum LocationMode { ByPIN, ByDistrict }

class InputDetails extends StatefulWidget {
  const InputDetails({Key? key}) : super(key: key);
  static const routeName = "input_details_pge";
  @override
  _InputDetailsState createState() => _InputDetailsState();
}

class _InputDetailsState extends State<InputDetails> {
  // bool _loading = true;
  bool _init = false;
  LocationMode _locationMode = LocationMode.ByPIN;

  ApiProvider? apiProvider;
  PlatformChannelProvider? platformChannelProvider;

  List<StateInfo>? states = [];

  List<String> listVaccine = ['ANY', 'COVISHIELD', 'COVAXIN', 'SPUTNIK V'];
  List<String> listAges = ['Any', 'Ages 18 - 45', 'Ages 45 +'];
  List<String> listDose = ['Any', 'First Dose', 'Second Dose'];
  List<String> listCost = ['Any', 'Free', 'Paid'];

  List<String> listVaccineUrl = [
    'generic.png',
    'covishield.png',
    'covaxin.png',
    'sputnikv.png'
  ];

  int? iVaccine = 0;
  int? iAge = 0;
  int? iDose = 0;
  int? iCost = 0;

  TextStyle? formElementsHeaderTextStyle;
  TextStyle? modalSheetHeader;
  TextStyle? labelTextStyle;

  @override
  void didChangeDependencies() async {
    if (!_init) {
      labelTextStyle = TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: Theme.of(context).primaryColor);
      formElementsHeaderTextStyle = TextStyle(
          fontSize: 19,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold);
      modalSheetHeader = TextStyle(
          fontSize: 22,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold);

      platformChannelProvider = Provider.of<PlatformChannelProvider>(context);
      apiProvider = Provider.of<ApiProvider>(context);
      StatesList statesData = await apiProvider!.getStates();
      states = statesData.states;

      setState(() {
        _init = true;
        apiProvider!.setLoading = false;
      });
      super.didChangeDependencies();
    }
  }

  Future<List<District>?> getDistrictsFromStateId(int stateId) async {
    Districts districts = await apiProvider!.getDistrictsByStateId(stateId);
    return districts.districts;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("CoWIN Notifier",
              style: TextStyle(color: Theme.of(context).primaryColor)),
          backgroundColor: apiProvider!.getLoading
              ? Theme.of(context).primaryColor.withOpacity(0.4)
              : Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
          actions: [
            GestureDetector(
                onTap: () async {
                  await platformChannelProvider!.deleteAlerts();
                },
                child: Icon(Icons.more_vert,
                    color: Theme.of(context).primaryColor)),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FlutterToggleTab(
                      width: MediaQuery.of(context).size.width * 0.2,
                      borderRadius: 15,
                      initialIndex: 0,
                      selectedTextStyle: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                      unSelectedTextStyle: TextStyle(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.8),
                          fontWeight: FontWeight.w400),
                      selectedIndex: _locationMode.index,
                      labels: ["PIN Code", "State/District"],
                      icons: [Icons.mail_outline, Icons.location_city],
                      selectedBackgroundColors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor
                      ],
                      unSelectedBackgroundColors: [
                        Theme.of(context).primaryColor.withOpacity(0.3),
                        Theme.of(context).primaryColor.withOpacity(0.3)
                      ],
                      selectedLabelIndex: (index) {
                        setState(() {
                          _locationMode = LocationMode.values.elementAt(index);
                        });
                        print("Selected Index $index");
                      },
                    ),
                  ),
                  SizedBox(height: 40),
                  _locationMode == LocationMode.ByPIN
                      ? EnterPinCode(
                          platformChannelProvider: platformChannelProvider,
                          context: context)
                      : EnterDistrict(
                          states: states,
                          apiProvider: apiProvider,
                          platformChannelProvider: platformChannelProvider),
                  if (_locationMode == LocationMode.ByPIN) SizedBox(height: 10),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child:
                            Text("Vaccine", style: formElementsHeaderTextStyle),
                      ),
                      SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            SizedBox(width: 15),
                            for (int i = 0; i < listVaccine.length; i++)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: vaccinePreview(
                                    listVaccine[i], listVaccineUrl[i], () {
                                  setState(() {
                                    iVaccine = i;
                                    print(listVaccine[i]);
                                  });
                                }),
                              ),
                            SizedBox(width: 15),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Text("Age Group",
                              style: formElementsHeaderTextStyle)),
                      SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(width: 20),
                            for (int i = 0; i < listAges.length; i++)
                              textTagOptions(listAges[i], i == iAge, () {
                                setState(() => iAge = i);
                              })
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: InkWell(
                      onTap: () => showMoreBottomSheet(),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                        // color: Colors.red,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("More", style: formElementsHeaderTextStyle),
                            Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 200),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(30.0))),
                child: TextButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, color: Colors.white),
                      SizedBox(width: 5),
                      Text("Get Notified",
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                    ],
                  ),
                  onPressed: () async {
                    if (_locationMode == LocationMode.ByPIN) {
                      if (platformChannelProvider!.getPincodeProv != null) {
                        if (platformChannelProvider!.getPincodeProv! > 110000 &&
                            platformChannelProvider!.getPincodeProv! < 999999) {
                          await platformChannelProvider!.registerWithPinCode(
                              listVaccine[iVaccine ?? 0],
                              iAge ?? 0,
                              iDose ?? 0,
                              iCost ?? 0);
                          Navigator.pushReplacementNamed(
                              context, ServiceAlreadyRunningPage.routeName,
                              arguments: {
                                "vaccine": listVaccine[iVaccine ?? 0],
                                "age": iAge ?? 0,
                                "dose": iDose ?? 0,
                                "cost": iCost ?? 0,
                                "pincode":
                                    platformChannelProvider!.getPincodeProv
                              });
                        } else {
                          //  TODO: SnackBar: Enter a valid pincode
                        }
                      } else {
                        //  TODO: SnackBar: Enter a pincode
                      }
                    } else if (_locationMode == LocationMode.ByDistrict) {
                      if (platformChannelProvider!.getDistrictCodeProv !=
                          null) {
                        await platformChannelProvider!.registerWithDistrictId(
                            listVaccine[iVaccine ?? 0],
                            iAge ?? 0,
                            iDose ?? 0,
                            iCost ?? 0);
                        Navigator.pushReplacementNamed(
                            context, ServiceAlreadyRunningPage.routeName,
                            arguments: {
                              "vaccine": listVaccine[iVaccine ?? 0],
                              "age": iAge ?? 0,
                              "dose": iDose ?? 0,
                              "cost": iCost ?? 0,
                              "district":
                                  platformChannelProvider!.getDistNameProv,
                              "state":
                                  platformChannelProvider!.getStateNameProv,
                              "pincode": 000000
                            });
                      }
                    }
                  },
                ),
              ),
            ),
            if (apiProvider!.getLoading)
              Container(
                color: Theme.of(context).primaryColor.withOpacity(0.4),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballScaleMultiple,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Container textTagOptions(String tagText, bool active, Function onPress) {
    return Container(
      child: GestureDetector(
          onTap: () => onPress(),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
                border: active
                    ? Border.all(
                        color: Theme.of(context).primaryColor, width: 2)
                    : Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.7),
                        width: 1),
                borderRadius: BorderRadius.circular(10.0)),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Center(
                child: Text(tagText,
                    style: active
                        ? labelTextStyle
                        : labelTextStyle!.copyWith(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.7)))),
          )),
    );
  }

  AnimatedContainer vaccinePreview(
      String vaccineName, String assetURL, Function onPress) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
          color: vaccineName == listVaccine[iVaccine!]
              ? Theme.of(context).scaffoldBackgroundColor
              : Theme.of(context).primaryColor.withOpacity(0.05),
          border: vaccineName == listVaccine[iVaccine!]
              ? Border.all(color: Theme.of(context).primaryColor, width: 2)
              : null,
          borderRadius: BorderRadius.circular(15.0)),
      child: GestureDetector(
        onTap: () => onPress(),
        child: Container(
          height: 150,
          width: 110,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(height: 1),
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.asset("assets/images/" + assetURL,
                    height: 100, fit: BoxFit.fitHeight),
              ),
              SizedBox(height: 10),
              Text(vaccineName, style: labelTextStyle),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  showMoreBottomSheet() async {
    int? iBSDose = iDose;
    int? iBSCost = iCost;
    await showFloatingModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 40),
            Text("More", style: modalSheetHeader),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Dose", style: formElementsHeaderTextStyle),
                ),
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      for (int i = 0; i < listDose.length; i++)
                        textTagOptions(listDose[i], i == iBSDose, () {
                          setModalState(() => iBSDose = i);
                        }),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Cost", style: formElementsHeaderTextStyle),
                ),
                SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(width: 10),
                      for (int i = 0; i < listCost.length; i++)
                        textTagOptions(listCost[i], i == iBSCost, () {
                          setModalState(() => iBSCost = i);
                        }),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Container(
              // height: 60,
              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 0),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(30.0))),
              child: TextButton(
                child: Text("Done",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
    setState(() {
      iCost = iBSCost;
      iDose = iBSDose;
    });
  }
}

class EnterDistrict extends StatefulWidget {
  final List<StateInfo>? states;
  final ApiProvider? apiProvider;
  final PlatformChannelProvider? platformChannelProvider;
  const EnterDistrict(
      {Key? key, this.states, this.apiProvider, this.platformChannelProvider})
      : super(key: key);

  @override
  _EnterDistrictState createState() => _EnterDistrictState();
}

class _EnterDistrictState extends State<EnterDistrict> {
  StateInfo? state;
  District? district;
  bool _init = false;

  List<District>? districts;

  Color clayColor = Color(0xFFF2F2F2);
  TextStyle? formElementsHeaderTextStyle;

  @override
  void didChangeDependencies() {
    if (!_init) {
      formElementsHeaderTextStyle = TextStyle(
          fontSize: 19,
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold);
      setState(() {
        _init = true;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      color: Color.fromRGBO(0, 0, 0, 0.001),
                      child: GestureDetector(
                        onTap: () {},
                        child: DraggableScrollableSheet(
                          initialChildSize: 0.7,
                          minChildSize: 0.5,
                          maxChildSize: 0.7,
                          builder: (_, controller) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(25.0),
                                  topRight: const Radius.circular(25.0),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.remove,
                                    color: Colors.grey[600],
                                  ),
                                  Text("State",
                                      style: formElementsHeaderTextStyle),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: ListView.builder(
                                      controller: controller,
                                      itemCount: widget.states!.length,
                                      itemBuilder: (_, index) {
                                        return ListTile(
                                          title: Text(widget.states!
                                                  .elementAt(index)
                                                  .stateName ??
                                              ""),
                                          onTap: () async {
                                            //TODO: Manage: state set by UI refreshes and states remove but still present in provider
                                            state =
                                                widget.states!.elementAt(index);
                                            district = null;
                                            widget.platformChannelProvider!
                                                    .setStateNameProv =
                                                state!.stateName!;
                                            widget.platformChannelProvider!
                                                .setDistrictCodeProv = null;
                                            widget.platformChannelProvider!
                                                .setDistNameProv = "";

                                            widget.apiProvider!.setLoading =
                                                true;
                                            Districts districtsData =
                                                await widget.apiProvider!
                                                    .getDistrictsByStateId(
                                                        state!.stateId ?? 0);
                                            districts = districtsData.districts;
                                            print(state!.stateId.toString() +
                                                " " +
                                                state!.stateName.toString());
                                            widget.apiProvider!.setLoading =
                                                false;
                                            setState(() {});
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text("State", style: formElementsHeaderTextStyle),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  height: 50,
                  width: state == null ? 50 : 120,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(15.0)),
                  child: Center(
                    child: state == null
                        ? Icon(Icons.arrow_forward_ios)
                        : Text(state == null ? "Select" : state!.stateName!),
                    // Marquee(
                    //         text: state == null ? "Select" : state!.stateName!,
                    //         blankSpace: 50.0,
                    //         velocity: 25.0,
                    //         fadingEdgeEndFraction: 0.2,
                    //         fadingEdgeStartFraction: 0.2,
                    //         showFadingOnlyWhenScrolling: true,
                    //       ),
                  ),
                ),
              ],
            ),
          ),
          if (state != null) SizedBox(height: 10),
          if (state != null)
            InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        color: Color.fromRGBO(0, 0, 0, 0.001),
                        child: GestureDetector(
                          onTap: () {},
                          child: DraggableScrollableSheet(
                            initialChildSize: 0.7,
                            minChildSize: 0.5,
                            maxChildSize: 0.7,
                            builder: (_, controller) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(25.0),
                                    topRight: const Radius.circular(25.0),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.remove,
                                      color: Colors.grey[600],
                                    ),
                                    Text("District",
                                        style: formElementsHeaderTextStyle),
                                    SizedBox(height: 10),
                                    Expanded(
                                      child: ListView.builder(
                                        controller: controller,
                                        physics: BouncingScrollPhysics(),
                                        itemCount: districts!.length,
                                        itemBuilder: (_, index) {
                                          return ListTile(
                                            title: Text(districts!
                                                    .elementAt(index)
                                                    .districtName ??
                                                ""),
                                            onTap: () async {
                                              setState(() {
                                                district =
                                                    districts!.elementAt(index);
                                                widget.platformChannelProvider!
                                                        .setDistrictCodeProv =
                                                    district!.districtId!;
                                                widget.platformChannelProvider!
                                                        .setDistNameProv =
                                                    district!.districtName!;
                                                print(district!.districtId
                                                        .toString() +
                                                    " " +
                                                    district!.districtName
                                                        .toString());
                                              });
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child:
                          Text("District", style: formElementsHeaderTextStyle)),
                  Container(
                    margin: EdgeInsets.only(
                        left: 20, right: 15, top: 15, bottom: 15),
                    height: 50,
                    width: district == null ? 50 : 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Center(
                      child: district == null
                          ? Icon(Icons.arrow_forward_ios)
                          : Text(
                              district == null
                                  ? "Select"
                                  : district!.districtName!,
                            ),
                      // Marquee(
                      //         text: district == null
                      //             ? "Select"
                      //             : district!.districtName!,
                      //         fadingEdgeStartFraction: 0.2,
                      //         showFadingOnlyWhenScrolling: true,
                      //         fadingEdgeEndFraction: 0.2,
                      //         velocity: 25.0,
                      //         blankSpace: 50.0,
                      //       ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: state != null ? 20 : 10)
        ],
      ),
    );
  }
}

class EnterPinCode extends StatefulWidget {
  final PlatformChannelProvider? platformChannelProvider;
  final BuildContext context;
  const EnterPinCode({
    Key? key,
    this.platformChannelProvider,
    required this.context,
  }) : super(key: key);

  static Color clayColor = Color(0xFFF2F2F2);
  static TextStyle formElementsHeaderTextStyle =
      TextStyle(fontSize: 19, fontWeight: FontWeight.bold);

  @override
  _EnterPinCodeState createState() => _EnterPinCodeState();
}

class _EnterPinCodeState extends State<EnterPinCode> {
  TextEditingController _pincodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Enter PIN Code",
            style: EnterPinCode.formElementsHeaderTextStyle
                .copyWith(color: Theme.of(context).primaryColor)),
        SizedBox(height: 10),
        Container(
          width: MediaQuery.of(context).size.width * 0.35,
          padding: EdgeInsets.only(top: 10),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.8),
              borderRadius: BorderRadius.circular(40.0)),
          child: Center(
            child: TextFormField(
              controller: _pincodeController,
              decoration: InputDecoration(
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  hintText: "######",
                  counter: Offstage(),
                  counterStyle: TextStyle(fontSize: 0),
                  border: InputBorder.none),
              keyboardType: TextInputType.number,
              maxLength: 6,
              // buildCounter: null,
              scrollPhysics: BouncingScrollPhysics(),
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              inputFormatters: [LengthLimitingTextInputFormatter(6)],
              textAlign: TextAlign.center,
              cursorColor: Colors.white,
              maxLengthEnforcement:
                  MaxLengthEnforcement.truncateAfterCompositionEnds,
              onChanged: (String? input) {
                if (input!.length == 6) {
                  //TODO: Check Valid number or not
                  widget.platformChannelProvider!.setPincodeProv =
                      int.parse(input);
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
