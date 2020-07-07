import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:google_live/models/DateSheetValue.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/models/DateSheetModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class DateSheet extends StatefulWidget {
  @override
  _DateSheetState createState() => _DateSheetState();
}

class _DateSheetState extends State<DateSheet> {
  DateSheetModel dateSheetModel;
  DateValue datesvalue;
  String pathPDF = "";
  var terms;
  bool loader = false;

  @override
  void initState() {
    super.initState();
    _dateSheet();
  }

  Future<File> createFileOfPdfUrl(String endUrl) async {
    final url = "http://smart.sksk.in/uploads/datesheet/" + endUrl;
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<File> _dateSheet() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/datesheet?access_token=' +
            prefs.get('token');
    await getDateSheet(url, prefs.get('token'));
  }

  Future<String> getDateSheet(String url, accessToken) async {
    final response = await http
        .get(url, headers: {"Content-Type": "application/json"}).then((res) {
      setState(() {
        Map<String, dynamic> user = jsonDecode(res.body);
        dateSheetModel = DateSheetModel.fromJson(user);
        if (dateSheetModel.resulttype.datesheetList.length == 0) {
          print('error');
          loader = true;
        } else {
          for (datesvalue in dateSheetModel.resulttype.datesheetList) {
            print(datesvalue.date_sheet);
          }
        }
      });

      setState(() {
        this.terms = this.datesvalue.type;
        loader = true;
      });
    }).catchError((onError) {
      print(onError);
    });
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
  Widget _commonRow() {
    return Container(
      width: 600,
      child: Column(
        children: <Widget>[
          Container(
            // padding: EdgeInsets.only(
            //   left: 10,
            // ),
            child: Card(
              child: Row(
                children: <Widget>[
                  this.terms == null
                      ? Text('No data')
                      : Text(
                          this.terms.toString(),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(33, 23, 47, 1)),
                        ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.only(right: 20),
                    child: this.terms == null
                        ? Text('No Data')
                        : RaisedButton(
                            color: Color.fromRGBO(33, 23, 47, 1),
                            onPressed: () {
                              print('LINK:${this.datesvalue.date_sheet}');
                              setState(() {
                                if (this.datesvalue.date_sheet == null ||
                                    this.datesvalue.date_sheet == '') {
                                  Toast.show('No Pdf Link Found', context,
                                      duration: Toast.LENGTH_LONG,
                                      gravity: Toast.BOTTOM);
                                }
                                createFileOfPdfUrl(this.datesvalue.date_sheet)
                                    .then((f) {
                                  setState(() {
                                    pathPDF = f.path;
                                    print(pathPDF);
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PDFScreen(pathPDF),
                                    ),
                                  );
                                });
                              });
                            },
                            child: Text(
                              'Open Pdf',
                              style: TextStyle(color: Colors.white),
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

  Widget _datesheetlink() {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: <Widget>[
              Text(
                'Terms',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                'DateSheet Link',
                style: TextStyle(fontWeight: FontWeight.bold),
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
        title: Text('DateSheet'),
        centerTitle: true,
      ),
      body: loader
          ? RefreshIndicator(
              onRefresh: () async {
                _dateSheet();
                 return await Future.delayed(Duration(seconds: 3));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 30, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _datesheetlink(),
                        _commonRow(),
                      ],
                    ),
                  )),
            )
          : bodyProgress,
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
          title: Text("Document"),
        ),
        path: pathPDF);
  }
}
