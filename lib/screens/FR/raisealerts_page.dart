import 'package:aidlink/screens/FR/view_alerts_fr.dart';
import 'package:aidlink/screens/login_page.dart';
import 'package:aidlink/services/FR_services.dart';
import 'package:aidlink/services/login_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../maps_page.dart';
class RaiseAlertsPage extends StatefulWidget {
  @override
  _RaiseAlertsPageState createState() => _RaiseAlertsPageState();
}

class _RaiseAlertsPageState extends State<RaiseAlertsPage> {
  String? dutyLocation;
  String? typeDescription;
  String? name;
  String? reportingTo;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      dutyLocation = prefs.getString('duty_location');
      typeDescription = prefs.getString('type_description');
      name = prefs.getString('name');
      reportingTo = prefs.getString('reporting_to');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raise Alerts'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ViewAlertsFR()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.location_pin),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapsPage()),
              );
            },
          )
        ],
      ),drawer: Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: UserAccountsDrawerHeader(
                    accountName: Text(
                      name ?? '', // Replace with the user's name from SharedPreferences
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    accountEmail: Text(
                      typeDescription ?? '', // Replace with the user's username from SharedPreferences
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.call),
                  title: Text('Helpdesk'),
                  onTap: () {
                    _makePhoneCall(reportingTo ?? '');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.directions),
                  title: Text('Assigned Location'),
                  onTap: () {
                    _launchMaps(dutyLocation ?? '');
                  },
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey,
          ),
          ListTile(
            leading: Icon(Icons.power_settings_new),
            title: Text('Logout'),
            onTap: () {
              LoginService().logoutUser();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomSlideActionBtn(alertText: "Emergency Alert", bgColor: Colors.redAccent),
            SizedBox(height: 20),
            CustomSlideActionBtn(alertText: "Injury Alert", bgColor: Colors.orangeAccent),
            SizedBox(height: 20),
            CustomSlideActionBtn(alertText: "Dehydration Alert", bgColor: Colors.blueAccent),
            SizedBox(height: 20),
            CustomSlideActionBtn(alertText: "Social Threat Alert", bgColor: Colors.green),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    // Implement your phone call functionality here
    print("Making a phone call to $phoneNumber");
  }

  void _launchMaps(String location) {
    // Implement launching maps functionality here
    print("Launching maps for location: $location");
  }
}
class CustomSlideActionBtn extends StatefulWidget {
  final String alertText;
  final Color bgColor;

  const CustomSlideActionBtn({required this.alertText, required this.bgColor});

  @override
  _CustomSlideActionBtnState createState() => _CustomSlideActionBtnState();
}

class _CustomSlideActionBtnState extends State<CustomSlideActionBtn> {
  final FRServices frServices = FRServices();
  bool _isPerformingAction = false;
  double _dragValue = 0.0;
  double _maxDragExtent = 355.0; // Adjust the maximum drag distance as needed
  double _triggerThreshold = 0.9; // Adjust the trigger threshold (90%)

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragValue += details.primaryDelta!;
          if (_dragValue < 0) {
            _dragValue = 0;
          } else if (_dragValue > _maxDragExtent) {
            _dragValue = _maxDragExtent;
          }
        });
      },
      onHorizontalDragEnd: (_) async {
        if (_dragValue >= (_maxDragExtent * _triggerThreshold)) {
          setState(() {
            _isPerformingAction = true;
            _dragValue = 0.0; // Reset drag value after action completion
          });
          int alertType = getAlertType(widget.alertText);
          bool alertRaised = await frServices.sendAlert(type: alertType);

          setState(() {
            _isPerformingAction = false;
          });

          // Show SnackBar if the alert is raised
          if (alertRaised) {
            String snackBarMessage = "Alert raised: ${widget.alertText}";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(snackBarMessage),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          // Reset the drag value if the action is not performed
          setState(() {
            _dragValue = 0.0;
          });
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Stack(
          children: [
            Container(
              width: 400,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: widget.bgColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: _dragValue,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 36,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: _isPerformingAction
                            ? const CupertinoActivityIndicator(
                          color: Colors.black,
                        )
                            : const Icon(
                          Icons.chevron_right,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      _isPerformingAction ? "Loading..." : widget.alertText,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int getAlertType(String alertText) {
    switch (alertText) {
      case "Emergency Alert":
        return 1;
      case "Injury Alert":
        return 2;
      case "Dehydration Alert":
        return 3;
      case "Social Threat Alert":
        return 4;
      default:
        return 0;
    }
  }
}
