import 'dart:convert';
import 'package:google_live/models/ExamListModel.dart';
import 'package:google_live/widgets/Quiz.dart';
import 'package:google_live/widgets/ShowAnswers.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnlineExams extends StatefulWidget {
  @override
  _OnlineExamsState createState() => _OnlineExamsState();
}

class _OnlineExamsState extends State<OnlineExams> {
  List<ExamModel> listOfExams = [];
  Future<List<ExamModel>> examss;
  List stud = [];
  bool startexam = false;
  bool cancel = false;
  bool isSubmit = false;
  DateTime _currentDate = new DateTime.now();
  String endDate = '2020-05-01 18:59:00';
  @override
  void initState() {
    super.initState();
    examss = _getExamsList();
  }

  Future<List<ExamModel>> _getExamsList() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/checkexam?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      Map<String, dynamic> examsList = json.decode(res.body);
      var exam = examsList['exam'];

      // print(exam);
      for (var s in exam) {
        var startdate = s['exam']['start_date'];
        var endDate = s['exam']['end_date'];
        this.startexam = false;
        bool inRange = isWithinRange(startdate, endDate);
        // print('DD:$inRange');
        this.startexam = inRange;
        this.isSubmit = s['exam']['stu'].length == 0 ? false : true;
        // print('Submit:${this.isSubmit}');
        ExamModel examModel = ExamModel(
            s['exam']['name'],
            s['exam']['total_marks'],
            s['exam']['pass_marks'],
            s['exam']['duration'],
            startdate,
            endDate,
            s['exam']['description'],
            s['exam']['subject']['subject_name'],
            this.startexam,
            this.cancel,
            s['exam']['id'],
            this.isSubmit);
        listOfExams.add(examModel);
        // print('Exam Name:${s['exam']['name']}');
      }
      print('Lenght: ${listOfExams.length}');
    }).catchError((onError) {
      print(onError);
    });
    return listOfExams;
  }

  bool isWithinRange(String startDate, String endDate) {
    DateTime testDate = new DateTime.now();
    // endDate = '2020-05-01 18:59:00';
    // startDate = '2020-04-30 12:55:00';
    // print('ST:$startDate');
    // print('ed:$endDate');
    // print('Ct:$testDate');
    // print(testDate.isAfter(DateTime.parse(startDate)));
    // print(testDate.isBefore(DateTime.parse(endDate)));
    return (testDate.isAfter(DateTime.parse(startDate)) &&
        testDate.isBefore(DateTime.parse(endDate)));
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
        title: Text('Online Exam'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          listOfExams = [];
          _getExamsList();

          return await Future.delayed(Duration(seconds: 3));
        },
        child: FutureBuilder(
          future: examss,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return bodyProgress;
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int i) {
                  return Container(
                    child: Card(
                      borderOnForeground: true,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Exam',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color.fromRGBO(33, 23, 47, 1)),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * .4,
                                  child: Text(
                                    '${snapshot.data[i].name}',
                                    style: TextStyle(
                                        // fontSize: 5,
                                        color: Color.fromRGBO(33, 23, 47, 1)),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Subject',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color.fromRGBO(33, 23, 47, 1)),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * .23,
                                  child: Text(
                                    '${snapshot.data[i].subject_name}',
                                    style: TextStyle(
                                        // fontSize: 15,
                                        color: Color.fromRGBO(33, 23, 47, 1)),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              children: <Widget>[
                                Text(
                                  'Action',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color.fromRGBO(33, 23, 47, 1)),
                                ),
                                Column(
                                  children: <Widget>[
                                    _currentDate.isAfter(DateTime.parse(
                                            snapshot.data[i].end_date))
                                        ? RaisedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ShowAnswer(
                                                    exam_id:
                                                        snapshot.data[i].id,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Show Answer',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            color:
                                                Color.fromRGBO(33, 23, 47, 1),
                                          )
                                        : (snapshot.data[i].isSubmit
                                            ? Text(
                                                'Finish',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            : Align(
                                                alignment: Alignment(-0.8, 0.0),
                                                child: RaisedButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          AlertDialog(
                                                        title: Text(
                                                            '${snapshot.data[i].name}'),
                                                        content: Text(
                                                            'Exam: ${snapshot.data[i].name}'
                                                            '\n'
                                                            'Subject: ${snapshot.data[i].subject_name}'
                                                            '\n'
                                                            'Total Marks: ${snapshot.data[i].total_marks}'
                                                            '\n'
                                                            'Pass Marks: ${snapshot.data[i].pass_marks}'
                                                            '\n'
                                                            'Duration: ${snapshot.data[i].duration}'
                                                            '\n'
                                                            'Start Date: ${snapshot.data[i].start_date}'
                                                            '\n'
                                                            'End Date: ${snapshot.data[i].end_date}'
                                                            '\n'
                                                            'Description: ${snapshot.data[i].description}'),
                                                        actions: <Widget>[
                                                          snapshot.data[i]
                                                                  .startexam
                                                              ? new FlatButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                Quiz(
                                                                          exam_id: snapshot
                                                                              .data[i]
                                                                              .id,
                                                                          examTime: snapshot
                                                                              .data[i]
                                                                              .duration,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child: Text(
                                                                      'START EXAM'),
                                                                )
                                                              : Container(),
                                                          new FlatButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(context);
                                                            },
                                                            child:
                                                                Text('CANCEL'),
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    'View',
                                                    style: TextStyle(
                                                        color: Color.fromRGBO(
                                                            33, 23, 47, 1)),
                                                  ),
                                                  color: Color.fromRGBO(
                                                      33, 23, 47, 1),
                                                ),
                                              )),
                                  ],
                                ),
                                SizedBox(
                                  width: 10,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
