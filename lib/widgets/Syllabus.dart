import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:google_live/models/SylabusModel.dart';
import 'package:google_live/models/SyllabusModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class Syllabus extends StatefulWidget {
  @override
  _SyllabusState createState() => _SyllabusState();
}

class _SyllabusState extends State<Syllabus> {
  Future<List<SyllabusModel>> syllabuses;
  NewSyllabus newSyllabus;
  String pathPDF = "";
  var pdf_file;
  bool loader = false;
  bool visible = false;
  List pdf;
  bool isPdf = false;
  @override
  void initState() {
    super.initState();
    syllabuses = _getSyllabus();
  }

  Future<List<SyllabusModel>> _getSyllabus() async {
    List<SyllabusModel> syllabusList = [];
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/syllabus?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Content-Type": "application/json"}).then((res) {
      Map<String, dynamic> syllabus = jsonDecode(res.body);
      var subjects = syllabus['subjects'];
      setState(() {
        loader = true;
        print(loader);
      });
      for (var s in subjects) {
        var sub = s['subject']['subject_name'];
        pdf = s['pdf'];
        if (pdf.length != 0) {
          for (var p in pdf) {
            pdf_file = p['pdf_file'];
            print('hii');
          }
        } else {
          print('bye');
          pdf_file = '';
        }

        SyllabusModel syllabusModel = SyllabusModel(sub, pdf_file);
        syllabusList.add(syllabusModel);
      }
      print(syllabusList.length);
    }).catchError((onError) {
      print(onError);
    });
    return syllabusList;
  }

  Future<File> createFileOfPdfUrl(String endUrl) async {
    final url = "http://sghps.cityschools.co/uploads/syllabus/" + endUrl;
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  Widget _headerFun() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Text(
                'SUBJECT NAME',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                'LINK',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 110),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(33, 23, 47, 1),
          title: Text('Syllabus'),
          centerTitle: true,
        ),
        body: loader
            ? RefreshIndicator(
                onRefresh: () async {
                  _getSyllabus();
                  return await Future.delayed(Duration(seconds: 3));
                },
                child: Card(
                  child: Column(
                    children: <Widget>[
                      _headerFun(),
                      _data(),
                    ],
                  ),
                ),
              )
            : bodyProgress);
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

  Widget _data() {
    return FutureBuilder(
      future: syllabuses,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return Container();
        } else {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int i) {
              return Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Text(
                          '${snapshot.data[i].subject_name}',
                          style: TextStyle(fontSize: 15),
                        ),
                        Spacer(),
                        snapshot.data[i].pdf_file == null ||
                                snapshot.data[i].pdf_file == ""
                            ? Text('Link not Available')
                            : RaisedButton(
                                onPressed: () async {
                                  setState(() {
                                    visible = true;
                                  });
                                  print('${snapshot.data[i].pdf_file}');
                                  // print('${snapshot.data[i].pdf_file}');
                                  var pdfurl =
                                      'http://sghps.cityschools.co/uploads/syllabus/' +
                                          '${snapshot.data[i].pdf_file}';
                                  print('${snapshot.data[i].pdf_file}');
                                  print(pdfurl);

                                  if (await canLaunch(pdfurl)) {
                                    await launch(pdfurl);
                                  } else {
                                    throw 'Could not launch $pdfurl';
                                  }
                                },
                                child: Text('PDF Link'),
                              ),
                        SizedBox(
                          width: 50,
                        )

                        // Visibility(
                        //   visible: visible,
                        //   child: Column(
                        //     children: [
                        //       CircularProgressIndicator(),
                        //       SizedBox(
                        //         height: 10,
                        //       ),
                        //       Text(
                        //         "Please Wait....",
                        //         style: TextStyle(color: Colors.blueAccent),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // SizedBox(width: 30,)
                      ],
                    ),
                    Divider(),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  PDFScreen(this.pathPDF);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(33, 23, 47, 1),
          title: Text("Document"),
        ),
        path: pathPDF);
  }
}
