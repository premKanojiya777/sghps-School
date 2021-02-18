import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/widgets/TeacherHome.dart';
import 'package:google_live/widgets/driverHome.dart';
import 'package:google_live/widgets/studentHome.dart';
import '../widgets/loggedIn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginUser extends StatefulWidget {
  @override
  LoginUserState createState() => LoginUserState();
}

class LoginUserState extends State {
  Map<String, dynamic> userRole;
  bool visible = false;
  bool loader = true;
  var savekey = '';
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading;
  var token;

  void _sendToServer() async {
    String username = emailController.text;
    String password = passwordController.text;
    String url = 'https://sghps.cityschools.co/applogin';
    Map dataMap = {
      'username': username,
      'password': password,
      'grant_type': 'password',
      'client_id': 'f3d259ddd3ed8ff3843839b',
      'client_secret': '4c7f6f8fa93d59c45502c0ae8c4a95b',
    };

    print(await apiRequest(url, dataMap));
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
    Map<String, dynamic> user = jsonDecode(reply);
    token = user['access_token'];
    if (token == null || token == '') {
      print('Invalid user');
      return showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: new Text('Invalid Username/Password'),
          content: new Text('Please Enter Valid Username And Password'),
          actions: <Widget>[
            new FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  loader = true;
                });
              },
              child: Text('Close'),
            )
          ],
        ),
      );
    } else if (token != null || token != '') {
      print('valid user');
      _getRole();
    }
    _saveToken(token);
    setState(() {
      LoggedIn();
      loader = true;
      visible = true;
    });
    httpClient.close();
    return reply;
  }

  _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'token';
    final value = token;
    prefs.remove(key);
    prefs.setString(key, value);
    this.savekey = prefs.get(key);
  }

  Future<String> _getRole() async {
    // final prefs = await SharedPreferences.getInstance();
    String url =
        'https://sghps.cityschools.co/studentapi/getrole?access_token=' +
            this.token;

    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      userRole = json.decode(res.body);
      if (userRole['role_id']['role_id'] == 7) {
        print('if');
        setState(() {
          visible = false;
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LocationHome()));
      } else if (userRole['role_id']['role_id'] == 4) {
        print('else if');
        setState(() {
          visible = false;
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => StudentHome()));
      } else if (userRole['role_id']['role_id'] == 3) {
        print('else if else');
        setState(() {
          visible = false;
        });
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => TeacherHome()));
      } else {
        print('Invalid User');
        setState(() {
          visible = false;
          loader = true;
        });
      }
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(33, 23, 47, 1),
          centerTitle: true,
          title: Text('Login'),
        ),
        body: loader
            ? SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 30),
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.transparent),
                        child: CircleAvatar(
                          radius: 90.0,
                          backgroundImage: AssetImage('icon.png'),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Container(
                        width: 320,
                        padding: EdgeInsets.all(10.0),
                        child: TextField(
                          controller: emailController,
                          autocorrect: true,
                          decoration: InputDecoration(
                            hintText: "Enter Username",
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Container(
                          width: 320,
                          padding: EdgeInsets.all(10.0),
                          child: TextField(
                            controller: passwordController,
                            autocorrect: true,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Enter Password",
                              fillColor: Colors.white,
                              // border: new OutlineInputBorder(
                              //   borderRadius: new BorderRadius.circular(35.0),
                              // ),
                            ),
                          )),
                      SizedBox(height: 10.0),
                      Container(
                        width: 320,
                        height: 45,
                        child: RaisedButton(
                          onPressed: () {
                            _sendToServer();
                            setState(() {
                              loader = false;
                            });
                          },
                          color: Color.fromRGBO(33, 23, 47, 1),
                          textColor: Colors.white,
                          padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                          child: Text(
                            'LOGIN',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                        visible: visible,
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Please Wait....",
                              style: TextStyle(color: Colors.blueAccent),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ) : 
             bodyProgress);
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
}
