import 'dart:convert';
import 'package:google_live/widgets/StudentSubjects.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

DateTime selectedDate = DateTime.now();

class StudentOnlineTeaching extends StatefulWidget {
  @override
  _StudentOnlineTeachingState createState() => _StudentOnlineTeachingState();
}

class _StudentOnlineTeachingState extends State<StudentOnlineTeaching> {
  DateTime dateTime = selectedDate;

  var batch_start;
  var batch_end;
  var start;
  var end;
  bool error;
  var dateofpresence;

  void initState() {
    super.initState();
    _checkSessionForTeaching();
    // _addAttendance();
    // _checkAttendance();
    super.initState();
  }

  void _checkSessionForTeaching() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'https://sghps.cityschools.co/studentapi/session?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      Map<String, dynamic> session = json.decode(res.body);
      setState(() {
        var checkSession = session['session'];
        this.batch_start = checkSession['batch_start'];
        this.batch_end = checkSession['batch_end'];
      });
    }).catchError((onError) {
      print(onError);
    });
    List<String> startaarray = this.batch_start.toString().split("-");
    this.start = new DateTime(int.parse(startaarray[0]),
        int.parse(startaarray[1]), int.parse(startaarray[2]));
    // print('Strtt: ${this.start}');
    List<String> endarray = this.batch_end.toString().split("-");
    this.end = new DateTime(
        int.parse(endarray[0]), int.parse(endarray[1]), int.parse(endarray[2]));
  }



  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: this.start,
        lastDate: this.end);
    if (picked != null && picked != selectedDate)
      setState(() {
        dateTime = picked;
      });
  }

  // void _handleRadioValueChange2(int value) {
  //   setState(() {
  //     _radioValue1 = value;
  //     dateofpresence = dateTime;
  //   print(dateofpresence);

      
      
  //   });
  // }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
        title: Text('Student Online Teaching'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Card(
                    child: Text(
                      'Current Date : 0${dateTime.month}' +
                          '-' +
                          '${dateTime.day}' +
                          '-' +
                          '${dateTime.year}',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                RaisedButton(
                  color: Color.fromRGBO(33, 23, 47, 1),
                  onPressed: () => _selectDate(context),
                  child: Text(
                    'Select date',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     Align(
            //       alignment: Alignment(0.7, 0.0),
            //       child: Text(
            //         'Mark Your Attendance',
            //         style: new TextStyle(
            //           fontWeight: FontWeight.bold,
            //           fontSize: 17.0,
            //         ),
            //       ),
            //     ),
            //     // error == false ?
            //     //     new FlatButton(
            //     //   child: Icon(
            //     //        Icons.radio_button_checked
            //     //       ), onPressed: () {},

            //     // ) :
            //     new Radio(
            //       value: 1,
            //       groupValue: _radioValue1,
            //       onChanged: _handleRadioValueChange2,
            //     ),
                
            //   ],
            // ),
            // SizedBox(
            //   height: 20.0,
            // ),
            RaisedButton(
              color: Color.fromRGBO(33, 23, 47, 1),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentSubject(
                            datepick: dateTime,
                            
                          )),
                );
              },
              child: Text(
                'Search',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
