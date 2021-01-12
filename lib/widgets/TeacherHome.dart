import 'dart:convert';
import 'dart:io';
import 'package:google_live/widgets/ClassAttendance.dart';
import 'package:google_live/widgets/ClassTimeTable.dart';
import 'package:google_live/widgets/Digital.dart';
import 'package:google_live/widgets/NotificationPage.dart';
import 'package:google_live/widgets/OnlineTeaching.dart';
import 'package:google_live/widgets/SendHomework.dart';
import 'package:google_live/widgets/TextField.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/widgets/TeacherAttendance.dart';
import 'package:google_live/widgets/TeacherNotification.dart';
import 'package:google_live/widgets/TeacherProfile.dart';
import 'package:google_live/widgets/TeacherTimeTable.dart';
import 'package:google_live/widgets/userLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherHome extends StatefulWidget {
  @override
  _TeacherHomeState createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  var checkIncharge;
  var cordi;

  @override
  void initState() {
    super.initState();
    _checkIncharge();
    super.initState();
  }

  void _checkIncharge() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/teacherapi/incharge_check?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      Map<String, dynamic> permission = json.decode(res.body);
      setState(() {
        this.checkIncharge = permission['allo'];
        this.cordi = permission['cordi'];
      });

      print('CHeck: $checkIncharge');
    }).catchError((onError) {
      print(onError);
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    String url = 'http://sghps.cityschools.co/studentapi/logout?access_token=' +
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
        title: Text('Home'),
        centerTitle: true,
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.exit_to_app), onPressed: _logout),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: this.checkIncharge == true
              ? Column(
                children: <Widget>[
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 7,),
                        SizedBox.fromSize(
                          size: Size(120, 120), // button width and height
                          child: ClipOval(
                            child: Material(
                              color: Color.fromRGBO(
                                  33, 23, 47, 1), // button color
                              child: InkWell(
                                splashColor: Colors.green, // splash color
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TeacherProfile()),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.school,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "Profile",
                                      style:
                                          TextStyle(color: Colors.white),
                                    ), // text
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        SizedBox.fromSize(
                          size: Size(120, 120), // button width and height
                          child: ClipOval(
                            child: Material(
                              color: Color.fromRGBO(
                                  33, 23, 47, 1), // button color
                              child: InkWell(
                                splashColor: Colors.green, // splash color
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TeacherTimeTable()),
                                  );
                                }, // button pressed
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.line_style,
                                      color: Colors.white,
                                    ), // icon
                                    Text(
                                      "Time Table",
                                      style:
                                          TextStyle(color: Colors.white),
                                    ), // text
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        SizedBox.fromSize(
                          size: Size(120, 120), // button width and height
                          child: ClipOval(
                            child: Material(
                              color: Color.fromRGBO(
                                  33, 23, 47, 1), // button color
                              child: InkWell(
                                splashColor: Colors.green, // splash color
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TeacherAttendance()),
                                  );
                                }, // button pressed
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.calendar_today,
                                        color: Colors.white), // icon
                                    Text(
                                      "Attendance",
                                      style:
                                          TextStyle(color: Colors.white),
                                    ), // text
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 7,),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 7,),
                        SizedBox.fromSize(
                          size: Size(120, 120), // button width and height
                          child: ClipOval(
                            child: Material(
                              color: Color.fromRGBO(
                                  33, 23, 47, 1), // button color
                              child: InkWell(
                                splashColor: Colors.green, // splash color
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            NotificationPage()),
                                  );
                                }, // button pressed
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.line_weight,
                                      color: Colors.white,
                                    ), // icon
                                    Text(
                                      "Notifications",
                                      style:
                                          TextStyle(color: Colors.white),
                                    ), // text
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Spacer(),
                        this.cordi == true
                            ? SizedBox.fromSize(
                              size: Size(
                                  120, 120), // button width and height
                              child: ClipOval(
                                child: Material(
                                  color: Color.fromRGBO(
                                      33, 23, 47, 1), // button color
                                  child: InkWell(
                                    splashColor:
                                        Colors.green, // splash color
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SendHomework()),
                                      );
                                    }, // button pressed
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.library_books,
                                          color: Colors.white,
                                        ), // icon
                                        Text(
                                          "Homework",
                                          style: TextStyle(
                                              color: Colors.white),
                                        ), // text
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            : Container(),
                            Spacer(),
                        SizedBox.fromSize(
                          size: Size(120, 120), // button width and height
                          child: ClipOval(
                            child: Material(
                              color: Color.fromRGBO(
                                  33, 23, 47, 1), // button color
                              child: InkWell(
                                splashColor: Colors.green, // splash color
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ClassTimeTable()),
                                  );
                                }, // button pressed
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.textsms,
                                        color: Colors.white), // icon
                                    Text(
                                      "Class TimeTable",
                                      style:
                                          TextStyle(color: Colors.white),
                                    ), // text
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 7,),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 7,),
                        SizedBox.fromSize(
                          size: Size(120, 120), // button width and height
                          child: ClipOval(
                            child: Material(
                              color: Color.fromRGBO(
                                  33, 23, 47, 1), // button color
                              child: InkWell(
                                splashColor: Colors.green, // splash color
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ClassAttendance()),
                                  );
                                }, // button pressed
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.line_weight,
                                      color: Colors.white,
                                    ), // icon
                                    Text(
                                      "Cl Attendance",
                                      style: TextStyle(color: Colors.white),
                                    ), // text
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Spacer(),
                        SizedBox(width: 9,),
                        SizedBox.fromSize(
                          size: Size(120, 120), // button width and height
                          child: ClipOval(
                            child: Material(
                              color: Color.fromRGBO(
                                  33, 23, 47, 1), // button color
                              child: InkWell(
                                splashColor: Colors.green, // splash color
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OnlineTeaching()),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.school,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      "Online Teaching",
                                      style: TextStyle(color: Colors.white),
                                    ), // text
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 7,),
                      ],
                    ),
                  )
                ],
              )
              : Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: <Widget>[
                         SizedBox(width: 7,),
                          SizedBox.fromSize(
                            size: Size(120, 120), // button width and height
                            child: ClipOval(
                              child: Material(
                                color: Color.fromRGBO(
                                    33, 23, 47, 1), // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TeacherProfile()),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.school,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Profile",
                                        style: TextStyle(color: Colors.white),
                                      ), // text
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          SizedBox.fromSize(
                            size: Size(120, 120), // button width and height
                            child: ClipOval(
                              child: Material(
                                color: Color.fromRGBO(
                                    33, 23, 47, 1), // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TeacherTimeTable()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.line_style,
                                        color: Colors.white,
                                      ), // icon
                                      Text(
                                        "Time Table",
                                        style: TextStyle(color: Colors.white),
                                      ), // text
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                         Spacer(),
                          SizedBox.fromSize(
                            size: Size(120, 120), // button width and height
                            child: ClipOval(
                              child: Material(
                                color: Color.fromRGBO(
                                    33, 23, 47, 1), // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TeacherAttendance()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.calendar_today,
                                          color: Colors.white), // icon
                                      Text(
                                        "Attendance",
                                        style: TextStyle(color: Colors.white),
                                      ), // text
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 7,),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 7,),
                          SizedBox.fromSize(
                            size: Size(120, 120), // button width and height
                            child: ClipOval(
                              child: Material(
                                color: Color.fromRGBO(
                                    33, 23, 47, 1), // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NotificationPage()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.line_weight,
                                        color: Colors.white,
                                      ), // icon
                                      Text(
                                        "Notifications",
                                        style: TextStyle(color: Colors.white),
                                      ), // text
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
