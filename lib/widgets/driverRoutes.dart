import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/driverRouteModel.dart';
import '../widgets/driverLocation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverRoutes extends StatefulWidget {
  @override
  _DriverRoutesState createState() => _DriverRoutesState();
}

class _DriverRoutesState extends State<DriverRoutes> {
  bool visible = false;
  bool loading;
  Map<String, dynamic> driverRoute;
  Future<List<RouteModel>> _routes;
  var token = '';
  @override
  void initState() {
    super.initState();
    _routes = _apiRequestDriver();
    visible = true;
    loading = false;
  }

  Future<List<RouteModel>> _apiRequestDriver() async {
    List<RouteModel> routes = [];
    final prefs = await SharedPreferences.getInstance();
    String url = 'http://sghps.cityschools.co/driverapi/route?access_token=' +
        prefs.get('token');
    Map dataMap = {
      'access_token': prefs.get('token'),
    };
    String jsonString = json.encode(dataMap);
    HttpClient httpClient = new HttpClient();

    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    request.headers.contentType =
        new ContentType('application', 'json', charset: 'utf-8');
    request.headers.set('Content-Length', jsonString.length.toString());
    request.write(jsonString);
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    setState(() {
      visible = false;
    });

    httpClient.close();
    if (mounted)
      setState(() {
        this.driverRoute = jsonDecode(reply);
        var route = driverRoute['route_assign'];
        for (var u in route) {
          RouteModel route1 = RouteModel(
            u["route_id"], u["vehicle_id"],
              u["start_time"], u["return_time"], u['route']["route_code"]);

          routes.add(route1);
        }
        print(routes.length);
      });
    return routes;
  }

  Future<void> _chooseRoute(String routeId, int vehicleId) async {
    final prefs = await SharedPreferences.getInstance();
    this.token = prefs.get('token');
    String url = 'http://sghps.cityschools.co/driverapi/route_status?access_token=' +
        prefs.get('token') +
        '&vehicle_id=' +
        vehicleId.toString() +
        '&route_id=' +
        routeId;
    Map dataMap = {};
    String jsonString = json.encode(dataMap);
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    request.headers.contentType =
        new ContentType('application', 'json', charset: 'utf-8');
    request.headers.set('Content-Length', jsonString.length.toString());
    request.write(jsonString);
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    print(reply);
    Map<String, dynamic> routetime = jsonDecode(reply);
    //print(routetime);
    var route = routetime['stat'];
    print(route);
    if (route == 'no_time') {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: new Text('Session Expired'),
          content: new Text('Your Route Expired Please Come Back Tommorrow'),
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
    } else if (route == 'eve') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(
              routeId: routeId,
              vehicleId: vehicleId.toString(),
              route: 'eve',
              token: prefs.get('token')),
        ),
      );

      print('this is Evening route');
    } else if (route == 'mor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyApp(
                routeId: routeId,
                vehicleId: vehicleId.toString(),
                route: 'mor',
                token: prefs.get('token'))),
      );

      print('this is Morning route');
    }
    visible = false;

    httpClient.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Profile'),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 300,
              child: FutureBuilder(
                future: _routes,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Container(
                      child: Center(
                        child: Text("Loading..."),
                      ),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Column(
                          children: <Widget>[
                            Text('RouteId: ${snapshot.data[i].route_id}'),
                            Text('VehicleId: ${snapshot.data[i].vehicle_id}'),
                            Text('Start Time: ${snapshot.data[i].start_time}'),
                            Text(
                                'Return Time: ${snapshot.data[i].return_time}'),
                            Text('Route Name: ${snapshot.data[i].route_code}'),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RaisedButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.green)),
                                color: Colors.green,
                                onPressed: () {
                                  _chooseRoute(snapshot.data[i].route_id,
                                      snapshot.data[i].vehicle_id);
                                },
                                child: Text('Start'),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Visibility(
                visible: this.visible,
                child: Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: CircularProgressIndicator(),
                )),
          ],
        ),
      ),
    );
  }
}
