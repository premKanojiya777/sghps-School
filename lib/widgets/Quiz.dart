import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:google_live/models/QuestionsModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Quiz extends StatefulWidget {
  final int exam_id;
  final int examTime;
  Quiz({this.exam_id, this.examTime});
  @override
  _QuizState createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  List answr = [];
  List<QuestionModel> listOfQuestions = [];
  List answersList = [];
  List selectedAnswersList = [];
  Future<List<QuestionModel>> quiz;
  static const duration = const Duration(seconds: 1);
  int secondPassed = 0;
  bool isActive = false;
  Timer timer;
  int correctScore = 0;
  int secCount = 0;
  var testName;
  var subjectName;
  var totalMarks;
  var completedIn;
  var questionAttempt;
  var marksObtains;
  bool isClicked = false;
  @override
  void initState() {
    super.initState();
    quiz = _getQuiz();
    handleTick();
    super.initState();
  }

  int _value1 = 0;
  int selectedValue = 0;
  Container datacontainer = new Container();

  Future<void> handleTick() async {
    var examDuration = widget.examTime * 60;
    // print(examDuration);
    if (secondPassed >= examDuration) {
      timer.cancel();
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: new Text('Your Time Is Over'),
          content: new Text('Come Back Tomorrow'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            )
          ],
        ),
      );
    } else {
      setState(() {
        secondPassed = secondPassed + 1;
        secCount++;
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  int updateValue() {
    return _value1 = _value1 + 1;
  }

  Future<List<QuestionModel>> _getQuiz() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/exam_ques?access_token=' +
            prefs.get('token') +
            '&id=' +
            widget.exam_id.toString();
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      Map<String, dynamic> quiz = json.decode(res.body);
      var ques = quiz['ques'];
      answersList = [];
      selectedAnswersList = [];
      for (var q in ques) {
        QuestionModel questionModel = QuestionModel(q['ques_desc'],
            q['choice_1'], q['choice_2'], q['choice_3'], false, q['id']);
        listOfQuestions.add(questionModel);
        List arr = [];
        for (var i = 0; i < 3; i++) {
          switch (i) {
            case 0:
              {
                arr.add(q['choice_1']);
              }
              break;

            case 1:
              {
                arr.add(q['choice_2']);
              }
              break;

            case 2:
              {
                arr.add(q['choice_3']);
              }
              break;
          }
        }
        answersList.add(arr);
        selectedAnswersList.add({"answer": "", "id": 0});
      }
      print(listOfQuestions.length);
    }).catchError((onError) {
      print(onError);
    });
    return listOfQuestions;
  }

  manageAnswerArray(int value, int id, int index) {
    int itemChange = (value / id).round() - (id + index);
    answersList.removeAt(index);
    answersList.insert(index, itemChange.toString());
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _submitTest() async {
    for (var i = 0; i < selectedAnswersList.length; i++) {
      // print('${selectedAnswersList[i]["answer"]}_${selectedAnswersList[i]["id"]}');
      answr.add("${listOfQuestions[i].id}_${selectedAnswersList[i]["id"]}");
    }
    final now = Duration(seconds: secondPassed);
    print("${_printDuration(now)}");
    final prefs = await SharedPreferences.getInstance();
    String url = 'http://sghps.cityschools.co/studentapi/exam_ques_ans';
    Map dataMap = {
      'access_token': prefs.get('token'),
      'url': url,
      'exam_id': widget.exam_id.toString(),
      'answer': answr,
      'timeuse': _printDuration(now),
    };

    await apiRequest(url, dataMap);
  }

  Future<String> apiRequest(String url, Map dataMap) async {
    String jsonString = json.encode(dataMap);
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.contentType =
        new ContentType("application", "json", charset: "utf-8");
    request.headers.set('Content-Length', jsonString.length.toString());
    request.write(jsonString);
    print(jsonString);
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    setState(() {
      Map<String, dynamic> user = jsonDecode(reply);
      var results = user['exam_detail'];
      this.testName = results['name'];
      this.subjectName = results['subject']['subject_name'];
      this.totalMarks = results['total_marks'];
      this.completedIn = user['timeuse'];
      this.marksObtains = user['marks'];
      this.questionAttempt = user['ques_attempt'];
    });

    httpClient.close();
    setState(() {
      isClicked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(33, 23, 47, 1),
          title: Text('Exam'),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            isClicked
                ? _resultsUI()
                : Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.fromLTRB(10, 8, 10, 10),
                        child: _timerUi(),
                      ),
                      _questionUi(),
                    ],
                  )
          ],
        ));
  }

  Widget _questionUi() {
    return Container(
      padding: EdgeInsets.only(top: 100),
      child: Stack(
        children: <Widget>[
          FutureBuilder(
            future: quiz,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: Center(
                    child: Text("Loading..."),
                  ),
                );
              } else {
                return Container(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int i) {
                            return Container(
                              padding: EdgeInsets.fromLTRB(20, 5, 20, 1),
                              child: Card(
                                child: new Column(
                                  children: <Widget>[
                                    Align(
                                        alignment: Alignment(-0.9, 0.0),
                                        child: Text(
                                          '${snapshot.data[i].ques_desc}',
                                          style: new TextStyle(
                                            fontSize: 18.0,
                                          ),
                                        )),
                                    new Row(
                                      children: <Widget>[
                                        Align(
                                            alignment: Alignment(-0.8, 0.0),
                                            child: Text(
                                              '1: ${snapshot.data[i].choice_1}',
                                              style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                              ),
                                            )),
                                        new FlatButton(
                                          child: Icon(selectedAnswersList[i]
                                                          ["answer"]
                                                      .toString() ==
                                                  snapshot.data[i].choice_1
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked),
                                          onPressed: () {
                                            selectedAnswersList.removeAt(i);
                                            selectedAnswersList.insert(i, {
                                              "answer":
                                                  snapshot.data[i].choice_1,
                                              "id": 1
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment(-0.8, 0.0),
                                          child: Text(
                                            '2: ${snapshot.data[i].choice_2}',
                                            style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ),
                                        new FlatButton(
                                          child: Icon(selectedAnswersList[i]
                                                          ["answer"]
                                                      .toString() ==
                                                  snapshot.data[i].choice_2
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked),
                                          onPressed: () {
                                            selectedAnswersList.removeAt(i);
                                            selectedAnswersList.insert(i, {
                                              "answer":
                                                  snapshot.data[i].choice_2,
                                              "id": 2
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Align(
                                            alignment: Alignment(-0.8, 0.0),
                                            child: Text(
                                              '3: ${snapshot.data[i].choice_3}',
                                              style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                              ),
                                            )),
                                        new FlatButton(
                                          child: Icon(selectedAnswersList[i]
                                                          ["answer"]
                                                      .toString() ==
                                                  snapshot.data[i].choice_3
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked),
                                          onPressed: () {
                                            selectedAnswersList.removeAt(i);
                                            selectedAnswersList.insert(i, {
                                              "answer":
                                                  snapshot.data[i].choice_3,
                                              "id": 3
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      RaisedButton(
                        textColor: Colors.white,
                        color: Color.fromRGBO(33, 23, 47, 1),
                        onPressed: _submitTest,
                        // () {

                        //   print("Answer: $answr");
                        // },
                        child: Text(
                          'SUBMIT',
                          style: TextStyle(
                            color: Color.fromRGBO(33, 23, 47, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _resultsUI() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Card(
              child: Column(
            children: <Widget>[
              Text(
                this.testName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Divider(),
              Text('Subject',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                this.subjectName,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Divider(),
              Text('Total Marks',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                this.totalMarks.toString(),
                style: TextStyle(fontSize: 18),
              ),
              Divider(),
              Text('Completed In',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                this.completedIn,
                style: TextStyle(fontSize: 18),
              ),
              Divider(),
              Text('Questions Obtained',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                this.questionAttempt.toString(),
                style: TextStyle(fontSize: 18),
              ),
              Divider(),
              Text('Marks Obtained',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(
                this.marksObtains.toString(),
                style: TextStyle(fontSize: 18),
              ),
              Divider(),
            ],
          )),
        ],
      ),
    );
  }

  Widget _timerUi() {
    if (timer == null) {
      timer = Timer.periodic(duration, (Timer t) {
        handleTick();
      });
    }
    int seconds = secondPassed % 60;
    int minutes = secondPassed ~/ 60;
    int hours = secondPassed ~/ (60 * 60);
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LabelText(label: '', value: hours.toString().padLeft(2, '0')),
              LabelText(label: '', value: minutes.toString().padLeft(2, '0')),
              LabelText(label: '', value: seconds.toString().padLeft(2, '0')),
            ],
          ),
        ],
      ),
    );
  }
}

class LabelText extends StatelessWidget {
  LabelText({this.label, this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.teal,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '$value',
            style: TextStyle(
                color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Text(
            '$label',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
