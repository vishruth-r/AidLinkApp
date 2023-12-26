import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/admin_services.dart';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController _mapController;
  final LatLng _initialLocation = const LatLng(10.8461274, 78.6977601);
  final Set<Marker> _markers = {};
  bool showFR = true;
  bool showAM = true;
  bool showAD = true;
  bool showAL = true;
  final MapService _mapService = MapService();
  bool _isLocationButtonEnabled = false;
  late BitmapDescriptor _frIcon;
  late BitmapDescriptor _amIcon;
  late BitmapDescriptor _adIcon;
  late BitmapDescriptor _al1Icon;
  late BitmapDescriptor _al2Icon;
  late BitmapDescriptor _al3Icon;
  late BitmapDescriptor _al4Icon;

  @override
  void initState() {
    _setMarkerIcons();
    super.initState();
  }
  void _setMarkerIcons() async {
    _frIcon = await _getResizedIcon('assets/images/fr-icon.png', 96);
    _amIcon = await _getResizedIcon('assets/images/am-icon.png', 96);
    _adIcon = await _getResizedIcon('assets/images/ad-icon.png', 96);
    _al1Icon = await _getResizedIcon('assets/images/al1-icon.png', 96);
    _al2Icon = await _getResizedIcon('assets/images/al2-icon.png', 96);
    _al3Icon = await _getResizedIcon('assets/images/al3-icon.png', 96);
    _al4Icon = await _getResizedIcon('assets/images/al4-icon.png', 96);
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

      );

      for (final user in usersList!) {
        final List<dynamic> lastKnownLocation = user['geocode'];
        final double latitude = lastKnownLocation[0];
        final double longitude = lastKnownLocation[1];
        final String markerId = user['mobile'].toString();
        final String markerTitle = user['name'].toString();
        final String markerType = user['type'].toString();

        BitmapDescriptor markerIcon;
        if (markerType == 'F') {
          markerIcon = _frIcon;
        } else if (markerType == 'A') {
          markerIcon = _amIcon;
        } else if (markerType == 'D') {
          markerIcon = _adIcon;
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

        _addMarker(LatLng(latitude, longitude), markerId, markerTitle, markerIcon);
      }
    } catch (e) {
      print('Error loading markers: $e');
    }
  }

  void _addMarker(
      LatLng position,
      String markerId,
      String markerTitle,
      BitmapDescriptor icon,
      ) {
    final Marker marker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(title: markerTitle),
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
        title: Text('Maps Page'),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.filter_list),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(showFR ? Icons.check_box : Icons.check_box_outline_blank),
                  title: Text('FR'),
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
                  title: Text('AM'),
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
                  title: Text('AD'),
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
                  title: Text('AL'),
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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _initialLocation, zoom: 12.0),
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
}
