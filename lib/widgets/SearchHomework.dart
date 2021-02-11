import 'dart:convert';
import 'dart:io';
import 'package:google_live/models/StudentDailyHomework.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_live/models/SearchModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' show DateFormat;

DateTime dateTime = DateTime.now();

class SearchHomework extends StatefulWidget {
  // ExamplePage({ Key key }) : super(key: key);
  @override
  _SearchHomeworkState createState() => new _SearchHomeworkState();
}

class _SearchHomeworkState extends State<SearchHomework> {
  final TextEditingController _date = new TextEditingController();
  List<StudentDailyHomework> todayHomeWorkList = [];
  List<StudentDailyHomework> searchedHomeWorkList = [];

  String _currentMonth = DateFormat.yMMMMEEEEd().format(dateTime);
  bool loader = false;
  var homework;
  var dateForSearch;
  bool isClicked = false;

  @override
  void initState() {
    super.initState();
    _dailyHomework();
  }

  void _dailyHomework() async {
    todayHomeWorkList = [];
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/homework?access_token=' +
            prefs.get('token');

    final response = await http
        .get(url, headers: {"Content-Type": "application/json"}).then((res) {
      print(prefs.get('token'));
      setState(() {
        Map<String, dynamic> user = jsonDecode(res.body);

        homework = user['homework'];
        print('HOMEWORK:$homework');

        for (var hm in homework) {
          var homeWorkImg = hm['attach'];
          var date = hm['date'];
          var task = hm['task'];
          var subName = hm['subject'];
          StudentDailyHomework studentDailyHomework =
              StudentDailyHomework(subName, task, date, homeWorkImg);

          todayHomeWorkList.add(studentDailyHomework);
        }
        print(todayHomeWorkList.length);
        loader = true;
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime(2020, 04, 25),
        lastDate: DateTime(2021, 03, 30));
    if (picked != null && picked != dateTime)
      setState(() {
        dateTime = picked;
        print(dateTime);
        var date = dateTime;
        dateForSearch = "${date.month}/${date.day}/${date.year}";
        print(dateForSearch);
      });
  }

  Future<void> _searchHomework() async {
    // searchedHomeWorkList = [];
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/gethomework?access_token=' +
            prefs.get('token');
    Map dataMap = {
      'url': url,
      'date': dateForSearch,
    };
    print(dataMap);
    await apiRequest(url, dataMap);
  }

  Future<List<SearchModel>> apiRequest(String url, Map dataMap) async {
    String jsonString = json.encode(dataMap);
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    request.headers.contentType =
        new ContentType("application", "json", charset: "utf-8");
    request.headers.set('Content-Length', jsonString.length.toString());
    request.write(jsonString);
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    setState(() {
      Map<String, dynamic> works = jsonDecode(reply);
      // print(works);
      var homework = works['homework'];
      //  print(homework);
      for (var hm in homework) {
        var homeWorkImg = hm['attach'];
        var date = hm['date'];
        var task = hm['task'];
        var subName = hm['subject'];
        StudentDailyHomework studentDailyHomework =
            StudentDailyHomework(subName, task, date, homeWorkImg);

        searchedHomeWorkList.add(studentDailyHomework);
      }
      // _dailyHomework();
      loader = true;
      print(searchedHomeWorkList.length);
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
          title: Text('Homework'),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(33, 23, 47, 1),
        ),
        body: loader == false
            ? bodyProgress
            : RefreshIndicator(
                onRefresh: () async {
                  _dailyHomework();
                  return await Future.delayed(Duration(seconds: 3));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Search',
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          RaisedButton(
                            color: Colors.white,
                            child: Text(
                              DateFormat.yMMMMEEEEd().format(dateTime),
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              _selectDate(context);
                            },
                          ),
                          Container(
                            width: 340,
                            child: RaisedButton(
                              onPressed: () {
                                setState(() {
                                  _searchHomework();
                                  isClicked = true;
                                  todayHomeWorkList = [];
                                  searchedHomeWorkList = [];
                                });
                              },
                              color: Color.fromRGBO(33, 23, 47, 1),
                              textColor: Colors.white,
                              padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                              child: Text(
                                'Search',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          isClicked == false
                              ? Text(
                                  'Today Home Work',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  DateFormat.yMMMMEEEEd().format(dateTime) +
                                      '\t' +
                                      'Homework',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                          ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.all(1),
                              itemCount: todayHomeWorkList.length,
                              itemBuilder: (BuildContext context, int i) {
                                return Card(
                                  child: ListTile(
                                    title: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          'https://sghps.cityschools.co/uploads/homework/${todayHomeWorkList[i].img}',
                                          height: 80,
                                        ),
                                        // SizedBox(width: 30,),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width*.4,
                                                child: Text(
                                                  '${todayHomeWorkList[i].task}',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                              ),
                                              Text(
                                                '${todayHomeWorkList[i].date}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      return showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          content: Image.network(
                                            'https://sghps.cityschools.co/uploads/homework/${todayHomeWorkList[i].img}',
                                            fit: BoxFit.fill,
                                          ),
                                          actions: <Widget>[
                                            new FlatButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(context);
                                              },
                                              child: Text('Close'),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: searchedHomeWorkList.length,
                              itemBuilder: (BuildContext context, int i) {
                                return Card(
                                  child: ListTile(
                                    title: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          'https://sghps.cityschools.co/uploads/homework/${searchedHomeWorkList[i].img}',
                                          height: 80,
                                        ),
                                        // SizedBox(width: 30,),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context).size.width*.4,
                                                child: Text(
                                                  '${searchedHomeWorkList[i].task}',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                              ),
                                              Text(
                                                '${searchedHomeWorkList[i].date}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      return showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          content: Image.network(
                                            'https://sghps.cityschools.co/uploads/homework/${searchedHomeWorkList[i].img}',
                                            fit: BoxFit.fill,
                                          ),
                                          actions: <Widget>[
                                            new FlatButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(context);
                                              },
                                              child: Text('Close'),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }
}
