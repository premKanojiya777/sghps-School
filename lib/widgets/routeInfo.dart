import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/driverLocation.dart';

class RouteInfo extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String routeid;
  final String vehicleId;
  final String token;
  final String route;

  const RouteInfo({
    this.latitude,
    this.longitude,
    this.routeid,
    this.token,
    this.vehicleId,
    this.route,
  });
  @override
  _RouteInfoState createState() => _RouteInfoState();
}

class _RouteInfoState extends State<RouteInfo> {
  Map<String, dynamic> routePoints;
  bool visible = false;
  final routenameController = TextEditingController();
  final notesController = TextEditingController();
  bool loading;

  void _sendToServer() async {
    String routename = routenameController.text;
    String notes = notesController.text;

    String url = 'http://sghps.cityschools.co/driverapi/route_points';
    Map dataMap = {
      'latitude': widget.latitude,
      'longitude': widget.longitude,
      'route_id': widget.routeid,
      'vehicle_id': widget.vehicleId,
      'access_token': widget.token,
      'location_name': routename,
      'notes': notes,
    };

    await apiRequest(url, dataMap);
  }

  Future<String> apiRequest(String url, Map dataMap) async {
    String jsonString = json.encode(dataMap);
    HttpClient httpClient = new HttpClient();

    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.contentType =
        new ContentType('application', 'json', charset: 'utf-8');
    request.headers.set('Content-Length', jsonString.length.toString());
    request.write(jsonString);
    print(jsonString);
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    this.routePoints = jsonDecode(reply);
    var addRoute = routePoints['error'];
    //print(addRoute);
    //print(reply);
    if (addRoute == false) {
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: new Text('Route Added'),
          content: new Text('Your Route Is Added Now ,Enter OK For Continue'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyApp(
                            vehicleId: widget.vehicleId,
                            routeId: widget.routeid,
                            token: widget.token,
                            route: widget.route,
                            // latitude: widget.latitude,
                            // longitude: widget.longitude,
                          )),
                );
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    } else
      print('SomeThing Went Wrong!!!!!!');

    httpClient.close();
    //return reply;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Route Information'),
        ),
        body: SingleChildScrollView(
            child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('Enter Route Information',
                      style: TextStyle(fontSize: 21))),
              Divider(),
              SizedBox(height: 45.0),
              Container(
                  width: 280,
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Enter Your Route Here ",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(35.0),
                      ),
                    ),
                  )),
              SizedBox(height: 45.0),
              Container(
                  width: 280,
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: notesController,
                    autocorrect: true,
                    decoration: InputDecoration(
                      hintText: "Enter Some Notes Here",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(35.0),
                      ),
                    ),
                  )),
              SizedBox(height: 45.0),
              RaisedButton(
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.green)),
                onPressed: _sendToServer,
                color: Colors.green,
                textColor: Colors.white,
                padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                child: Text('Submit'),
              ),
              Visibility(
                visible: visible,
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Please Wait....",
                      style: TextStyle(color: Colors.blueAccent),
                    )
                  ],
                ),
              ),
            ],
          ),
        )));
  }
}
