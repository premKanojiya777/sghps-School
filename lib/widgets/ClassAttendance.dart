import 'dart:convert';
import 'package:google_live/models/ClassAttenModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassAttendance extends StatefulWidget {
  @override
  _ClassAttendanceState createState() => _ClassAttendanceState();
}

class _ClassAttendanceState extends State<ClassAttendance> {
  Future<List<ClassAttenModel>> futureList;
  List<ClassAttenModel> stuList = [];
  List selectedStuList = [];
  var classs;
  var section;
  bool loader = false;
  var stuName;
  var stuID;

  @override
  void initState() {
    super.initState();
    futureList = _filterSection();
  }

  Future<List<ClassAttenModel>> _filterSection() async {
    stuList = [];
    final prefs = await SharedPreferences.getInstance();

    String url =
        'https://sghps.cityschools.co/teacherapi/class_attendance?access_token=' +
            prefs.get('token');

    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      setState(() {
        Map<String, dynamic> dataresponse = json.decode(res.body);
        var students = dataresponse['students'];
        this.classs = dataresponse['class'];
        this.section = dataresponse['section'];

        for (var s in students) {
          this.stuName = s['stu_name'];
          this.stuID = s['student_id'];
          ClassAttenModel filterModel = ClassAttenModel(
              this.stuName, s['status'], s['class_roll'], this.stuID, false);
          stuList.add(filterModel);
        }
        loader = true;
      });

      print(stuList.length);
    }).catchError((onError) {
      print(onError);
    });
    return stuList;
  }

  Future<void> _submit() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    stuList.forEach((f) {
      var apList = {"id": f.students_id, "status": f.status};
      selectedStuList.add(apList);
    });
    var _body = {
      'access_token': prefs.get('token'),
      'stu': selectedStuList,
    };
    String url =
        'https://sghps.cityschools.co/teacherapi/update_class_attendance';

    final response = await http
        .post(url, body: jsonEncode(_body), headers: headers)
        .then((res) {
      setState(() {});
      print(_body);
      print('RES${res.body}');
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
        title: Text(' Attendance Mark'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
      ),
      body: loader
          ? RefreshIndicator(
              onRefresh: () async {
                _filterSection();
                return await Future.delayed(Duration(seconds: 3));
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: FutureBuilder(
                      future: futureList,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return Text('');
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Text(
                                    'Class : ${this.classs} - ${this.section}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Divider(),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: <Widget>[
                                        Text('Roll No',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors
                                                    .lightBlueAccent[100])),
                                        SizedBox(
                                          width: 80,
                                        ),
                                        Text('Name',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors
                                                    .lightBlueAccent[100])),
                                        SizedBox(
                                          width: 80,
                                        ),
                                        Text('Select',
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors
                                                    .lightBlueAccent[100])),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: stuList.length,
                                  itemBuilder: (BuildContext context, int i) {
                                    Spacer();
                                    return Table(
                                      defaultColumnWidth:
                                          FixedColumnWidth(90.0),
                                      border: TableBorder.all(
                                          color: Colors.lightBlueAccent[100]),
                                      children: [
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20),
                                              child: new Text(''),
                                            ),
                                            Container(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                child: new Text(
                                                    snapshot.data[i].stu_name)),
                                            Container(
                                              color: stuList[i].status == "P"
                                                  ? Colors.green
                                                  : Colors.red,
                                              child: CheckboxListTile(
                                                activeColor: Colors.white,
                                                checkColor: Colors.black,
                                                value: stuList[i].status == "P",
                                                onChanged: (val) {
                                                  setState(() {
                                                    if (val == true) {
                                                      stuList[i].status = "P";
                                                    } else {
                                                      stuList[i].status = "A";
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                // ),
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Container(
                                  width: 80,
                                  height: 35,
                                  child: RaisedButton(
                                    onPressed: () {
                                      setState(() {
                                        _submit();
                                        print(selectedStuList.length);
                                         Navigator.pop(context);
                                      });
                                    },
                                    color: Colors.grey,
                                    textColor: Colors.white,
                                    padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                                    child: Text(
                                      'Submit',
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          );
                        }
                      }),
                ),
              ),
            )
          : bodyProgress,
    );
  }
}
