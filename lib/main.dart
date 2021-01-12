import 'package:flutter/material.dart';
import 'package:google_live/widgets/LocalNotification.dart';
import './widgets/loggedIn.dart';
import 'dart:core';

void main() {
  runApp(MaterialApp(
    title: 'SGHPS School',
    home: LoadingScreen(),
  ));
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    super.initState();
  }

  bool visible = false;
  bool loading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "splach.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Visibility(
                    child: Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                  ),
                )),
                LoggedIn(),
                LocalNotification(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
