import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/models/PeriodValue.dart';
import 'package:google_live/models/TimeTableModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TeacherTimeTable extends StatefulWidget {
  @override
  _TeacherTimeTableState createState() => _TeacherTimeTableState();
}

class _TeacherTimeTableState extends State<TeacherTimeTable> {
  Map<String, dynamic> timeTable;
  TimeTableModel timeTableData;
    Future<List<Period>> _filter;
  bool repons = false;
  var mondayWidgets = List<Widget>();
  var tuesdayWidgets = List<Widget>();
  var wednesdayWidgets = List<Widget>();
  var thursdayWidgets = List<Widget>();
  var fridayWidgets = List<Widget>();
  var saturdayWidgets = List<Widget>();
  @override
  void initState() {
    super.initState();
    _timeTable();
  }

  Future<void> _timeTable() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/teacherapi/timetable?access_token=' +
            prefs.get('token');
    await getTimeTable(url, prefs.get('token'));
  }

  Future<String> getTimeTable(String url, accessToken) async {
    final response = await http
        .get(url, headers: {"Content-Type": "application/json"}).then((res) {
      //print({"res", res.body});
      Map<String, dynamic> user = jsonDecode(res.body);
      timeTableData = TimeTableModel.fromJson(user);

      if (timeTableData.error) {
        print('error');
      } else {
        mondayWidgets = [];
        tuesdayWidgets = [];
        wednesdayWidgets = [];
        thursdayWidgets = [];
        fridayWidgets = [];
        saturdayWidgets = [];
        for (Period period in timeTableData.monday.periodList) {
          mondayWidgets.add(_commonRow('${period.period}', '${period.value}'));
        }
        for (Period period in timeTableData.tuesday.periodList) {
          tuesdayWidgets.add(_commonRow('${period.period}', '${period.value}'));
        }
        for (Period period in timeTableData.wednesday.periodList) {
          wednesdayWidgets
              .add(_commonRow('${period.period}', '${period.value}'));
        }
        for (Period period in timeTableData.thursday.periodList) {
          thursdayWidgets
              .add(_commonRow('${period.period}', '${period.value}'));
        }
        for (Period period in timeTableData.friday.periodList) {
          fridayWidgets.add(_commonRow('${period.period}', '${period.value}'));
        }
        for (Period period in timeTableData.saturday.periodList) {
          saturdayWidgets
              .add(_commonRow('${period.period}', '${period.value}'));
        }
      }
      repons = true;
    }).catchError((onError) {
      print(onError);
    });
    setState(() {});
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
          title: Text('Time Table'),
          centerTitle: true,
        ),
        body: repons
            ? RefreshIndicator(
                onRefresh: () async{
                  _timeTable();
                 return await Future.delayed(Duration(seconds: 3));
                },
                child: Card(
                  margin: EdgeInsets.all(10),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Tabs(refresh: () => setState(() {})),
                        value == 0 ? _monTabWidget() : Container(),
                        value == 1 ? _tueTabWidget() : Container(),
                        value == 2 ? _wedTabWidget() : Container(),
                        value == 3 ? _thusTabWidget() : Container(),
                        value == 4 ? _friTabWidget() : Container(),
                        value == 5 ? _satTabWidget() : Container(),
                      ],
                    ),
                  ),
                ),
              )
            : bodyProgress);
  }

  Widget _monTabWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 12, right: 20),
          child: Row(
            children: <Widget>[
              Text(
                'Period',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 90),
              Text(
                'Subject/Teacher',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Divider(),
        ListView(shrinkWrap: true, children: <Widget>[
          ...mondayWidgets,
        ])
      ],
    );
  }

  Widget _tueTabWidget() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 12, right: 20),
          child: Row(
            children: <Widget>[
              Text(
                'Period',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 90),
              Text(
                'Subject/Teacher',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Divider(),
        ListView(shrinkWrap: true, children: <Widget>[
          ...tuesdayWidgets,
        ])
      ],
    );
  }

  Widget _wedTabWidget() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 12, right: 20),
          child: Row(
            children: <Widget>[
              Text(
                'Period',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 90),
              Text(
                'Subject/Teacher',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Divider(),
        ListView(shrinkWrap: true, children: <Widget>[
          ...wednesdayWidgets,
        ])
      ],
    );
  }

  Widget _thusTabWidget() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 12, right: 20),
          child: Row(
            children: <Widget>[
              Text(
                'Period',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 90),
              Text(
                'Subject/Teacher',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Divider(),
        ListView(shrinkWrap: true, children: <Widget>[
          ...thursdayWidgets,
        ])
      ],
    );
  }

  Widget _friTabWidget() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 12, right: 20),
          child: Row(
            children: <Widget>[
              Text(
                'Period',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 90),
              Text(
                'Subject/Teacher',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Divider(),
        ListView(shrinkWrap: true, children: <Widget>[
          ...fridayWidgets,
        ])
      ],
    );
  }

  Widget _satTabWidget() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 12, right: 20),
          child: Row(
            children: <Widget>[
              Text(
                'Period',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 90),
              Text(
                'Subject/Teacher',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Divider(),
        ListView(shrinkWrap: true, children: <Widget>[
          ...saturdayWidgets,
        ])
      ],
    );
  }

  Widget _commonRow(String label, String value) {
    return Container(
      width: 600,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: 10,
            ),
            child: Row(
              children: <Widget>[
                Text(label),
                Spacer(),
                Text(
                  "$value",
                  style: TextStyle(fontSize: 12),
                ),
                Spacer(),
              ],
            ),
          ),
          SizedBox(height: 5),
          Divider(),
        ],
      ),
    );
  }
}

class Tabs extends StatefulWidget {
  final Function refresh;

  Tabs({this.refresh});

  @override
  _TabsState createState() => _TabsState();
}

int value = 1;

class _TabsState extends State<Tabs> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(33, 23, 47, 1),
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          // SizedBox(width: 5),
          MyTab(
              text: 'Mon',
              isSelected: value == 0,
              onTap: () => _updateValue(0)),
          SizedBox(width: 5),
          MyTab(
              text: 'Tue',
              isSelected: value == 1,
              onTap: () => _updateValue(1)),
          SizedBox(width: 5),
          MyTab(
              text: 'Wed',
              isSelected: value == 2,
              onTap: () => _updateValue(2)),
          SizedBox(width: 5),
          MyTab(
              text: 'Thurs',
              isSelected: value == 3,
              onTap: () => _updateValue(3)),
          SizedBox(width: 5),
          MyTab(
              text: 'Fri',
              isSelected: value == 4,
              onTap: () => _updateValue(4)),
          SizedBox(width: 5),
          MyTab(
              text: 'Sat',
              isSelected: value == 5,
              onTap: () => _updateValue(5)),
          SizedBox(width: 5),
        ],
      ),
    );
  }

  void _updateValue(int newValue) {
    widget.refresh();
    setState(() {
      value = newValue;
    });
  }
}

class MyTab extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Function onTap;

  const MyTab(
      {Key key, @required this.isSelected, @required this.text, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              text,
              style: TextStyle(
                fontSize: isSelected ? 16 : 14,
                color: isSelected ? Colors.yellow : Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            Container(
              height: 6,
              width: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isSelected ? Color(0xFFFF5A1D) : Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
