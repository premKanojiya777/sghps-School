import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_live/widgets/routeInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/LocationHistoryModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:core';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class MyApp extends StatefulWidget {
  final String routeId;
  final String vehicleId;
  final String route;
  final double latitude;
  final double longitude;
  String token;
  MyApp(
      {this.routeId,
      this.vehicleId,
      this.route,
      this.token,
      this.latitude,
      this.longitude});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Completer<GoogleMapController> _controller = Completer();

  ListViewExample myModel = new ListViewExample();

  static const LatLng _center = const LatLng(30.933093, 75.8386531);

  final Set<Marker> _marker = {};

  final Set<Polyline> _polylines = {};

  LatLng locationData = _center;

  List<LatLng> latlng = [];

  MapType _currentMapType = MapType.normal;

  Map<String, dynamic> module;
  bool permission = true;
  bool visible = false;
  String reply;

  @override
  void initState() {
    super.initState();
    _checkTrnasport();
    bg.BackgroundGeolocation.onLocation((bg.Location location) {});

    bg.BackgroundGeolocation.ready(bg.Config(
            desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
            distanceFilter: 10.0,
            stopOnTerminate: true,
            startOnBoot: true,
            debug: false,
            enableHeadless: true,
            logLevel: bg.Config.LOG_LEVEL_VERBOSE))
        .then((bg.State state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.start();
      }
    });

    const fivSec = const Duration(seconds: 30);
    new Timer.periodic(fivSec, (Timer t) => _onAddMarkerButtonPressed());
  }

  // void _onMapTypeButtonPressed() {
  //   setState(() {
  //     _currentMapType = _currentMapType == MapType.normal
  //         ? MapType.satellite
  //         : MapType.normal;
  //   });
  // }

  void _onAddMarkerButtonPressed() async {
    final GoogleMapController controller = await _controller.future;
    final prefs = await SharedPreferences.getInstance();
    widget.token = prefs.get('token');
    LocationData locationData;
    var location = new Location();
    var timestamp = DateTime.now();

    try {
      locationData = await location.getLocation();
      //location.onLocationChanged().listen((LocationData locationData) {

    //  if (locationData.accuracy <= 25) {
        print(locationData.latitude);
        print(locationData.longitude);
        print(locationData.speed * 3.6);
        print(timestamp);
        print(locationData.accuracy);
        listViewData.add(
          ListViewModel(
            latitude: locationData.latitude.toString(),
            longitude: locationData.longitude.toString(),
            speed: (locationData.speed * 3.6).toString(),
            accuracy: locationData.accuracy.toString(),
            timestamp: timestamp.toIso8601String(),
          ),
        );
        latlng.add(LatLng(locationData.latitude, locationData.longitude));
      // } 
      // else {
      //   print('invalid Accuracy');
      // }
      // });
    } on Exception {
      locationData = null;
    }
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(locationData.latitude, locationData.longitude),
        zoom: 19.0,
      ),
    ));
    if (!mounted) return;
    setState(() {
     if (locationData.accuracy <= 25) {
        if(_marker != null) {
        _marker.clear();
      }
        _marker.add(Marker(
        markerId: MarkerId(locationData.toString()),
        draggable: true,
        position: LatLng(locationData.latitude, locationData.longitude),
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: '5 Star Rating',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
      
        _polylines.add(Polyline(
          polylineId: PolylineId(locationData.toString()),
          visible: true,
          points: latlng,
          color: Colors.blue,
          width: 10,
        ));
     }
      
    });

    String url = 'https://sghps.cityschools.co/location_flutter';

    Map dataMap = {
      'latitude': locationData.latitude,
      'longitude': locationData.longitude,
      'speed': locationData.speed * 3.6,
      'accuracy': locationData.accuracy,
      'time': timestamp.toIso8601String(),
      'route': widget.route,
      'routeid': widget.routeId,
      'vehicleid': widget.vehicleId,
    };

    print(await apiRequest(url, dataMap));
  }

  Future<String> apiRequest(String url, Map dataMap) async {
    String jsonString = json.encode(dataMap);
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('Content-Length', jsonString.length.toString());
    request.write(jsonString);
    print(jsonString);
    HttpClientResponse response = await request.close();
    this.reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    return this.reply;
  }

  void _onCameraMove(CameraPosition position) {
    locationData = position.target;
    CameraPosition newPos = CameraPosition(target: position.target);
    if (!mounted) return;
     _marker.first.copyWith(positionParam: newPos.target);
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _checkTrnasport() async {
    final prefs = await SharedPreferences.getInstance();
    String url = 'https://sghps.cityschools.co/driverapi/module?access_token=' +
        prefs.get('token');

    Map dataMap = {
      'access_token': prefs.get('token'),
    };

    print(await apiRequestStudent(url, dataMap));
  }

  Future<String> apiRequestStudent(String url, Map dataMap) async {
    String jsonString = json.encode(dataMap);
    HttpClient httpClient = new HttpClient();

    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    request.headers.contentType =
        new ContentType('application', 'json', charset: 'utf-8');
    request.headers.set('Content-Length', jsonString.length.toString());
    request.write(jsonString);
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    module = jsonDecode(reply);
    permission = module['error'];

    if (permission == false) {
      print('Valid');
    } else {
      print('Invalid');
    }

    httpClient.close();
    return reply;
  }



  void _latlongToAddress() async {
    final coordinates =
        new Coordinates(locationData.latitude, locationData.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: new Text('Your Address Is'),
        content: new Text(
            '${first.locality},${first.adminArea},${first.subLocality},${first.subAdminArea},${first.addressLine},${first.featureName},${first.thoroughfare},${first.subThoroughfare}'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List reversedListData = listViewData.reversed.toList();
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Driver Current Location'),
          backgroundColor: Colors.green[700],
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.info), onPressed: _latlongToAddress),
          ],
        ),
        body: Container(
            child: this.permission == false
                ? Stack(
                    children: <Widget>[
                      GoogleMap(
                        polylines: _polylines,
                        onMapCreated: _onMapCreated,
                        myLocationEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(locationData.latitude, locationData.longitude),
                          zoom: 16.0,
                        ),
                        mapType: _currentMapType,
                        markers: _marker,
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
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RouteInfo(
                                              routeid: widget.routeId,
                                              latitude: locationData.latitude,
                                              longitude: locationData.longitude,
                                              token: widget.token,
                                              vehicleId: widget.vehicleId,
                                              route: widget.route,
                                              // accuracy: locationData.accuracy,
                                            )),
                                  );
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.padded,
                                backgroundColor: Colors.green,
                                child:
                                    const Icon(Icons.add_location, size: 36.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(children: <Widget>[
                    GoogleMap(
                      polylines: _polylines,
                      onMapCreated: _onMapCreated,
                      myLocationEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(locationData.latitude, locationData.longitude),
                        zoom: 16.0,
                      ),
                      mapType: _currentMapType,
                      markers: _marker,
                      onCameraMove: _onCameraMove,
                    ),
                  ])),
        drawer: Drawer(
          //child: Text('$reply'),
          child: ListView.builder(
              itemCount: reversedListData.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: new Text('LAT: ${reversedListData[index].latitude.toString()}' +
                      '\t'
                          '\t'
                          '\t'
                          'LONG: ${reversedListData[index].longitude.toString()}' +
                      '\t'
                          '\t'
                          '\t'
                          'SPD: ${(reversedListData[index].speed).toString()}' +
                      '\t'
                          '\t'
                          '\t'
                          'ACURCY: ${reversedListData[index].accuracy.toString()}' +
                      '\t'
                          '\t'
                          '\t'
                          'Time: ${reversedListData[index].timestamp}'),
                );
              }),
        ),
      ),
    );
  }
}

class ListViewExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("List view Example - Flutterian"),
      ),
      body: DisplayListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
