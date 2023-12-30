import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/admin_services.dart';
import '../services/login_services.dart';
import 'login_page.dart';
import 'package:location/location.dart';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  Timer? _timer;
  Location location = Location(); // Location object for getting current location
  LatLng _currentLocation = LatLng(0, 0); // Initialize with a default location
  String? dutyLocation;
  String? typeDescription;
  String? name;
  String? reportingTo;
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  bool showFR = true;
  bool showAM = true;
  bool showAD = true;
  bool showAL = true;
  bool showAS = true;

  final MapService _mapService = MapService();
  bool _isLocationButtonEnabled = false;
  late BitmapDescriptor _frIcon;
  late BitmapDescriptor _amIcon;
  late BitmapDescriptor _adIcon;
  late BitmapDescriptor _al1Icon;
  late BitmapDescriptor _al2Icon;
  late BitmapDescriptor _al3Icon;
  late BitmapDescriptor _al4Icon;
  late BitmapDescriptor _wasIcon;
  late BitmapDescriptor _maIcon;
  late BitmapDescriptor _asIcon;
  late BitmapDescriptor _frofflineIcon;
  late BitmapDescriptor _amofflineIcon;
  late BitmapDescriptor _ambusyIcon;


  @override
  void initState() {
    _setMarkerIcons();
    super.initState();
    getUserData();
    _loadInitialLocation();
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _loadMarkers();
    });
  }

  void _stopTimer() {
    // Cancel the timer when it's no longer needed (e.g., when the widget is disposed)
    _timer?.cancel();
  }
  void _loadInitialLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedLocation = prefs.getString('user_location');

    if (storedLocation != null) {
      List<String> latLng = storedLocation.split(',');
      double latitude = double.tryParse(latLng[0]) ?? 0.0;
      double longitude = double.tryParse(latLng[1]) ?? 0.0;

      setState(() {
        _currentLocation = LatLng(latitude, longitude);
      });
    } else {
      // If no stored location found, get the current location
      _getCurrentLocation();
    }
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
  void _getCurrentLocation() async {
    try {
      // Request permission to access the device's location
      await location.requestPermission();

      // Get the current location of the user
      LocationData currentLocation = await location.getLocation();
      setState(() {
        _currentLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  void _setMarkerIcons() async {
    _frIcon = await _getResizedIcon('assets/images/fr-icon.png', 96);
    _frofflineIcon = await _getResizedIcon('assets/images/fr-offline-icon.png', 96);
    _amIcon = await _getResizedIcon('assets/images/am-icon.png', 96);
    _ambusyIcon = await _getResizedIcon('assets/images/am-busy-icon.png', 96);
    _amofflineIcon = await _getResizedIcon('assets/images/am-offline-icon.png', 96);
    _adIcon = await _getResizedIcon('assets/images/ad-icon.png', 96);
    _al1Icon = await _getResizedIcon('assets/images/al1-icon.png', 96);
    _al2Icon = await _getResizedIcon('assets/images/al2-icon.png', 96);
    _al3Icon = await _getResizedIcon('assets/images/al3-icon.png', 96);
    _al4Icon = await _getResizedIcon('assets/images/al4-icon.png', 96);
    _wasIcon = await _getResizedIcon('assets/images/was-icon.png', 96);
    _maIcon = await _getResizedIcon('assets/images/ma-icon.png', 96);
    _asIcon = await _getResizedIcon('assets/images/as-icon.png', 96);
  }

  Future<BitmapDescriptor> _getResizedIcon(String imagePath, int size) async {
    final ByteData data = await rootBundle.load(imagePath);
    final Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetHeight: size);
    final FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? resizedData = await frameInfo.image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(resizedData!.buffer.asUint8List());
  }

  void _loadMarkers() async {
    setState(() {
      _markers.clear();
    });

    try {
      final List<Map<String, dynamic>>? usersList = await _mapService.getUsersList(
        fr: showFR,
        am: showAM,
        ad: showAD,
        al: showAL,
        as: showAS,
      );

      for (final user in usersList!) {
        final List<dynamic> lastKnownLocation = user['geocode'];
        final double latitude = lastKnownLocation[0];
        final double longitude = lastKnownLocation[1];
        final String markerId = user['id'].toString();
        final String markerPhone = user['mobile'].toString();
        final String markerTitle = user['name'].toString();
        final String markerType = user['statusicon'].toString();

        BitmapDescriptor markerIcon;
        if (markerType == 'F1') {
          markerIcon = _frIcon;
        } else if (markerType == 'A1') {
          markerIcon = _amIcon;
        } else if (markerType == 'D1' || markerType == 'D0') {
          markerIcon = _adIcon;
        }
        else if (markerType == 'W1' || markerType == 'W0' || markerType == 'W2'){
          markerIcon = _wasIcon;
        }
        else if (markerType == 'S1' || markerType == 'S0'){
          markerIcon = _asIcon;
        }
        else if (markerType == 'R0' || markerType == 'R1'){
          markerIcon = _maIcon;
        }
        else if (markerType == 'F0'){
          markerIcon = _frofflineIcon;
        }
        else if (markerType == 'A0'){
          markerIcon = _amofflineIcon;
        }
        else if (markerType == 'A2'){
          markerIcon = _ambusyIcon;
        }
        else if (markerType == '1'){
          markerIcon = _al1Icon;
        }
        else if (markerType == '2'){
          markerIcon = _al2Icon;
        }
        else if (markerType == '3'){
          markerIcon = _al3Icon;
        }
        else if (markerType == '4'){
          markerIcon = _al4Icon;
        }
        else {
          markerIcon = BitmapDescriptor.defaultMarker;
        }

        _addMarker(LatLng(latitude, longitude),markerPhone ,markerId, markerTitle, markerIcon);
      }
    } catch (e) {
      print('Error loading markers: $e');
    }
  }
  //this can be used to show the custom info window with more info or route details etc
  Future<void> _showCustomInfoWindow(String markerTitle, String phoneNumber) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(markerTitle),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _makePhoneCall(phoneNumber);
                },
                child: Text('Call'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addMarker(
      LatLng position,
      String markerPhone,
      String markerId,
      String markerTitle,
      BitmapDescriptor icon,
      ) {
    final Marker marker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(
        title: markerTitle,
        onTap: () {
          _makePhoneCall(markerPhone);
        },

      ),
      icon: icon,
    );

    setState(() {
      _markers.add(marker);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Birds Eye View'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _loadMarkers();
            },
          ),
          PopupMenuButton(
            icon: Icon(Icons.filter_list),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(showFR ? Icons.check_box : Icons.check_box_outline_blank),
                  title: Text('First Responders'),
                  onTap: () {
                    setState(() {
                      showFR = !showFR;
                      _loadMarkers();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(showAM ? Icons.check_box : Icons.check_box_outline_blank),
                  title: Text('Ambulances'),
                  onTap: () {
                    setState(() {
                      showAM = !showAM;
                      _loadMarkers();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(showAD ? Icons.check_box : Icons.check_box_outline_blank),
                  title: Text('Doctors'),
                  onTap: () {
                    setState(() {
                      showAD = !showAD;
                      _loadMarkers();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(showAL ? Icons.check_box : Icons.check_box_outline_blank),
                  title: Text('Alerts'),
                  onTap: () {
                    setState(() {
                      showAL = !showAL;
                      _loadMarkers();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),

      drawer: Drawer(
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
                        name!, // Replace with the user's name from SharedPreferences
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                        ),
                      ),
                      accountEmail: Text(
                        typeDescription!, // Replace with the user's username from SharedPreferences
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
                      _makePhoneCall(reportingTo!);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.directions),
                    title: Text('Assigned Location'),
                    onTap: () {
                      _launchMaps(dutyLocation!);
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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentLocation, zoom: 12.0),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _loadMarkers();
              _updateLocationButton();
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: _isLocationButtonEnabled,
          ),
        ],
      ),
    );
  }

  void _updateLocationButton() {
    setState(() {
      _isLocationButtonEnabled = true;
    });
  }

  void _moveToFirstMarker() {
    if (_markers.isNotEmpty) {
      Marker firstMarker = _markers.first;
      _mapController.animateCamera(CameraUpdate.newLatLng(firstMarker.position));
    }
  }

  void _launchMaps(String latLong) async {
    String mapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latLong';
    if (await canLaunch(mapsUrl)) {
      await launch(mapsUrl);
    } else {
      throw 'Could not launch $mapsUrl';
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    print("Phone number: $phoneNumber");
    String phoneUrl = 'tel:$phoneNumber';
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      throw 'Could not launch $phoneUrl';
    }
  }
}
