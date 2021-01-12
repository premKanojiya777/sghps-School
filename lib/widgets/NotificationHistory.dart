import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/models/HIstoryNotiModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationHistory extends StatefulWidget {
  @override
  _NotificationHistoryState createState() => _NotificationHistoryState();
}

class _NotificationHistoryState extends State<NotificationHistory> {
  Future<List<HistoryNotiModel>> historyModel;
  List<HistoryNotiModel> historyList = [];
  var link;

  @override
  void initState() {
    super.initState();
    historyModel = _getNotiHistory();
  }

  Future<List<HistoryNotiModel>> _getNotiHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/coordinator/noti_history?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      Map<String, dynamic> history = json.decode(res.body);

      setState(() {
        var notification = history['noti'];
        for (var u in notification) {
          HistoryNotiModel historyNotiModel = HistoryNotiModel(u['title'],
              u['message'], u['clss'], u['section'], u['issue_date']);

          historyList.add(historyNotiModel);
        }
        print(historyList.length);
      });
    }).catchError((onError) {
      print(onError);
    });
    return historyList;
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
        title: Text('History'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
      ),
      body: FutureBuilder(
        future: historyModel,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return bodyProgress;
          } else {
            return RefreshIndicator(
              onRefresh: () {
                return historyModel;
              },
              child: ListView.builder(
                padding: EdgeInsets.all(8),
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int i) {
                  return Card(
                    child: 
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${snapshot.data[i].title}',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 17),
                              ),

                              SizedBox(
                                height: 3,
                              ),
                              // subtitle:
                              RichText(
                                text: TextSpan(
                                  children: [
                                    WidgetSpan(
                                        style: TextStyle(color: Colors.black),
                                        child: (snapshot.data[i].message
                                                    .lastIndexOf('https') !=
                                                -1)
                                            ? Text(snapshot.data[i].message
                                                .substring(
                                                    0,
                                                    snapshot.data[i].message
                                                        .lastIndexOf('https')))
                                            : Text(snapshot.data[i].message)),
                                    TextSpan(
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                      text: 'Link',
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          RegExp exp = new RegExp(
                                              r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
                                          Iterable<RegExpMatch> matches =
                                              exp.allMatches(
                                                  snapshot.data[i].message);

                                          matches.forEach((match) {
                                            this.link = snapshot.data[i].message
                                                .substring(
                                                    match.start, match.end);
                                          });

                                          var url = '${this.link}';
                                          if (await canLaunch(url)) {
                                            await launch(url);
                                          } else {
                                            throw 'Could not launch $url';
                                          }
                                        },
                                    ),
                                  ],
                                ),
                              ),
                              ListTile(
                                leading:  Text(
                            '${snapshot.data[i].clss}' +
                                '-'
                                    '${snapshot.data[i].section}',
                            style:
                                TextStyle(color: Colors.black, fontSize: 12),
                          ),
                          trailing: Text(
                            '${snapshot.data[i].issue_date}',
                            style:
                                TextStyle(color: Colors.black, fontSize: 12),
                          ),
                              ),
                            ],
                            
                          ),
                        ),
                       
                        
                     
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
