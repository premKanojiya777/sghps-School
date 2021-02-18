import 'dart:convert';
import 'package:google_live/widgets/ShowSubjects.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

DateTime selectedDate = DateTime.now();

class OnlineTeaching extends StatefulWidget {
  @override
  _OnlineTeachingState createState() => _OnlineTeachingState();
}

class _OnlineTeachingState extends State<OnlineTeaching> {
  DateTime dateTime = selectedDate;
  bool respon = false;
  var batch_start;
  var batch_end;
  var start;
  var end;

  void initState() {
    super.initState();
    _checkSessionForTeaching();
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
        respon = true;
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
        title: Text('Online Teaching'),
        centerTitle: true,
      ),
      body: respon ?  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Card(
                    child: Text(
                      'Current Date : ${dateTime.month}' +
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
                      builder: (context) => ShowSubjects(
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
      ) : bodyProgress
    );
  }
}
