import 'dart:convert';
import 'dart:io';
import 'package:google_live/widgets/OnlineTeaching.dart';
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
  Future<List<SearchModel>> _search;
  List<SearchModel> model = [];
  SearchModel searchModel;
  String _currentMonth = DateFormat.yMMMMEEEEd().format(dateTime);
  bool loader = true;
  var attch;
  var todayhome;
  var todtask;
  var toddate;
  var task;
  var date;

  @override
  void initState() {
    super.initState();
    _dailyHomework();
  }

  Future<String> _dailyHomework() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/homework?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Content-Type": "application/json"}).then((res) {
      //print({"res", res.body});
      setState(() {
        Map<String, dynamic> user = jsonDecode(res.body);
        var a = user['homework'];
        this.todayhome = a[0]['attach'];
        this.toddate = a[0]['date'];
        this.todtask = a[0]['task'];
        loader = true;
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020, 04, 25),
        lastDate: DateTime(2021, 03, 30));
    if (picked != null && picked != selectedDate)
      setState(() {
        dateTime = picked;
      });
  }

  Future<void> _searchHomework() async {
    String date = _date.text;
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/gethomework?access_token=' +
            prefs.get('token');
    Map dataMap = {
      'url': url,
      'date': date,
    };

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
      var a = works['homework'];
      this.attch = a[0]['attach'];
      this.date = a[0]['date'];
      this.task = a[0]['task'];
      loader = true;
      print(this.date);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(33, 23, 47, 1),
          title: Text('Homework'),
          centerTitle: true,
        ),
        body: loader
            ? RefreshIndicator(
                onRefresh: () async {
                  _searchHomework();
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
                          // Container(
                          //   width: 400,
                          //   padding: EdgeInsets.all(10.0),
                          //   child: TextField(
                          //     // controller: _date,
                          //     autocorrect: true,
                          //     decoration: InputDecoration(
                          //       icon: const Icon(Icons.calendar_today),
                          //       hintText: _currentMonth,
                          //       fillColor: Colors.white,

                          //       // border: new OutlineInputBorder(
                          //       //   borderRadius: new BorderRadius.circular(35.0),
                          //       // ),
                          //     ),
                          //     onTap:(){
                          //       _selectDate(context);
                          //     },
                          //   ),
                          // ),
                          Container(
                            width: 340,
                            child: RaisedButton(
                              // shape: new RoundedRectangleBorder(
                              //     borderRadius: new BorderRadius.circular(18.0),
                              //     side: BorderSide(color: Colors.green)),
                              onPressed: _searchHomework,
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
                          Text(
                            DateFormat.yMMMMEEEEd().format(dateTime) +
                                '\t' +
                                'Homework',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Divider(),
                          Card(
                            // color: Colors.blue,
                            child: Container(
                              child: ListTile(
                                title: Image.network(
                                  'https://sghps.cityschools.co/uploads/homework/${this.attch}',
                                  height: 100,
                                ),
                                trailing: Text(
                                    '${this.task}' + '\n' + '${this.date}'),
                                onTap: () {
                                  return showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      content: Image.network(
                                        'https://sghps.cityschools.co/uploads/homework/${this.attch}',
                                        fit: BoxFit.fill,
                                      ),
                                      actions: <Widget>[
                                        new FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(context);
                                          },
                                          child: Text('Close'),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Card(
                            // color: Colors.blue,
                            child: Container(
                              child: ListTile(
                                title: Image.network(
                                  'https://sghps.cityschools.co/uploads/homework/${this.todayhome}',
                                  height: 100,
                                ),
                                trailing: Text('${this.todtask}' +
                                    '\n' +
                                    '${this.toddate}'),
                                onTap: () {
                                  return showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      content: Image.network(
                                        'https://sghps.cityschools.co/uploads/homework/${this.todayhome}',
                                        fit: BoxFit.fill,
                                      ),
                                      actions: <Widget>[
                                        new FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(context);
                                          },
                                          child: Text('Close'),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : bodyProgress);
  }
}
