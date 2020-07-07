import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/models/SingleTimeTable.dart';
import 'package:google_live/widgets/StudentsUploadedFiles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

class StudentSubject extends StatefulWidget {
  final DateTime datepick;
  final DateTime dateofAtten;

  StudentSubject({this.datepick, this.dateofAtten});
  @override
  _StudentSubjectState createState() => _StudentSubjectState();
}

class _StudentSubjectState extends State<StudentSubject> {
  Future<List<SingleTimeTable>> singleTimeTable;
  var sectionID;
  var periodID;
  var classID;
  var subjectId;
  bool isData = false;
  int periodId, classId, sectionId, subIds;
  int secId, periId, clsId, subId;
  Map<String, dynamic> live_data;
  var accessdata;
  var error;
  int _radioValue1 =-1;
  @override
  void initState() {
    super.initState();
    singleTimeTable = _singleTimeTable();
    
    super.initState();
  }

  Future<List<SingleTimeTable>> _singleTimeTable() async {
    List<SingleTimeTable> list = [];
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/singletimetable?access_token=' +
            prefs.get('token') +
            '&date=' +
            widget.datepick.toString();
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      Map<String, dynamic> days = json.decode(res.body);
      var timetable = days['day'];
      for (var u in timetable) {
        this.classID = u['class_id'];
        this.sectionID = u['section_id'];
        this.periodID = u['period_id'];
        this.subjectId = u['subject_id'];
        this.isData = u['data'];
        SingleTimeTable single = SingleTimeTable(
            u['subject_name'],
            u['class_name'],
            u['period_name'],
            this.classID,
            this.periodID,
            this.sectionID,
            this.subjectId,
            this.isData,
            u['teacher_name']);
        list.add(single);
      }

      print(list.length);
    }).catchError((onError) {
      print(onError);

      print(url);
    });
    return list;
  }

  Future<void> _addAttendance(int value) async {
   
    
    final prefs = await SharedPreferences.getInstance();
    String url = 'http://sghps.cityschools.co/studentapi/attendance_student';

    final response = await http.post(url, body: {
      'access_token': prefs.get('token'),
      'date': widget.datepick.toString(),
    }, headers: {
      "Accept": "application/json"
    }).then((res) {
      setState(() {
        var added = json.decode(res.body);
        this.error = added['error'];
        var attendance = added['message'];
        print(added);
        Toast.show(attendance, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      });
    }).catchError((onError) {
      print(onError);

    });
     setState(() {
      _radioValue1 =value;
    });
  }

  Future<void> _chooseSubject(secId, periId, clsId, subId) async {
    print(periId);
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/class_live_data?access_token=' +
            prefs.get('token') +
            '&date=' +
            widget.datepick.toString() +
            '&period_id=' +
            periId.toString() +
            '&class_id=' +
            clsId.toString() +
            '&section_id=' +
            secId.toString() +
            '&subject_id=' +
            subId.toString();
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      setState(() {
        this.live_data = json.decode(res.body);
        var live_class_data = this.live_data['live_class_data'];
        var live_periodID = live_class_data['period_id'];
        var live_classID = live_class_data['class_id'];
        var live_sectionID = live_class_data['section'];
        var live_subjectID = live_class_data['subject_id'];
        var live_video = live_class_data['video_link'];
        var live_audio = live_class_data['audio_link'];
        var live_class = live_class_data['live_class_link'];
        var live_image = live_class_data['image'];
        var live_pdf = live_class_data['pdf'];
        var live_text = live_class_data['text'];
        if (live_class_data != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentsUploadedFilesInfo(
                dateT: widget.datepick,
                sectionId: secId,
                periodId: periId,
                classId: clsId,
                subjectId: subId,
                video_link: live_video,
                audio_link: live_audio,
                image_link: live_image,
                pdf_link: live_pdf,
                live_class_link: live_class,
                text_link: live_text,
              ),
            ),
          );
          print('Button Click:$live_class_data');
        } else if (live_class_data == null) {
          print('No Data Founds');
        }
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
        title: Text('Time Table'),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          FutureBuilder(
            future: singleTimeTable,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Container(
                  child: Center(
                    child: Text("Loading..."),
                  ),
                );
              } else {
                return GridView.builder(
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int i) {
                    return Container(
                      decoration: BoxDecoration(
                        color: snapshot.data[i].isData
                            ? Colors.green
                            : Colors.redAccent,
                        borderRadius: BorderRadius.all(
                          Radius.circular(70),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: SizedBox.fromSize(
                          size: Size(80, 80), // button width and height
                          child: ClipOval(
                            child: Material(
                              color: Colors.white, // button color
                              child: InkWell(
                                onTap: () {
                                  _chooseSubject(
                                    snapshot.data[i].class_id,
                                    snapshot.data[i].period_ID,
                                    snapshot.data[i].section_id,
                                    snapshot.data[i].subject_id,
                                  );
                                }, // button pressed

                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      '${snapshot.data[i].subject_name}' +
                                          '\t' +
                                          '${snapshot.data[i].period_ID}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Text('${snapshot.data[i].class_name}',
                                        style: TextStyle(color: Colors.black)),
                                    Text('${snapshot.data[i].teacher_name}',
                                        style: TextStyle(color: Colors.black,fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    );
                  },
                );
              }
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment(0.7, 0.0),
                child: Text(
                  'Mark Your Attendance',
                  style: new TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
              ),
               new Radio(
                  value: 1,
                  groupValue: error == false ? _radioValue1 : null,
                  onChanged: _addAttendance,
                ),
              // new FlatButton(
              //   child: Icon(this.error == false
              //       ? Icons.radio_button_checked
              //       : Icons.radio_button_unchecked),
              //   onPressed: () {},
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
