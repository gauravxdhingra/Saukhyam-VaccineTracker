import 'package:clay_containers/clay_containers.dart';
import 'package:cowintrackerindia/models/districts/districts.dart';
import 'package:cowintrackerindia/models/states/state.dart';
import 'package:cowintrackerindia/provider/api_provider.dart';
import 'package:cowintrackerindia/provider/platform_channel_provider.dart';
import 'package:cowintrackerindia/ui/service_running.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:select_dialog/select_dialog.dart';

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

  Map<String, Function> formElementsMap = {};

  List<String> listVaccine = ['ANY', 'COVISHIELD', 'COVAXIN', 'SPUTNIK V'];
  List<String> listAges = ['Any', 'Ages 18 - 45', 'Ages 45 +'];
  List<String> listDose = ['Any', 'First Dose', 'Second Dose'];
  List<String> listCost = ['Any', 'Free', 'Paid'];

  int? iVaccine;
  int? iAge;
  int? iDose;
  int? iCost;

  Color clayColor = Color(0xFFF2F2F2);

  @override
  void didChangeDependencies() async {
    if (!_init) {
      apiProvider = Provider.of<ApiProvider>(context);
      StatesList statesData = await apiProvider!.getStates();
      states = statesData.states;

      platformChannelProvider =
          Provider.of<PlatformChannelProvider>(context, listen: false);

      formElementsMap = {
        "Vaccine": showVaccineBottomSheet,
        "Age Group": showAgeBottomSheet,
        "Dose": showDoseBottomSheet,
        "Cost": showCostBottomSheet,
      };
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
  void dispose() async {
    await platformChannelProvider!.onDestroy();
    super.dispose();
  }

  TextStyle formElementsHeaderTextStyle =
      TextStyle(fontSize: 17, color: Colors.black.withOpacity(0.7));

  TextStyle modalSheetHeader =
      TextStyle(fontSize: 22, color: Colors.black.withOpacity(0.7));

  TextStyle modalPreviewItemsTextStyle = TextStyle(fontSize: 17);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: clayColor,
        appBar: AppBar(
          backgroundColor: clayColor,
          title: Text(
            "CoWIN Notifier",
            style: TextStyle(color: Colors.black.withOpacity(0.4)),
          ),
          elevation: 0,
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () async {
                await platformChannelProvider!.deleteAlerts();
              },
              child: Container(
                color: clayColor,
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                child: ClayContainer(
                  child: Icon(Icons.more_vert, color: Colors.grey),
                  borderRadius: 10.0,
                  color: clayColor,
                  width: 40,
                ),
              ),
            ),
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
                    child: NeumorphicToggle(
                      children: [
                        ToggleElement(
                          foreground: Center(child: Text("PIN Code")),
                          background: Center(
                              child: Text(
                            "PIN Code",
                            style:
                                TextStyle(color: Colors.black.withOpacity(0.4)),
                          )),
                        ),
                        ToggleElement(
                          foreground: Center(child: Text("State/District")),
                          background: Center(
                              child: Text(
                            "State/District",
                            style:
                                TextStyle(color: Colors.black.withOpacity(0.4)),
                          )),
                        )
                      ],
                      thumb: Neumorphic(
                        style: NeumorphicStyle(
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.all(Radius.circular(15))),
                        ),
                      ),
                      isEnabled: true,
                      onChanged: (int newIdx) {
                        setState(() {
                          _locationMode = LocationMode.values.elementAt(newIdx);
                        });
                      },
                      selectedIndex: _locationMode.index,
                    ),
                  ),
                  SizedBox(height: 40),
                  _locationMode == LocationMode.ByPIN
                      ? EnterPinCode(
                          platformChannelProvider: platformChannelProvider)
                      : EnterDistrict(
                          states: states,
                          apiProvider: apiProvider,
                          platformChannelProvider: platformChannelProvider),
                  if (_locationMode == LocationMode.ByPIN) SizedBox(height: 10),
                  for (int i = 0; i < formElementsMap.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 15),
                          formElementsBuilder(formElementsMap.keys.elementAt(i),
                              formElementsMap.values.elementAt(i)),
                        ],
                      ),
                    ),
                  SizedBox(height: 100),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: ClayContainer(
                  color: clayColor,
                  child: TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none),
                        SizedBox(width: 5),
                        Text("Get Notified"),
                      ],
                    ),
                    onPressed: () async {
                      if (_locationMode == LocationMode.ByPIN) {
                        if (platformChannelProvider!.getPincodeProv != null) {
                          if (platformChannelProvider!.getPincodeProv! >
                                  110000 &&
                              platformChannelProvider!.getPincodeProv! <
                                  999999) {
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
            ),
            if (apiProvider!.getLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    child: LoadingIndicator(
                      indicatorType: Indicator.ballScaleMultiple,
                      color: clayColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Row formElementsBuilder(String title, Function onPress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: formElementsHeaderTextStyle),
        GestureDetector(
          onTap: () => onPress(),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            height: 50,
            width: getFormButtonText(title) == "Choose" ? 50 : 120,
            child: ClayContainer(
                child: Center(
                  child: getFormButtonText(title) != "Choose"
                      ? Text(getFormButtonText(title))
                      : Icon(Icons.arrow_forward_ios),
                ),
                color: clayColor,
                borderRadius: 15.0),
          ),
        ),
      ],
    );
  }

  String getFormButtonText(String title) {
    switch (title) {
      case "Vaccine":
        if (iVaccine == null)
          return "Choose";
        else
          return listVaccine[iVaccine!];
      case "Age Group":
        if (iAge == null)
          return "Choose";
        else
          return listAges[iAge!];
      case "Dose":
        if (iDose == null)
          return "Choose";
        else
          return listDose[iDose!];
      case "Cost":
        if (iCost == null)
          return "Choose";
        else
          return listCost[iCost!];
      default:
        return "Choose";
    }
  }

  void bottomSheet(String heading, Widget child) {
    showFloatingModalBottomSheet(
      context: context,
      backgroundColor: clayColor,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 40),
          Text(heading, style: modalSheetHeader),
          SizedBox(height: 20),
          child,
          SizedBox(height: 20)
        ],
      ),
    );
  }

  showVaccineBottomSheet() {
    bottomSheet(
      "Vaccine",
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Row(
          children: [
            SizedBox(width: 30),
            vaccinePreview("ANY", "dose1.png", () {
              setState(() => iVaccine = 0);
            }),
            SizedBox(width: 30),
            vaccinePreview("COVISHIELD", "covishield.png", () {
              setState(() => iVaccine = 1);
            }),
            SizedBox(width: 30),
            vaccinePreview("COVAXIN", "covaxin.jpg", () {
              setState(() => iVaccine = 2);
            }),
            SizedBox(width: 30),
            vaccinePreview("SPUTNIK V", "sputnikv.png", () {
              setState(() => iVaccine = 3);
            }),
            SizedBox(width: 30),
          ],
        ),
      ),
    );
  }

  showAgeBottomSheet() {
    bottomSheet(
      "Age Group",
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Row(
          children: [
            SizedBox(width: 30),
            agePreview("Any", () {
              setState(() => iAge = 0);
            }),
            SizedBox(width: 30),
            agePreview("18-45 Years", () {
              setState(() => iAge = 1);
            }),
            SizedBox(width: 30),
            agePreview("45+ Years", () {
              setState(() => iAge = 2);
            }),
            SizedBox(width: 30),
          ],
        ),
      ),
    );
  }

  showDoseBottomSheet() {
    bottomSheet(
      "Dose",
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Row(
          children: [
            SizedBox(width: 30),
            //TODO: Option: ANY
            dosePreview("Any", "dose1.png", () {
              setState(() => iDose = 0);
            }),
            SizedBox(width: 30),
            dosePreview("First Dose", "dose1.png", () {
              setState(() => iDose = 1);
            }),
            SizedBox(width: 30),
            dosePreview("Second Dose", "dose2.jpg", () {
              setState(() => iDose = 2);
            }),
            SizedBox(width: 30),
          ],
        ),
      ),
    );
  }

  showCostBottomSheet() {
    bottomSheet(
      "Cost",
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Row(
          children: [
            SizedBox(width: 30),
            costPreview("Any", () {
              setState(() => iCost = 0);
            }),
            SizedBox(width: 30),
            costPreview("Free", () {
              setState(() => iCost = 1);
            }),
            SizedBox(width: 30),
            costPreview("Paid", () {
              setState(() => iCost = 2);
            }),
            SizedBox(width: 30),
          ],
        ),
      ),
    );
  }

  Container agePreview(String ageText, Function onPress) {
    return Container(
      child: GestureDetector(
          onTap: () {
            onPress();
            // setState(() {});
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ClayContainer(
                child: Center(
                    child: Text(ageText, style: modalPreviewItemsTextStyle)),
                height: 50,
                width: 120,
                borderRadius: 15.0,
                color: clayColor),
          )),
    );
  }

  Container vaccinePreview(
      String vaccineName, String assetURL, Function onPress) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
      child: GestureDetector(
        onTap: () {
          onPress();
          // setState(() {});
          Navigator.pop(context);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: ClayContainer(
            borderRadius: 15.0,
            color: Colors.white,
            // clayColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset("assets/images/" + assetURL,
                      height: 170, fit: BoxFit.fitHeight),
                ),
                SizedBox(height: 10),
                Text(vaccineName, style: modalPreviewItemsTextStyle),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container dosePreview(String dose, String assetURL, Function onPress) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0)),
      child: GestureDetector(
        onTap: () {
          onPress();
          // setState(() {});
          Navigator.pop(context);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: ClayContainer(
            color: Colors.white,
            // clayColor,
            borderRadius: 15.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset("assets/images/" + assetURL,
                      height: 170, fit: BoxFit.fitHeight),
                ),
                SizedBox(height: 10),
                Text(dose, style: modalPreviewItemsTextStyle),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container costPreview(String costText, Function onPress) {
    return Container(
      child: GestureDetector(
        onTap: () {
          onPress();
          // setState(() {});
          Navigator.pop(context);
        },
        child: Container(
          color: clayColor,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: ClayContainer(
            child: Center(
                child: Text(costText, style: modalPreviewItemsTextStyle)),
            height: 50,
            width: 100,
            borderRadius: 15.0,
          ),
        ),
      ),
    );
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

  List<District>? districts;

  Color clayColor = Color(0xFFF2F2F2);
  TextStyle formElementsHeaderTextStyle =
      TextStyle(fontSize: 17, color: Colors.black.withOpacity(0.7));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 15),
      child: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("State", style: formElementsHeaderTextStyle),
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                    child: ClayContainer(
                      color: clayColor,
                      height: 50,
                      width: state == null ? 50 : 120,
                      borderRadius: 15.0,
                      child: Center(
                        child: state == null
                            ? Icon(Icons.arrow_forward_ios)
                            : Marquee(
                                text: state == null
                                    ? "Select"
                                    : state!.stateName! +
                                        " (" +
                                        state!.stateId.toString() +
                                        ")",
                                blankSpace: 50.0,
                                velocity: 25.0,
                                fadingEdgeEndFraction: 0.2,
                                fadingEdgeStartFraction: 0.2,
                                showFadingOnlyWhenScrolling: true,
                              ),
                      ),
                    ),
                  ),
                  onTap: () {
                    SelectDialog.showModal<StateInfo>(
                      context,
                      label: "Select State",
                      items: widget.states,
                      selectedValue: state,
                      itemBuilder: (BuildContext context, StateInfo item,
                          bool isSelected) {
                        return Container(
                          decoration: !isSelected
                              ? null
                              : BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                          child: ListTile(
                            // leading: CircleAvatar(
                            //   backgroundImage: NetworkImage(item.stateName),
                            // ),
                            selected: isSelected,
                            title: Text(item.stateName.toString()),
                            subtitle: Text(item.stateId.toString()),
                          ),
                        );
                      },
                      onChange: (selected) async {
                        //TODO: Manage: state set by UI refreshes and states remove but still present in provider
                        state = selected;
                        district = null;
                        widget.platformChannelProvider!.setStateNameProv =
                            state!.stateName!;
                        widget.platformChannelProvider!.setDistrictCodeProv =
                            null;
                        widget.platformChannelProvider!.setDistNameProv = "";

                        widget.apiProvider!.setLoading = true;
                        Districts districtsData = await widget.apiProvider!
                            .getDistrictsByStateId(state!.stateId ?? 0);
                        districts = districtsData.districts;
                        print(state!.stateId.toString() +
                            " " +
                            state!.stateName.toString());
                        widget.apiProvider!.setLoading = false;
                        setState(() {});
                      },
                    );
                  },
                ),
              ],
            ),
            if (state != null) SizedBox(height: 10),
            if (state != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("District", style: formElementsHeaderTextStyle),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.only(
                          left: 20, right: 5, top: 15, bottom: 15),
                      child: ClayContainer(
                        color: clayColor,
                        height: 50,
                        width: district == null ? 50 : 120,
                        borderRadius: 15.0,
                        child: Center(
                          child: district == null
                              ? Icon(Icons.arrow_forward_ios)
                              : Marquee(
                                  text: district == null
                                      ? "Select"
                                      : district!.districtName! +
                                          " (" +
                                          district!.districtId.toString() +
                                          ")",
                                  fadingEdgeStartFraction: 0.2,
                                  showFadingOnlyWhenScrolling: true,
                                  fadingEdgeEndFraction: 0.2,
                                  velocity: 25.0,
                                  blankSpace: 50.0,
                                ),
                        ),
                      ),
                    ),
                    onTap: () {
                      SelectDialog.showModal<District>(
                        context,
                        label: "Select District",
                        items: districts,
                        selectedValue: district,
                        itemBuilder: (BuildContext context, District item,
                            bool isSelected) {
                          return Container(
                            decoration: !isSelected
                                ? null
                                : BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                            child: ListTile(
                              // leading: CircleAvatar(
                              //   backgroundImage: NetworkImage(item.stateName),
                              // ),
                              selected: isSelected,
                              title: Text(item.districtName.toString()),
                              subtitle: Text(item.districtId.toString()),
                            ),
                          );
                        },
                        onChange: (selected) {
                          setState(() {
                            district = selected;
                            widget.platformChannelProvider!
                                .setDistrictCodeProv = district!.districtId!;
                            widget.platformChannelProvider!.setDistNameProv =
                                district!.districtName!;
                            print(district!.districtId.toString() +
                                " " +
                                district!.districtName.toString());
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class EnterPinCode extends StatelessWidget {
  final PlatformChannelProvider? platformChannelProvider;
  const EnterPinCode({
    Key? key,
    this.platformChannelProvider,
  }) : super(key: key);

  static Color clayColor = Color(0xFFF2F2F2);
  static TextStyle formElementsHeaderTextStyle =
      TextStyle(fontSize: 17, color: Colors.black.withOpacity(0.7));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("PIN Code", style: formElementsHeaderTextStyle),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.3),
          child: ClayContainer(
            color: clayColor,
            borderRadius: 40.0,
            emboss: true,
            height: 50,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(),
                // left: 15, right: 15
                child: TextFormField(
                  decoration: InputDecoration(
                      hintStyle:
                          TextStyle(color: Colors.black.withOpacity(0.35)),
                      hintText: "######",
                      counter: Offstage(),
                      border: InputBorder.none),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: TextStyle(fontSize: 25),
                  textAlign: TextAlign.center,
                  maxLengthEnforcement:
                      MaxLengthEnforcement.truncateAfterCompositionEnds,
                  onChanged: (String? input) {
                    if (input!.length == 6) {
                      //TODO: Check Valid number or not
                      platformChannelProvider!.setPincodeProv =
                          int.parse(input);
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
