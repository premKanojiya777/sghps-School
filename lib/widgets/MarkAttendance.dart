import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


DateTime selectedDate = DateTime.now();
class MarkAttendance extends StatefulWidget {
  @override
  _MarkAttendanceState createState() => _MarkAttendanceState();
}

class _MarkAttendanceState extends State<MarkAttendance> {
  DateTime dateTime = selectedDate;
  var error;
  int _radioValue1 =-1;
  Future<void> _addAttendance(int value) async {
   
    
    final prefs = await SharedPreferences.getInstance();
    String url = 'http://sghps.cityschools.co/studentapi/attendance_student';

    final response = await http.post(url, body: {
      'access_token': prefs.get('token'),
      'date': dateTime.toString(),
    }, headers: {
      "Accept": "application/json"
    }).then((res) {
      setState(() {
        var added = json.decode(res.body);
        this.error = added['error'];
        var attendance = added['message'];
        print(added);
        Toast.show(attendance, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      });
    }).catchError((onError) {
      print(onError);

    });
     setState(() {
      _radioValue1 =value;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mark Attendance'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
      ),
      body: Column(
        children: <Widget>[
           Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment(0.7, 0.0),
                child: Text(
                  'Mark Your Attendance',
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
              ),
               new Radio(
                  value: 1,
                  groupValue: error == false ? _radioValue1 : null,
                  onChanged: _addAttendance,
                ),
        ],
           ),
        ],
      ),
    );
  }
}