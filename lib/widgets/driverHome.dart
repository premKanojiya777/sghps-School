import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/widgets/userLogin.dart';
import '../widgets/driverProfile.dart';
import '../widgets/driverRoutes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationHome extends StatefulWidget {
  final String token;

  LocationHome({this.token});
  @override
  _LocationHomeState createState() => _LocationHomeState();
}

class _LocationHomeState extends State<LocationHome> {
  bool visible = false;
  //bool loading;
  var savekey = '';

  // @override
  // void initState() {
  //   super.initState();
  //   _checkTrnasport();
  //   visible = true;

  //  // loading = false;
  // }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    String url = 'https://sghps.cityschools.co/studentapi/logout?access_token=' +
        prefs.get('token');
    print(prefs.get('token'));
    Map dataMap = {
      'access_token': prefs.get('token'),
    };
    await apiRequestDriver(url, dataMap);
  }

  Future<String> apiRequestDriver(String url, Map dataMap) async {
    String jsonString = json.encode(dataMap);
    HttpClient httpClient = new HttpClient();

    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    request.headers.contentType =
        new ContentType('application', 'json', charset: 'utf-8');
    request.headers.set('Content-Length', jsonString.length.toString());
    request.write(jsonString);
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    Map<String, dynamic> user = jsonDecode(reply);
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    //print(prefs.remove('token'));
    var logout = user['error'];
    if (logout == false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginUser()));
    }
    print(reply);
    httpClient.close();
    return reply;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Driver Home'),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.exit_to_app), onPressed: _logout),
        ],
      ),
      body: Container(
          height: 300,
          child: Center(
            child: Container(
              height: 300,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: SizedBox.fromSize(
                            size: Size(110, 110), // button width and height
                            child: ClipOval(
                              child: Material(
                                color: Colors.blue, // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DriverProfile()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.person,
                                          color: Colors.white), // icon
                                      Text(
                                        "Driver Profile",
                                        style: TextStyle(color: Colors.white),
                                      ), // text
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: SizedBox.fromSize(
                            size: Size(110, 110), // button width and height
                            child: ClipOval(
                              child: Material(
                                color: Colors.blue, // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DriverRoutes()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                      ), // icon
                                      Text(
                                        "Route",
                                        style: TextStyle(color: Colors.white),
                                      ), // text
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: SizedBox.fromSize(
                            size: Size(110, 110), // button width and height
                            child: ClipOval(
                              child: Material(
                                color: Colors.blue, // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //       builder: (context) => HolidayHomeWork()),
                                    // );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.work,
                                          color: Colors.white), // icon
                                      Text(
                                        "Dummy",
                                        style: TextStyle(color: Colors.white),
                                      ), // text
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
