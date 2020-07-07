import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/models/LeaveModel.dart';
import 'package:google_live/models/LeaveValueModel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

DateTime _currentDate = new DateTime.now();

class StudentLeaves extends StatefulWidget {
  @override
  _StudentLeavesState createState() => _StudentLeavesState();
}

class _StudentLeavesState extends State<StudentLeaves> {
  final date = TextEditingController();
  final description = TextEditingController();
  var image;
  LeaveModel leaveModel;
  var listofLeaves = List<Widget>();
  File imageFile;
  String imageDecoded;
  bool loader = false;

  String _showDate = DateFormat.yMMMMEEEEd().format(_currentDate);

  @override
  void initState() {
    super.initState();
    _leaveListsShow();
  }

  Future getImage() async {
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
    //  image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      imageFile = image;
      print(imageFile);
    });
  }

  Future<void> _leaveListsShow() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/student_leaves?access_token=' +
            prefs.get('token');
    await getLeaveList(url, prefs.get('token'));
  }

  Future<String> getLeaveList(String url, accessToken) async {
    final response = await http
        .get(url, headers: {"Content-Type": "application/json"}).then((res) {
      //print({"res", res.body});
      Map<String, dynamic> user = jsonDecode(res.body);
      leaveModel = LeaveModel.fromJson(user);
      // print(user);
      if (leaveModel.leave == null) {
        print('error');
      } else {
        for (Leave leaves in leaveModel.leave.leavelist) {
          listofLeaves.add(_commonRow(
              '${leaves.id}',
              '${leaves.date}',
              '${leaves.reason_for}',
              '${leaves.attachement}',
              '${leaves.status}'));
        }
      }
      loader = true;
    }).catchError((onError) {
      print(onError);
    });
  }

  Future<void> _apply() async {
    // String _desc = description.text;
    // final prefs = await SharedPreferences.getInstance();
    final path = imageFile.readAsBytesSync();
    this.imageDecoded = base64Encode(path);
    print(this.imageDecoded.substring(0, 100));
    String url = 'http://sghps.cityschools.co/studentapi/test_image';
    // prefs.get('token');
    http.post(url, body: {
      // "url": url,
      // "dates": _showDate,
      // "reason": _desc,
      "image": this.imageDecoded
    }).then((Response response) {
      print("Response body: ${response.body}");
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

  Widget _leavesList() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text('List Of Applied Leaves',
              style: TextStyle(fontSize: 21, color: Color.fromRGBO(33, 23, 47, 1))),
        ),
        Divider(),
        Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Row(
            children: <Widget>[
              Text(
                'Sr NO.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                'Date',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                'Reason',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                'File',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
        Divider(),
        ListView(shrinkWrap: true, children: <Widget>[])
      ],
    );
  }

  Widget _commonRow(
      String srNo, String _dates, String reasons, String files, String status) {
    return Container(
      width: 600,
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: 10,
            ),
            child: Row(
              children: <Widget>[
                Text(srNo),
                Spacer(),
                Text(_dates),
                Spacer(),
                Text(reasons),
                Spacer(),

                // new Center(child: new Icon(Icons.link)),
                // new Center(
                //   child: new FadeInImage.memoryNetwork(
                //      placeholder:nofound ,
                //     image:
                //         'http://smart.sksk.in/uploads/leaves/' + files,

                //   ),
                // ),
                // Container(
                //   height: 10,
                //   width: 10,
                //   child: Image.network(
                //     'http://smart.sksk.in/uploads/leaves/' + files,
                //     scale: 1.0,
                //   ),
                // ),
                Spacer(),
                Text(status),
                Spacer(),
              ],
            ),
          ),
          SizedBox(height: 5),
          Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
        title: Text('Leave'),
        centerTitle: true,
      ),
      body:  SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              Container(
                  width: 320,
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    // ?controller: date,
                    // autocorrect: true,
                    decoration: InputDecoration(
                      hintText: _showDate,
                      fillColor: Colors.white,
                    ),
                  )),
              SizedBox(height: 10.0),
              Container(
                  width: 320,
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: description,
                    autocorrect: true,
                    maxLines:2,
                    decoration: InputDecoration(
                      hintText: "Enter Description",
                      fillColor: Colors.white,
                    ),
                  )),
              Container(
                height: 100,
                width: 100,
                child: image == null
                    ? Text('No image selected.')
                    : Image.file(image),
              ),
              SizedBox(
                width: 150,
                child: RaisedButton(
                  color:Color.fromRGBO(33, 23, 47, 1),
                  textColor: Colors.white,
                  child: Text('AttachMent'),
                  onPressed: getImage,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 40.0,
                width: 300,
                child: RaisedButton(
                  onPressed: () {
                    _apply();
                
                  },
                  color: Color.fromRGBO(33, 23, 47, 1),
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                  child: Text(
                    'Apply ',
                  ),
                ),
              ),
              
              Divider(),
              loader ?
              _leavesList() :
              // ...listofLeaves,
              bodyProgress,
            ],
          ),
        ),
      ),
    );
  }
}
