import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/widgets/TeacherHome.dart';
import 'package:google_live/widgets/driverHome.dart';
import 'package:google_live/widgets/studentHome.dart';
import '../widgets/userLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoggedIn extends StatefulWidget {
  @override
  _LoggedInState createState() => _LoggedInState();
}

class _LoggedInState extends State<LoggedIn> {
  bool visible = false;
  String token;

  @override
  void initState() {
    super.initState();
    _loggedIn();
    visible = true;
  }

  Future<void> _loggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.get('token');
    print(token);
    if (token == null || token == '') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginUser()),
      );
    } else {
      _studentApiGetRole();
    }
  }

  void _studentApiGetRole() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.get('token');
    String url = 'http://sghps.cityschools.co/studentapi/getrole?access_token=' +
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
    Map<String, dynamic> role = jsonDecode(reply);
    if (role['role_id']['role_id'] == 7) {
      print('if');
      setState(() {
        visible = false;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LocationHome()));
    } else if (role['role_id']['role_id'] == 4) {
      print('else if');
      setState(() {
        visible = false;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => StudentHome()));
    } else if (role['role_id']['role_id'] == 3) {
      print('else if else');
      setState(() {
        visible = false;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => TeacherHome()));
      
    }
    else {
      print('else');
      setState(() {
        visible = false;
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginUser()));
    }
    httpClient.close();
    return reply;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
    );
  }
}
