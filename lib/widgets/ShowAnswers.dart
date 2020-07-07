import 'dart:convert';
import 'package:google_live/models/AnswersModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowAnswer extends StatefulWidget {
  final int exam_id;

  const ShowAnswer({Key key, this.exam_id}) : super(key: key);

  @override
  _ShowAnswerState createState() => _ShowAnswerState();
}

class _ShowAnswerState extends State<ShowAnswer> {
  Future<List<AnswerModel>> answerList;
  @override
  void initState() {
    super.initState();
    answerList = _getAnswers();
    super.initState();
  }

  Future<List<AnswerModel>> _getAnswers() async {
    List<AnswerModel> listOfAnsers = [];
    final prefs = await SharedPreferences.getInstance();
    String url = 'http://sghps.cityschools.co/studentapi/answers?access_token=' +
        prefs.get('token') +
        '&exam_id=' +
        widget.exam_id.toString();
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      Map<String, dynamic> answers = json.decode(res.body);
      var answer = answers['question'];
      for (var ans in answer) {
        AnswerModel answerModel = AnswerModel(
            ans['ques_desc'],
            ans['choice_1'],
            ans['choice_2'],
            ans['choice_3'],
            ans['answer'],
            ans['ans']['answer']);
        listOfAnsers.add(answerModel);
      }
      print(listOfAnsers.length);
    }).catchError((onError) {
      print(onError);
    });
    return listOfAnsers;
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
        title: Text('Show Answers'),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder(
            future: answerList,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return bodyProgress;
              } else {
                return Container(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
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
                                          ' ${snapshot.data[i].ques_desc}',
                                          style: new TextStyle(
                                            fontSize: 18.0,
                                          ),
                                        )),
                                    new Row(
                                      children: <Widget>[
                                        Align(
                                            alignment: Alignment(-0.8, 0.0),
                                            child: Text(
                                              '   1: ${snapshot.data[i].choice_1}',
                                              style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                              ),
                                            )),
                                        new FlatButton(
                                          child: Icon(
                                              Icons.radio_button_unchecked),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Align(
                                          alignment: Alignment(-0.8, 0.0),
                                          child: Text(
                                            '   2: ${snapshot.data[i].choice_2}',
                                            style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ),
                                        new FlatButton(
                                          child: Icon(
                                              Icons.radio_button_unchecked),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Align(
                                            alignment: Alignment(-0.8, 0.0),
                                            child: Text(
                                              '   3: ${snapshot.data[i].choice_3}',
                                              style: new TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0,
                                              ),
                                            )),
                                        new FlatButton(
                                          child: Icon(
                                              Icons.radio_button_unchecked),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Align(
                                      alignment: Alignment(-0.9, 0.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Correct Answer:${snapshot.data[i].answer}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.green),
                                          ),
                                          Text(
                                            'Your Answer:${snapshot.data[i].user_answer}',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color:
                                                    snapshot.data[i].answer ==
                                                            snapshot.data[i]
                                                                .user_answer
                                                        ? Colors.green
                                                        : Colors.red),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
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
}
