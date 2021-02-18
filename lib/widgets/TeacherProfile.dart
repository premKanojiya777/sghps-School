import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherProfile extends StatefulWidget {
  @override
  _TeacherProfileState createState() => _TeacherProfileState();
}

class _TeacherProfileState extends State<TeacherProfile> {
  Map<String, dynamic> tprofile;
  String firstname = '';
  String lastname = '';
  String username = '';
  String mobno = '';
  String email = '';
  String image = '';
  String role = '';
  String dob = '';
  String address = '';
  String fathername = '';
  String mothername = '';
  bool respons = false;

  @override
  void initState() {
    super.initState();
    _teacherProfile();
    super.initState();
  }

  Future<void> _teacherProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'https://sghps.cityschools.co/teacherapi/teacherprofile?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      setState(() {
        this.tprofile = json.decode(res.body);
        var teacher = tprofile['teacher'];
        this.fathername = teacher['father_name'];
        this.mothername = teacher['mother_name'];
        this.dob = teacher['dob'];
        this.address = teacher['address'];
        this.firstname = teacher['user']['first_name'];
        // this.lastname = teacher['user']['last_name'];
        this.mobno = teacher['user']['mobile'];
        this.username = teacher['user']['school_regd_no'];
        this.image = teacher['image'];
        this.email = teacher['user']['email'];
        this.role = teacher['user']['role']['role_name'];
      });
      if (this.tprofile != null) {
        respons = true;
      }
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(33, 23, 47, 1),
          title: Text('Profile'),
          centerTitle: true,
          
        ),
        body: respons
            ? RefreshIndicator(
              onRefresh: _teacherProfile,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Name:  ',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        // Spacer(),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 100),
                                          child: Text(this.firstname,
                                              style: TextStyle(fontSize: 15)),
                                        ),
                                      ]),
                                  SizedBox(height: 15.0),
                                  Divider(),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Email ID:  ',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 85),
                                          child: Text(this.email,
                                              style: TextStyle(
                                                fontSize: 15,
                                              )),
                                        ),
                                      ]),
                                  SizedBox(height: 15.0),
                                  Divider(),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Role:  ',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 115),
                                          child: Text(this.role,
                                              style: TextStyle(fontSize: 15)),
                                        ),
                                      ]),
                                  SizedBox(height: 15.0),
                                  Divider(),
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
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
                                      mainAxisAlignment: MainAxisAlignment.start,
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
                                      mainAxisAlignment: MainAxisAlignment.start,
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
                                  Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Mother Name:',
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 55),
                                          child: Text(this.mothername,
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
                      top: 40.0,
                      child: Container(
                        height: 140.0,
                        width: 140.0,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.transparent),
                        child: CircleAvatar(
                          radius: 90.0,
                          backgroundImage: (this.image == null ||
                                  this.image == '')
                              ? AssetImage('placeholder_image.png')
                              : NetworkImage(
                                  'http://sghps.cityschools.co/uploads/teachers/${this.image}'),
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
