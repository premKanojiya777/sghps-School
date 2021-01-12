import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/widgets/NotificationHistory.dart';
import 'package:google_live/widgets/SendNotification.dart';
import 'package:google_live/widgets/TeacherNotification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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
        this.cordi = permission['cordi'];
      });

      print('CHeck: $cordi');
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              this.cordi == true
                  ? Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 7,
                          ),
                          SizedBox.fromSize(
                            size: Size(120, 120), // button width and height
                            child: ClipOval(
                              child: Material(
                                color:
                                    Color.fromRGBO(33, 23, 47, 1), // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TeacherNotification()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.markunread,
                                        color: Colors.white,
                                      ), // icon
                                      Text(
                                        "Receive",
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
                                color:
                                    Color.fromRGBO(33, 23, 47, 1), // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NotificationHistory()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.history,
                                        color: Colors.white,
                                      ), // icon
                                      Text(
                                        "History",
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
                                color:
                                    Color.fromRGBO(33, 23, 47, 1), // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SendNotification()),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.send,
                                          color: Colors.white), // icon
                                      Text(
                                        "Send",
                                        style: TextStyle(color: Colors.white),
                                      ), // text
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 7,
                          ),
                        ],
                      ),
                  )
                  : Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: 7,
                          ),
                          SizedBox.fromSize(
                            size: Size(120, 120), // button width and height
                            child: ClipOval(
                              child: Material(
                                color:
                                    Color.fromRGBO(33, 23, 47, 1), // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TeacherNotification()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.markunread,
                                        color: Colors.white,
                                      ), // icon
                                      Text(
                                        "Receive",
                                        style: TextStyle(color: Colors.white),
                                      ), // text
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
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
