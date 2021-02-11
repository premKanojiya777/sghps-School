import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class StudentsResults extends StatefulWidget {
  @override
  _StudentsResultsState createState() => _StudentsResultsState();
}

class _StudentsResultsState extends State<StudentsResults> {
  String _mySelection;
  List data = List();
  bool loader = false;

  @override
  void initState() {
    super.initState();
    _getTerms();
  }

  Future<String> _getTerms() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/result_type?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      setState(() {
        Map<String, dynamic> classes = json.decode(res.body);
        var classname = classes['resulttype'];
        print(classname);
        data = classname;
        // sectionListBuffer = SectionModelList.fromJson(classes['sections']);
        // print(sectionList.length);
        loader = true;
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  void _getResult() async {
    final prefs = await SharedPreferences.getInstance();
    String url = 'http://sghps.cityschools.co/studentapi/result?access_token=' +
        prefs.get('token') +
        '&unit=' +
        _mySelection;
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      setState(() {
        Map<String, dynamic> result = json.decode(res.body);
        var resultAll = result['result'];

        if (resultAll == "") {
          Toast.show('No Data Founds', context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
        print(result);
        print(url);
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
        title: Text('Result'),
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
        centerTitle: true,
      ),
      body: loader
          ? Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Card(
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(30),
                          child: Text(
                            'Term',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Spacer(),
                        new DropdownButton(
                          items: data.map((item) {
                            return new DropdownMenuItem(
                              child: new Text('${item['type']}'),
                              value: item['id'].toString(),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            setState(() {
                              _mySelection = newVal;
                              print(_mySelection);
                              _getResult();
                            });
                          },
                          value: _mySelection,
                          hint: Text('Select Term'),
                        ),
                        SizedBox(width: 20,),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : bodyProgress,
    );
  }
}
