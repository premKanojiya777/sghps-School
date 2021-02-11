import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentProfile extends StatefulWidget {
  @override
  _StudentProfileState createState() => _StudentProfileState();
}

class _StudentProfileState extends State<StudentProfile> {
  Map<String, dynamic> studentProfile;
  String firstname = '';
  String lastname = '';
  String username = '';
  String fathername = '';
  String dob = '';
  String mobno = '';
  String section = '';
  String profileImaage;
  String classname = '';
  bool loader = false;
  @override
  void initState() {
    super.initState();
    _studentProfile();
  }

  Future<void> _studentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/profile?access_token=' +
            prefs.get('token');
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
    httpClient.close();
    setState(() {
      this.studentProfile = jsonDecode(reply);
      var student = this.studentProfile['student'];
      // print(student);
      this.firstname = student['first_name'];
      this.lastname = student['last_name'];
      this.username = student['school_regd_no'];
      this.fathername = student['students']['father_name'];
      this.mobno = student['students']['mobile'];
      this.dob = student['students']['dob'];
      this.section = student['students']['section']['section_name'];
      this.profileImaage = student['image'];
      this.classname = student['students']['classs']['class_name'];
      loader = true;
    });
    // print(this.profileImaage);
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
                color: Colors.blue[100],
                borderRadius: new BorderRadius.circular(3.0)),
            width: 140,
            height: 70,
            alignment: AlignmentDirectional.center,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Center(
                  child: new SizedBox(
                    height: 30.0,
                    width: 30.0,
                    child: new CircularProgressIndicator(
                      value: null,
                      strokeWidth: 4.0,
                    ),
                  ),
                ),
                SizedBox(
                  width: 9,
                ),
                new Container(
                  // margin: const EdgeInsets.only(top: 25.0),
                  child: new Center(
                    child: new Text(
                      "Loading",
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

  @override
  Widget build(BuildContext context) {
    // print(this.profileImaage);
    return Scaffold(
        // backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(33, 23, 47, 1),
          title: Text('Student Profile'),
          centerTitle: true,
        ),
        body: loader
            ? RefreshIndicator(
                onRefresh: () async {
                  _studentProfile();
                  return await Future.delayed(Duration(seconds: 3));
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          height: 120.0,
                          color: Color.fromRGBO(33, 23, 47, 1),
                        ),
                        SizedBox(
                          height: 60,
                        ),
                        Divider(),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Name:  ',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Spacer(),
                                        lastname == null
                                            ? Text('${this.firstname}',
                                                style: TextStyle(
                                                    fontSize: 15))
                                            : Text(
                                                '${this.firstname}' +
                                                    '\t' +
                                                    '${this.lastname}',
                                                style: TextStyle(
                                                    fontSize: 15)),
                                  SizedBox(width: 150,),

                                      ]),
                                  SizedBox(height: 15.0),
                                  Divider(),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Date OF Birth:  ',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 15.0),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 45),
                                          child: Text(this.dob,
                                              style: TextStyle(fontSize: 15)),
                                        ),
                                      ]),
                                  SizedBox(height: 15.0),
                                  Divider(),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Username Name:  ',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 15.0),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 25),
                                          child: Text(this.username,
                                              style: TextStyle(fontSize: 15)),
                                        ),
                                      ]),
                                  SizedBox(height: 15.0),
                                  Divider(),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Class-Section:  ',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 46),
                                          child: Text(this.section,
                                              style: TextStyle(fontSize: 15)),
                                        ),
                                      ]),
                                  SizedBox(height: 15.0),
                                  Divider(),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Father Name:  ',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 55),
                                          child: Text(this.fathername,
                                              style: TextStyle(fontSize: 15)),
                                        ),
                                      ]),
                                  SizedBox(height: 15.0),
                                  Divider(),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Mobile:  ',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 100),
                                          child: Text(this.mobno,
                                              style: TextStyle(fontSize: 15)),
                                        ),
                                      ]),
                                  SizedBox(height: 15.0),
                                  Divider(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top:
                          40.0, // (background container size) - (circle height / 2)
                      child: Container(
                        height: 140.0,
                        width: 140.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.transparent),
                        child: CircleAvatar(
                          radius: 90.0,
                          backgroundImage: (this.profileImaage == null ||
                                  this.profileImaage == '')
                              ? AssetImage('placeholder_image.png')
                              : NetworkImage(
                                  'http://sghps.cityschools.co/uploads/students/${this.profileImaage}'),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : bodyProgress);
  }
}
