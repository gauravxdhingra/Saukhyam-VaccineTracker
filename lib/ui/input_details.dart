import 'package:cowintrackerindia/models/districts/districts.dart';
import 'package:cowintrackerindia/models/states/state.dart';
import 'package:cowintrackerindia/provider/api_provider.dart';
import 'package:cowintrackerindia/provider/platform_channel_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rolling_switch/rolling_switch.dart';
import 'package:select_dialog/select_dialog.dart';
import 'package:toggle_switch/toggle_switch.dart';

enum LocationMode { ByPIN, ByDistrict }

class InputDetails extends StatefulWidget {
  const InputDetails({Key? key}) : super(key: key);

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

  int iVaccine = 0;
  int iAge = 0;
  int iDose = 0;
  int iCost = 0;

  @override
  void didChangeDependencies() async {
    if (!_init) {
      apiProvider = Provider.of<ApiProvider>(context);
      StatesList statesData = await apiProvider!.getStates();
      states = statesData.states;

      platformChannelProvider =
          Provider.of<PlatformChannelProvider>(context, listen: false);
      // await platformChannelProvider!
      //     .registerWithPinCode(110009, "COVAXIN", 18, 0, 2);

      setState(() {
        _init = true;
        apiProvider!.setLoading = false;
      });
    }
    super.didChangeDependencies();
  }

  Future<List<District>?> getDistrictsFromStateId(int stateId) async {
    Districts districts = await apiProvider!.getDistrictsByStateId(stateId);
    return districts.districts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              RollingSwitch.icon(
                onChanged: (bool state) {
                  if (state) {
                    _locationMode = LocationMode.ByDistrict;
                  } else {
                    _locationMode = LocationMode.ByPIN;
                  }
                  print(state.toString() + " : " + _locationMode.toString());
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
              _locationMode == LocationMode.ByPIN
                  ? EnterPinCode(
                      platformChannelProvider: platformChannelProvider)
                  : EnterDistrict(
                      states: states,
                      apiProvider: apiProvider,
                      platformChannelProvider: platformChannelProvider),
              Column(
                children: [
                  SizedBox(height: 10),
                  ToggleSwitch(
                    minWidth: MediaQuery.of(context).size.width * 0.24,
                    initialLabelIndex: 0,
                    labels: listVaccine,
                    fontSize: 12,
                    onToggle: (index) {
                      setState(() {
                        iVaccine = index;
                      });
                      print(listVaccine[iVaccine]);
                    },
                  ),
                  SizedBox(height: 10),
                  ToggleSwitch(
                    minWidth: MediaQuery.of(context).size.width * 0.27,
                    initialLabelIndex: 0,
                    labels: listAges,
                    onToggle: (index) {
                      setState(() {
                        iAge = index;
                      });
                      print(listAges[iAge]);
                    },
                  ),
                  SizedBox(height: 10),
                  ToggleSwitch(
                    minWidth: MediaQuery.of(context).size.width * 0.27,
                    initialLabelIndex: 0,
                    labels: listDose,
                    onToggle: (index) {
                      setState(() {
                        iDose = index;
                      });
                      print(listDose[iDose]);
                    },
                  ),
                  SizedBox(height: 10),
                  ToggleSwitch(
                    minWidth: MediaQuery.of(context).size.width * 0.27,
                    initialLabelIndex: 0,
                    labels: listCost,
                    onToggle: (index) {
                      setState(() {
                        iCost = index;
                      });
                      print(listCost[iCost]);
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: TextButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none, color: Colors.white),
                    SizedBox(width: 5),
                    Text("Get Notified", style: TextStyle(color: Colors.white)),
                  ],
                ),
                onPressed: () async {
                  if (_locationMode == LocationMode.ByPIN) {
                    await platformChannelProvider!.registerWithPinCode(
                        listVaccine[iVaccine], iAge, iDose, iCost);
                  } else if (_locationMode == LocationMode.ByDistrict) {
                    await platformChannelProvider!.registerWithDistrictId(
                        listVaccine[iVaccine], iAge, iDose, iCost);
                  }
                },
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Select State"),
              ElevatedButton(
                child: Text(state == null
                    ? "Select"
                    : state!.stateName! +
                        " (" +
                        state!.stateId.toString() +
                        ")"),
                onPressed: () {
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
          if (state != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Select District"),
                ElevatedButton(
                  child: Text(district == null
                      ? "Select"
                      : district!.districtName! +
                          " (" +
                          district!.districtId.toString() +
                          ")"),
                  onPressed: () {
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
                          widget.platformChannelProvider!.setDistrictCodeProv =
                              district!.districtId!;
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
