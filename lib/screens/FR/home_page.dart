import 'package:aidlink/screens/FR/view_alerts_fr.dart';
import 'package:aidlink/screens/login_page.dart';
import 'package:aidlink/services/FR_services.dart';
import 'package:aidlink/services/login_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../maps_page.dart';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        title: Text('Raise Alert'),
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
            CustomSlideActionBtn(alertText: "Emergency Alert", bgColor: Colors.red),
            SizedBox(height: 20),
            CustomSlideActionBtn(alertText: "Injury Alert", bgColor: Colors.orange),
            SizedBox(height: 20),
            CustomSlideActionBtn(alertText: "Dehydration Alert", bgColor: Colors.blue),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
      },
      onHorizontalDragEnd: (_) async {
        setState(() {
          _isPerformingAction = true;
        });
        FRServices().sendAlert(type: getAlertType(widget.alertText));
        setState(() {
          _isPerformingAction = false;
        });
        int alertType = getAlertType(widget.alertText);
        bool alertRaised = await frServices.sendAlert(type: alertType);
        print("Action completed for ${widget.alertText}");

        if (alertRaised) {
          String snackBarMessage = "Alert raised: ${widget.alertText}";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(snackBarMessage),
              duration: Duration(seconds: 2),
            ),
          );

          print("Action completed for ${widget.alertText}");
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Container(
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
                left: 0,
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