import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/widgets/DateSheet.dart';
import 'package:google_live/widgets/HolidayHomeWork.dart';
import 'package:google_live/widgets/ImageGallery.dart';
import 'package:google_live/widgets/LibraryList.dart';
import 'package:google_live/widgets/OnlineExam.dart';
import 'package:google_live/widgets/SearchHomework.dart';
import 'package:google_live/widgets/StudentNotifications.dart';
import 'package:google_live/widgets/StudentOnlineTeaching.dart';
import 'package:google_live/widgets/Student_Leaves.dart';
import 'package:google_live/widgets/StudentsResults.dart';
import 'package:google_live/widgets/Syllabus.dart';
import 'package:google_live/widgets/holiday.dart';
import 'package:google_live/widgets/studentProfile.dart';
import 'package:google_live/widgets/timeTable.dart';
import 'package:google_live/widgets/userLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

DateTime selectedDate = DateTime.now();

class StudentHome extends StatefulWidget {
  @override
  _StudentHomeState createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  DateTime dateTime = selectedDate;
  var error;
  bool visible = false;
  var savekey = '';

  @override
  void initState() {
    super.initState();
    visible = true;
  }

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

  Future<void> _addAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    String url = 'https://sghps.cityschools.co/studentapi/attendance_student';

    final response = await http.post(url, body: {
      'access_token': prefs.get('token'),
      'date': dateTime.toString(),
    }, headers: {
      "Accept": "application/json"
    }).then((res) {
      setState(() {
        var added = json.decode(res.body);
        this.error = added['error'];
        var message = added['message'];
        print(added);
        Toast.show(message, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  var bodyProgress = new Container(
    child: new Stack(
      children: <Widget>[
        new Container(
          alignment: AlignmentDirectional.center,
          decoration: new BoxDecoration(
            color: Colors.white70,
          ),
          child: new Container(
            decoration: new BoxDecoration(
                color: Colors.grey,
                borderRadius: new BorderRadius.circular(10.0)),
            width: 140,
            height: 120,
            alignment: AlignmentDirectional.center,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Center(
                  child: new SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: new CircularProgressIndicator(
                      value: null,
                      strokeWidth: 7.0,
                    ),
                  ),
                ),
                new Container(
                  margin: const EdgeInsets.only(top: 25.0),
                  child: new Center(
                    child: new Text(
                      "loading.. wait...",
                      style: new TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

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
      body: visible
          ? SingleChildScrollView(
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
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
                                color: Color.fromRGBO(
                                    33, 23, 47, 1), // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StudentProfile()),
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
                                              CalendarPage2()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.assignment,
                                        color: Colors.white,
                                      ), // icon
                                      Text(
                                        "Attendence",
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
                                          builder: (context) => TimeTable()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.date_range,
                                          color: Colors.white), // icon
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
                          SizedBox(
                            width: 7,
                          ),
                        ],
                      ),
                    ),
                    Padding(
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
                                color: Color.fromRGBO(
                                    33, 23, 47, 1), // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ImageGallery()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.photo_library,
                                          color: Colors.white), // icon
                                      Text(
                                        "Gallery",
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
                                          builder: (context) => Syllabus()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.picture_as_pdf,
                                        color: Colors.white,
                                      ), // icon
                                      Text(
                                        "Sylabus",
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
                                              HolidayHomeWork()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.event_available,
                                          color: Colors.white), // icon
                                      Text(
                                        "Holiday HW",
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
                    ),
                    Padding(
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
                                color: Color.fromRGBO(
                                    33, 23, 47, 1), // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StudentNotific()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.notifications,
                                          color: Colors.white), // icon
                                      Text(
                                        "Notification",
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
                                              SearchHomework()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.format_list_numbered,
                                        color: Colors.white,
                                      ), // icon
                                      Text(
                                        "HomeWork",
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
                                          builder: (context) => OnlineExams()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.desktop_mac,
                                          color: Colors.white), // icon
                                      Text(
                                        "Online Exam",
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
                    Padding(
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
                                color: Color.fromRGBO(
                                    33, 23, 47, 1), // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DateSheet()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.card_giftcard,
                                        color: Colors.white,
                                      ), // icon
                                      Text(
                                        "DateSheet",
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
                                          builder: (context) => LibraryList()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.library_books,
                                        color: Colors.white,
                                      ), // icon
                                      Text(
                                        "Library",
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
                                    _addAttendance();
                                    // return showDialog(
                                    //     context: context,
                                    //     builder: (_) => AlertDialog(
                                    //           title: Text('Coming Soon'),
                                    //         ));
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.check,
                                          color: Colors.white), // icon
                                      Text(
                                        "Mark Attendance",
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
                    ),
                    Padding(
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
                                color: Color.fromRGBO(
                                    33, 23, 47, 1), // button color
                                child: InkWell(
                                  splashColor: Colors.green, // splash color
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              StudentOnlineTeaching()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.textsms,
                                          color: Colors.white), // icon
                                      Text(
                                        "Online Teching",
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
                                              StudentLeaves()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.launch,
                                          color: Colors.white), // icon
                                      Text(
                                        "Leave",
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
                                              StudentsResults()),
                                    );
                                  }, // button pressed
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.trending_up,
                                          color: Colors.white), // icon
                                      Text(
                                        "Result",
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
                    ),
                  ],
                ),
              ),
            )
          : bodyProgress,
    );
  }
}
