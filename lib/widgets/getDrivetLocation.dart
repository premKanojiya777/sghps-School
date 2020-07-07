import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationGet extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<LocationGet> {
  double latitude = 30.933093;
  double longitude = 75.8386531;
  bool isData = false;

  Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = const LatLng(30.933093, 75.8386531);

  final Set<Marker> _markers = {};

  final Set<Polyline> _polylines = {};

  LatLng currentLocation = _center;

  List<LatLng> latlng = [];

  MapType _currentMapType = MapType.normal;

  void _onCameraMove(CameraPosition position) {
    currentLocation = position.target;
    CameraPosition newPos = CameraPosition(target: position.target);
    if (!mounted) return;
    setState(() {
      _markers.first.copyWith(positionParam: newPos.target);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void initState() {
    super.initState();

    _onAddMarkerButtonPressed();
  }

  void _onAddMarkerButtonPressed() async {
    final GoogleMapController controller = await _controller.future;
    // var lati=30.933093;
    // var longi=75.8386531;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(latitude, longitude),
        zoom: 19.0,
      ),
    ));
    if (!mounted) return;
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(currentLocation.toString()),
        draggable: true,
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: '5 Star Rating',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });

    var response = await http.get(
      "https://api.github.com/users/nitishk72",
      headers: {"Accept": "application/json"},
    );

    if (response.statusCode == 200) {
      String responseBody = response.body;
      var responseJSON = json.decode(responseBody);
      latitude = responseJSON['latitude'];
      longitude = responseJSON['longitude'];
      isData = true;
      setState(() {
        print(responseBody);
        print('UI Updated');
      });
    } else {
      print('Something went wrong. \nResponse Code : ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Driver Location'),
          backgroundColor: Colors.green[700],
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              polylines: _polylines,
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 16.0,
              ),
              mapType: _currentMapType,
              markers: _markers,
              onCameraMove: _onCameraMove,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 50.0),
                    FloatingActionButton(
                      onPressed: _onAddMarkerButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.add_location, size: 36.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class ListView {
//  final String longitude;
//   final String latitude;
//   // final String route;
//   // final String speed;
//   // final int routeid;
//   // final int vehicleid;
//    ListView({
//     this.longitude,
//     this.latitude,
//     // this.speed,
//     // this.route,
//     // this.routeid,
//     // this.vehicleid,
//     });

//   factory ListView.fromJson(Map<String, dynamic> json) {
//     return ListView(
//       latitude: json['latitude'],
//       longitude: json['longitude'],
//       // speed: json['speed'],
//       // body: json['body'],
//     );
//   }
// }
