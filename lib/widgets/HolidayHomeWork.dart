import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:google_live/models/HolidayModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class HolidayHomeWork extends StatefulWidget {
  @override
  _HolidayHomeWorkState createState() => _HolidayHomeWorkState();
}

class _HolidayHomeWorkState extends State<HolidayHomeWork> {
  Future<List<HolidayModel>> syllabuses;
  List<HolidayModel> homeworkss = [];
  HolidayModel syllabusModel;
  String pathPDF = "";
  var homework;
  bool visible = false;
  bool loader = false;
  @override
  void initState() {
    super.initState();
    syllabuses = _getHoliDayWork();
  }

  Future<List<HolidayModel>> _getHoliDayWork() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'https://sghps.cityschools.co/studentapi/holidayhome?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Content-Type": "application/json"}).then((res) {
      setState(() {
        Map<String, dynamic> data = jsonDecode(res.body);
        this.homework = data['holidayhome'];
        _checkHomeWork(this.homework);
        this.syllabusModel = HolidayModel(data['holidayhome'], data['url']);
        print('pdf:' + syllabusModel.holidayhome);

        homeworkss.add(syllabusModel);
        print(homeworkss.length);
        loader = true;
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  Future<File> createFileOfPdfUrl(String endUrl) async {
    final url = "https://sghps.cityschools.co/uploads/holidayhome/" + endUrl;
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  void _checkHomeWork(String homework) {
    if (homework == '') {
      Toast.show('No Data Founds', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      Navigator.pop(context);
    } else {
      Toast.show('HomeWork Founds', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
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
          title: Text('HoliDay HomeWork'),
          centerTitle: true,
        ),
        body: loader
            ? RefreshIndicator(
                onRefresh: () async {
                  homeworkss = [];
                  _getHoliDayWork();
                  return await Future.delayed(Duration(seconds: 3));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              onPressed: () {
                                print(syllabusModel.holidayhome);
                                setState(() async {
                                  visible = true;
                                  if (syllabusModel.holidayhome == null ||
                                      syllabusModel.holidayhome == '') {
                                    Toast.show('No Pdf Link Found', context,
                                        duration: Toast.LENGTH_LONG,
                                        gravity: Toast.BOTTOM);
                                    visible = false;
                                  } else {
                                    var pdfurl =
                                        'https://sghps.cityschools.co/uploads/syllabus/' +
                                            syllabusModel.holidayhome;
                                    print(syllabusModel.holidayhome);
                                    print(pdfurl);

                                    if (await canLaunch(pdfurl)) {
                                      await launch(pdfurl);
                                    } else {
                                      throw 'Could not launch $pdfurl';
                                    }
                                    //     setState(() {
                                    //       createFileOfPdfUrl(
                                    //               syllabusModel.holidayhome)
                                    //           .then((f) {
                                    //         setState(() {
                                    //           pathPDF = f.path;
                                    //           print(pathPDF);
                                    //           visible = false;
                                    //         });
                                    //         Navigator.push(
                                    //           context,
                                    //           MaterialPageRoute(
                                    //             builder: (context) =>
                                    //                 PDFScreen(pathPDF),
                                    //           ),
                                    //         );
                                    //       });
                                    //     });

                                  }
                                });
                              },
                              child: Text(
                                'Holiday HomeWork Pdf',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Color.fromRGBO(33, 23, 47, 1),
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
                          ]),
                    ),
                  ),
                ),
              )
            : bodyProgress);
  }
}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  PDFScreen(this.pathPDF);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Text("HoliDay Works"),
        ),
        path: pathPDF);
  }
}
