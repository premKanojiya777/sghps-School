import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DriverProfile extends StatefulWidget {
  @override
  _DriverProfileState createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  bool visible = false;
  bool loading;
  Map<String, dynamic> driverData;
  String firstname = '';
  String lastname = '';
  String phoneno = '';
  String liecenseno = '';
  String vehicleno = '';
  String rcno = '';

  @override
  void initState() {
    super.initState();
    _driverProfile();
    visible = true;

    loading = false;
  }

  void _driverProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String url = 'https://sghps.cityschools.co/driverapi/profile?access_token=' +
        prefs.get('token');
    Map dataMap = {
      'access_token': prefs.get('token'),
    };
    await apiRequestDriver(url, dataMap);
  }

  Future<Void> apiRequestDriver(String url, Map dataMap) async {
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
    // driverData = jsonDecode(reply);

    httpClient.close();
    if (mounted)
      setState(() {
        this.driverData = jsonDecode(reply);
        this.firstname = driverData['driver']['first_name'];
        this.lastname = driverData['driver']['last_name'];
        this.phoneno = driverData['driver']['phone'];
        this.liecenseno = driverData['driver']['liecense_number'];
        this.vehicleno = driverData['driver']['vehicle']['vehicle_no'];
        this.rcno = driverData['driver']['vehicle']['rc_no'];
        this.visible = false;
      });
    // return null;
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
                height: 54.0,
                padding: EdgeInsets.all(12.0),
                child: Text('User Details:',
                    style: TextStyle(fontWeight: FontWeight.w700))),
            Text('First Name:  ' + this.firstname,
                style: TextStyle(fontSize: 15)),
            Text('Last Name:  ' + this.lastname,
                style: TextStyle(fontSize: 15)),
            Text('Phone No:  ' + this.phoneno, style: TextStyle(fontSize: 15)),
            Text('Liecense No:  ' + this.liecenseno,
                style: TextStyle(fontSize: 15)),
            Text('Vehicle No:  ' + this.vehicleno,
                style: TextStyle(fontSize: 15)),
            Text('RC No:  ' + this.rcno, style: TextStyle(fontSize: 15)),
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
