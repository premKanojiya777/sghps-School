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
      // newSyllabus = NewSyllabus.fromJson(syllabus);
      //  if (newSyllabus.error) {
      //   print('error');
      // } else {
      //       for (Syllabus syll in newSyllabus.subjects.syllabusList) {
      //     mondayWidgets.add(_commonRow('${syll.subject_name}', '${syll.pdf_file}'));
      //   }
      var subjects = syllabus['subjects'];

      for (var s in subjects) {
        var sub = s['subject']['subject_name'];

        pdf = s['pdf'];
        print(pdf);
        if (pdf.length != 0) {
          for (var p in pdf) {
            pdf_file = p['pdf_file'];
            print('hii');
            // isPdf = true;
          }
        } else {
          print('bye');
          pdf_file = '';
          // isPdf = false;
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
                'Subject Name',
                style: TextStyle(fontSize: 17),
              ),
              SizedBox(width: 90),
              Text(
                'Link',
                style: TextStyle(fontSize: 19),
              ),
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
      body: RefreshIndicator(
        onRefresh: () async {
            _getSyllabus();
          return await Future.delayed(Duration(seconds: 3));
        },
        child: Container(
          padding: EdgeInsets.all(10),
          child: Card(
            child: Stack(
              children: <Widget>[
                _headerFun(),
                _data(),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _data() {
    return FutureBuilder(
      future: syllabuses,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.data == null) {
          return bodyProgress;
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 50),
            child: ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int i) {
                return Container(
                  padding: EdgeInsets.only(left: 17, right: 12),
                  child: Row(children: <Widget>[
                    Text(
                      '${snapshot.data[i].subject_name}',
                      style: TextStyle(fontSize: 15),
                    ),
                    Spacer(),

                    RaisedButton(
                      onPressed: () {
                        print('${snapshot.data[i].pdf_file}');
                        setState(() {
                          loader = true;
                          if (snapshot.data[i].pdf_file == null || snapshot.data[i].pdf_file == '') {
                            Toast.show('No Pdf Link Found', context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.BOTTOM);
                            loader = false;
                          } else {
                            createFileOfPdfUrl('${snapshot.data[i].pdf_file}')
                                .then((f) {
                              setState(() {
                                pathPDF = f.path;
                                print(pathPDF);
                                loader = false;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFScreen(pathPDF),
                                ),
                              );
                            });
                          }
                        });
                      },
                      child: Text('PDF Link'),
                    ),
                    // : Container(),
                    SizedBox(
                      width: 65,
                    ),
                    Visibility(
                      visible: loader,
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
                );
              },
            ),
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
