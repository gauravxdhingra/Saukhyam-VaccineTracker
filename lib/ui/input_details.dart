import 'package:clay_containers/clay_containers.dart';
import 'package:cowintrackerindia/models/districts/districts.dart';
import 'package:cowintrackerindia/models/states/state.dart';
import 'package:cowintrackerindia/provider/api_provider.dart';
import 'package:cowintrackerindia/provider/platform_channel_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rolling_switch/rolling_switch.dart';
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: clayColor,
        appBar: AppBar(
          backgroundColor: clayColor,
          title: Text(""),
          elevation: 0,
          leading: GestureDetector(
            onTap: () async {},
            child: Container(
              color: clayColor,
              padding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
              child: ClayContainer(
                child: Center(
                    child: Icon(Icons.arrow_back_ios, color: Colors.grey)),
                borderRadius: 10.0,
                color: clayColor,
                width: 40,
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                await platformChannelProvider!.deleteAlerts();
              },
              child: Container(
                color: clayColor,
                padding: EdgeInsets.symmetric(vertical: 7, horizontal: 7),
                child: ClayContainer(
                  child: Icon(Icons.delete, color: Colors.grey),
                  borderRadius: 10.0,
                  color: clayColor,
                  width: 40,
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  RollingSwitch.icon(
                    onChanged: (bool state) {
                      if (state) {
                        _locationMode = LocationMode.ByDistrict;
                      } else {
                        _locationMode = LocationMode.ByPIN;
                      }
                      print(
                          state.toString() + " : " + _locationMode.toString());
                      setState(() {});
                    },
                    rollingInfoRight: const RollingIconInfo(
                      icon: Icons.location_city,
                      text: Text('By District'),
                    ),
                    rollingInfoLeft: const RollingIconInfo(
                      icon: FontAwesomeIcons.hashtag,
                      backgroundColor: Colors.grey,
                      text: Text('By PIN'),
                    ),
                    // width: MediaQuery.of(context).size.width * 0.5,
                  ),
                  SizedBox(height: 20),
                  _locationMode == LocationMode.ByPIN
                      ? EnterPinCode(
                          platformChannelProvider: platformChannelProvider)
                      : EnterDistrict(
                          states: states,
                          apiProvider: apiProvider,
                          platformChannelProvider: platformChannelProvider),
                  for (int i = 0; i < formElementsMap.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        await platformChannelProvider!.registerWithPinCode(
                            listVaccine[iVaccine!],
                            iAge ?? 0,
                            iDose ?? 0,
                            iCost ?? 0);
                      } else if (_locationMode == LocationMode.ByDistrict) {
                        await platformChannelProvider!.registerWithDistrictId(
                            listVaccine[iVaccine!],
                            iAge ?? 0,
                            iDose ?? 0,
                            iCost ?? 0);
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
                child: Center(child: CircularProgressIndicator()),
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
        Text(title),
        GestureDetector(
          onTap: () => onPress(),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            height: 50,
            width: 110,
            child: ClayContainer(
                child: Center(child: Text(getFormButtonText(title))),
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
          SizedBox(height: 20),
          Text(heading),
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
            SizedBox(width: 20),
            costPreview("Any", () {
              setState(() => iCost = 0);
            }),
            SizedBox(width: 20),
            costPreview("Free", () {
              setState(() => iCost = 1);
            }),
            SizedBox(width: 20),
            costPreview("Paid", () {
              setState(() => iCost = 2);
            }),
            SizedBox(width: 20),
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
                child: Center(child: Text(ageText)),
                height: 50,
                width: 150,
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
            color: clayColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset("assets/images/" + assetURL,
                      height: 170, fit: BoxFit.fitHeight),
                ),
                SizedBox(height: 10),
                Text(vaccineName)
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
            color: clayColor,
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
                Text(dose)
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
            child: Center(child: Text(costText)),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Select State"),
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: ClayContainer(
                      color: clayColor,
                      height: 70,
                      width: 150,
                      borderRadius: 15.0,
                      child: Center(
                        child: Text(
                          state == null
                              ? "Select"
                              : state!.stateName! +
                                  " (" +
                                  state!.stateId.toString() +
                                  ")",
                          textAlign: TextAlign.center,
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
                        state = selected;
                        district = null;
                        widget.platformChannelProvider!.setDistrictCodeProv =
                            null;
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
                  Text("Select District"),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      child: ClayContainer(
                        color: clayColor,
                        height: 70,
                        width: 150,
                        borderRadius: 15.0,
                        child: Center(
                          child: Text(
                            district == null
                                ? "Select"
                                : district!.districtName! +
                                    " (" +
                                    district!.districtId.toString() +
                                    ")",
                            textAlign: TextAlign.center,
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

  // TODO: VALIDATE PINCODE USING ANY SERVICE

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.3),
      child: TextFormField(
        decoration: InputDecoration(labelText: "PIN Code", counter: null),
        keyboardType: TextInputType.number,
        maxLength: 6,
        maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
        onChanged: (String? input) {
          if (input!.length == 6) {
            platformChannelProvider!.setPincodeProv = int.parse(input);
          }
        },
      ),
    );
  }
}
