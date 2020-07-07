import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_live/models/StudNotificationsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TeacherNotification extends StatefulWidget {
  @override
  _TeacherNotificationState createState() => _TeacherNotificationState();
}

class _TeacherNotificationState extends State<TeacherNotification> {
  Map<String, dynamic> studentnotifications;
  Future<List<StudNotification>> _notifications;
  var link;
  var token = '';
  @override
  void initState() {
    super.initState();
    _notifications = _studentnotification();
  }

  Future<List<StudNotification>> _studentnotification() async {
    List<StudNotification> notifications = [];
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/teacherapi/teachernotification?access_token=' +
            prefs.get('token');
    Map dataMap = {
      'access_token': prefs.get('token'),
    };
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
    if (mounted)
      setState(() {
        this.studentnotifications = jsonDecode(reply);
        var route = studentnotifications['select'];
        for (var u in route) {
          StudNotification route1 =
              StudNotification(u['title'], u['message'], u['issue_date']);

          notifications.add(route1);
        }
        print(notifications.length);
      });
    return notifications;
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
        title: Text('Teacher Notifications'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _notifications,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return bodyProgress;
          } else {
            return RefreshIndicator(
              onRefresh: (){
                _studentnotification();
                return _notifications;
              },
                          child: ListView.builder(
                padding: EdgeInsets.fromLTRB(15, 30, 15, 10),
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int i) {
                  Spacer();
                  return Container(
                    height: 130,
                    width: 100,
                    child: Card(
                      child: Stack(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${snapshot.data[i].title}',
                                style:
                                    TextStyle(color: Colors.black, fontSize: 17),
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
                            ],
                          ),
                          Positioned(
                            top: 100,
                            left: 200,
                            child: Text(
                              '${snapshot.data[i].issue_date}',
                              style: TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          )
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
