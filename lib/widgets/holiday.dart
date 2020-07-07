import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' show DateFormat;

DateTime _currentDate2 = DateTime.now();
final dates = new DateTime.now().year;
var dayOfYear = dates;
var visible;

class CalendarPage2 extends StatefulWidget {
  @override
  _CalendarPage2State createState() => new _CalendarPage2State();
}

class _CalendarPage2State extends State<CalendarPage2> {
  @override
  void initState() {
    super.initState();
    _studentAttendence();
    this.presarray.insert(0, "");
    this.absarray.insert(0, "");
    this.holiarray.insert(0, "");
  }

  Map<String, dynamic> user;
  bool loader = false;
  var fetiv;
  var pasr;
  var yr;
  var pday;
  var month;
  var attendence;
  var months;
  var pdays;
  var weekends;
  var presentdays;
  var daysInCurrentMonth;
  var session;
  var starts;
  var end;
  var pr;
  var ab;
  var mon;
  var hol;
  var hoday;
  List<String> holydays = [];
  List<DateTime> thisSunday = [];
  List<DateTime> absentlist = [];
  List<DateTime> presents = [];
  List<DateTime> holidays = [];
  List presarray = [];
  List absarray = [];
  List holiarray = [];
  List ppp = [];
  String _currentMonth = DateFormat.yMMM().format(_currentDate2);
  DateTime _targetDateTime = _currentDate2;

  static Widget _presentIcon(String day) => Container(
        decoration: BoxDecoration(
          // color: Colors.green,
          borderRadius: BorderRadius.all(
            Radius.circular(1000),
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: Colors.green,
            ),
          ),
        ),
      );
  static Widget _absentIcon(String day) => Container(
        decoration: BoxDecoration(
          // color: Colors.red,
          borderRadius: BorderRadius.all(
            Radius.circular(1000),
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ),
      );

  static Widget _holidaysIcon(String day) => Container(
        decoration: BoxDecoration(
          // color: Colors.yellow,
          borderRadius: BorderRadius.all(
            Radius.circular(1000),
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: Colors.yellow,
            ),
          ),
        ),
      );

  EventList<Event> _markedDateMap = new EventList<Event>(
    events: {},
  );

  CalendarCarousel _calendarCarouselNoHeader;

  double cHeight;

  Future<void> _studentAttendence() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/attendance?access_token=' +
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
      this.user = jsonDecode(reply);
      this.attendence = user['attendance'];
      this.fetiv = user['cal'];
      this.session = user['session'];
      this.starts = session['batch_start'];

      print(_targetDateTime);
      this.pasr = DateTime.parse(this.starts);
      print(this.pasr);
      var yea = pasr.year;
      var mon = pasr.month;
      this.end = session['batch_end'];
      var ed = DateTime.parse(this.end);
      var edyr = ed.year;
      var edmon = ed.month;
      for (int i = 1; i <= edmon; i++) {
        int presntcount = 0;
        int absentcount = 0;
        int suncount = 0;
        this.holydays = [];
        int dcm = daysInMonth(DateTime(edyr, i, 1));
        for (int t = 1; t <= dcm; t++) {
          int bb = 0;
          var now = new DateTime(edyr, i, t);
          int today = now.weekday;
          var dayNr = (today + 7) % 7;
          var a = now.subtract(new Duration(days: (dayNr))).toString();
          var sd = DateTime.parse(a);
          var sda = sd.day;
          if (t == sda) {
            this.thisSunday += [DateTime(edyr, i, sda)];
            suncount++;
          } else {
            for (int j = 0; j < fetiv[i.toString()].length; j++) {
              var f = (fetiv[i.toString()][j]);
              if (f != "") {
                this.hoday = f['value'];
                this.holydays.add(f['value']);

                var inh = int.parse(this.hoday);
                //print(inh);
                if (t == inh) {
                  this.thisSunday += [DateTime(edyr, i, inh)];
                  suncount++;
                  bb = 1;
                  break;
                }
              }
            }
            if ((attendence[i.toString()].length) > 1) {
              for (int j = 0; j < attendence[i.toString()].length; j++) {
                if (int.parse(attendence[i.toString()][j]) == t) {
                  this.presents += [
                    DateTime(edyr, i, int.parse(attendence[i.toString()][j]))
                  ];
                  presntcount++;

                  bb = 1;
                  break;
                } //compare days if present or absents
              }

              if (bb == 0) {
                this.absentlist += [DateTime(edyr, i, t)];
                absentcount++;
              }
            } else {
              this.absentlist += [DateTime(edyr, i, t)];
              absentcount++;
            } //no present founds in month all absents
          } //sunday else ends

        } //daysInMonth ends
        this.holiarray.insert(i, suncount);
        this.presarray.insert(i, presntcount);
        this.absarray.insert(i, absentcount);
      } //Month  ends
      for (int i = mon; i <= (this.attendence.length); i++) {
        int presntcount = 0;
        int absentcount = 0;
        int suncount = 0;
        int dcm = daysInMonth(DateTime(yea, i, 1));
        for (int t = 1; t <= dcm; t++) {
          int bb = 0;
          var now = new DateTime(yea, i, t);
          int today = now.weekday;
          var dayNr = (today + 7) % 7;
          var a = now.subtract(new Duration(days: (dayNr))).toString();
          var sd = DateTime.parse(a);
          var sda = sd.day;
          if (t == sda) {
            this.thisSunday += [DateTime(yea, i, sda)];
            suncount++;
          } else {
            for (int j = 0; j < fetiv[i.toString()].length; j++) {
              var f = (fetiv[i.toString()][j]);
              if (f != "") {
                this.hoday = f['value'];
                this.holydays.add(f['value']);
                //print(hoday);

                var inh = int.parse(this.hoday);
                //print(inh);
                if (t == inh) {
                  this.thisSunday += [DateTime(yea, i, inh)];
                  suncount++;
                  bb = 1;
                  break;
                }
              }
            }
            if ((attendence[i.toString()].length) > 1) {
              for (int j = 0; j < attendence[i.toString()].length; j++) {
                if (int.parse(attendence[i.toString()][j]) == t) {
                  this.presents += [
                    DateTime(yea, i, int.parse(attendence[i.toString()][j]))
                  ];
                  presntcount++;
                  bb = 1;
                  break;
                }
              }

              if (bb == 0) {
                this.absentlist += [DateTime(yea, i, t)];
                absentcount++;
              }
            } else {
              this.absentlist += [DateTime(yea, i, t)];

              absentcount++;
            }
          }
        }
        this.holiarray.insert(i, suncount);
        this.presarray.insert(i, presntcount);
        this.absarray.insert(i, absentcount);
      }
      loader = true;
    });
  }

  int daysInMonth(DateTime date) {
    var firstDayThisMonth = new DateTime(date.year, date.month, date.day);
    //print('rrr:$firstDayThisMonth');
    var firstDayNextMonth = new DateTime(firstDayThisMonth.year,
        firstDayThisMonth.month + 1, firstDayThisMonth.day);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
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

  @override
  Widget build(BuildContext context) {
    cHeight = MediaQuery.of(context).size.height;
    for (int pday = 0; pday < this.presents.length; pday++) {
      _markedDateMap.add(
        this.presents[pday],
        new Event(
          date: this.presents[pday],
          title: 'Event 5',
          icon: _presentIcon(
            this.presents[pday].day.toString(),
          ),
        ),
      );
    }

    for (int aday = 0; aday < this.absentlist.length; aday++) {
      _markedDateMap.add(
        this.absentlist[aday],
        new Event(
          date: this.absentlist[aday],
          title: 'Event 5',
          icon: _absentIcon(
            this.absentlist[aday].day.toString(),
          ),
        ),
      );
    }

    for (int hday = 0; hday < this.thisSunday.length; hday++) {
      _markedDateMap.add(
        this.thisSunday[hday],
        new Event(
          date: this.thisSunday[hday],
          title: 'Event 5',
          icon: _holidaysIcon(
            this.thisSunday[hday].day.toString(),
          ),
        ),
      );
    }

    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      height: cHeight * 0.44,
      weekendTextStyle: TextStyle(
        color: Colors.blue,
      ),
      weekdayTextStyle: TextStyle(color: Colors.black),
      // headerTitleTouchable: true,
      thisMonthDayBorderColor: Colors.grey,
      todayButtonColor: Colors.blue,
      markedDatesMap: _markedDateMap,
      markedDateShowIcon: true,
      markedDateIconMaxShown: 1,
      showOnlyCurrentMonthDate: true,
      firstDayOfWeek: 1,
      showHeader: false,
      // selectedDateTime: _currentDate2,
      targetDateTime: _targetDateTime,
      pageScrollPhysics: NeverScrollableScrollPhysics(),
      minSelectedDate: _currentDate2.subtract(Duration(days: 60)),
      maxSelectedDate: _currentDate2,
      markedDateMoreShowTotal:
          null, // null for not showing hidden events indicator
      markedDateIconBuilder: (event) {
        return event.icon;
      },
    );
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Color.fromRGBO(33, 23, 47, 1),
          title: new Text("Attendance"),
          centerTitle: true,
        ),
        body: loader
            ? RefreshIndicator(
                onRefresh: () async {
                  _studentAttendence();
                  return await Future.delayed(Duration(seconds: 3));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(
                          top: 30.0,
                          bottom: 16.0,
                          left: 16.0,
                          right: 16.0,
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                                child: Text(
                              _currentMonth,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                              ),
                            )),
                            FlatButton(
                              child: Text('PREV'),
                              onPressed: () {
                                setState(() {
                                  _targetDateTime =

                                      //_currentDate2;
                                      DateTime(_currentDate2.year,
                                          _currentDate2.month - 1);
                                  _currentMonth =
                                      DateFormat.yMMM().format(_targetDateTime);
                                });
                                this.pr = this.presarray[_targetDateTime.month];
                                this.ab = this.absarray[_targetDateTime.month];
                                this.hol =
                                    this.holiarray[_targetDateTime.month];
                              },
                            ),
                            FlatButton(
                              child: Text('NEXT'),
                              onPressed: () {
                                setState(() {
                                  _targetDateTime = _currentDate2;
                                  // DateTime(
                                  //     _targetDateTime.year, _targetDateTime.month + 1);
                                  _currentMonth =
                                      DateFormat.yMMM().format(_targetDateTime);
                                  this.pr = presarray[_targetDateTime.month];
                                  this.ab = absarray[_targetDateTime.month];
                                  this.hol =
                                      this.holiarray[_targetDateTime.month];
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      Card(
                        color: Colors.grey[200],
                        //margin: EdgeInsets.symmetric(horizontal: 16.0),
                        child: _calendarCarouselNoHeader,
                      ),
                      markerRepresent(Colors.red, "Absent:$ab"),
                      markerRepresent(Colors.green, "Present:$pr"),
                      markerRepresent(Colors.yellow, "Holiday:$hol"),
                    ],
                  ),
                ),
              )
            : bodyProgress);
  }

  Widget markerRepresent(Color color, String data) {
    return new ListTile(
      leading: new CircleAvatar(
        backgroundColor: color,
        radius: cHeight * 0.022,
      ),
      title: new Text(
        data,
      ),
    );
  }
}
