import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/models/SingleTimeTable.dart';
import 'package:google_live/models/VideosModel.dart';
import 'package:google_live/widgets/UploadFiles.dart';
import 'package:google_live/widgets/UploadedFilesInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ShowSubjects extends StatefulWidget {
  final DateTime datepick;
  ShowSubjects({this.datepick});
  @override
  _ShowSubjectsState createState() => _ShowSubjectsState();
}

class _ShowSubjectsState extends State<ShowSubjects> {
  Future<List<SingleTimeTable>> singleTimeTable;
  List<VideosModel> videolist = [];
  var dateT;
  var sectionID;
  var periodID;
  var classID;
  var subjectId;
  var liveClassId;
  bool isData = false;
  int periodId, classId, sectionId, subIds;
  int secId, periId, clsId, subId;
  Map<String, dynamic> live_data;
  var accessdata;
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
        'http://sghps.cityschools.co/teacherapi/singletimetable_teacher?access_token=' +
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
            u['section_name'],
            u['teacher_name']);
        list.add(single);
      }

      print(list.length);
    }).catchError((onError) {
      print(onError);
    });
    return list;
  }

  Future<void> _chooseSubject(secId, periId, clsId, subId) async {
    videolist = [];
    final prefs = await SharedPreferences.getInstance();
    var header = {
      "Accept": "application/json",
      'Content-Type': "application/json;charset=UTF-8",
      'Charset': "utf-8",
    };
    String url =
        'https://sghps.cityschools.co/studentapi/class_live_data?access_token=' +
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
        .get(url, headers: {'Accept': 'application/json'}).then((res) {
      setState(() {
        this.live_data = json.decode(res.body);
        var live_class_data = this.live_data['live_class_data'];
        var check_assignment = this.live_data['assignment_check'];
       
        if (live_class_data != null) {
          var videos = live_class_data['videos'];

          for (var v in videos) {
            this.liveClassId = v['id'];
            print(this.liveClassId);
            VideosModel videosModel = VideosModel(v['title'], v['link'],this.liveClassId);

            videolist.add(videosModel);
          }
          print(videolist.length);
          var liveClassDataID = live_class_data['id'];
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadedFilesInfo(
                dateT: widget.datepick,
                sectionId: secId,
                periodId: periId,
                classId: clsId,
                subjectId: subId,
                video_link: videolist,
                audio_link: live_audio,
                image_link: live_image,
                pdf_link: live_pdf,
                live_class_link: live_class,
                text_link: live_text,
                check_assign: check_assignment,
                liveClassId:liveClassDataID
              ),
            ),
          );
        }
         else if (live_class_data == null) {
          print('empty');

          print(live_class_data);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadFiles(
                dateT: widget.datepick,
                sectionId: secId,
                periodId: periId,
                classId: clsId,
                subjectId: subId,
              ),
            ),
          );
        }

        // print('Button Click:$live_class_data');
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
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
        title: Text('Shows Subjects'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: singleTimeTable,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return bodyProgress;
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
                      Radius.circular(100),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: SizedBox.fromSize(
                      size: Size(110, 110), // button width and height
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
                                      '${snapshot.data[i].period_name}',
                                  style: TextStyle(color: Colors.black),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                    '${snapshot.data[i].class_name}'
                                    '\t'
                                    '-'
                                    '\t'
                                    '${snapshot.data[i].section_name}',
                                    style: TextStyle(color: Colors.black)),
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
    );
  }
}
