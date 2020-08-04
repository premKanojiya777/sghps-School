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
  bool visible = false;
  var index = 1;

  String _showDate = DateFormat.yMMMMEEEEd().format(_currentDate);

  @override
  void initState() {
    super.initState();
    _leaveListsShow();
  }

  Future<void> _singleImageDialogBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  GestureDetector(
                      child: Row(
                        children: <Widget>[
                          new Icon(Icons.photo_camera),
                          Padding(
                            padding: EdgeInsets.only(left: 3),
                          ),
                          new Text('Take a picture',
                              style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                      onTap: () async {
                        singleImageCamera();
                      }),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: Row(
                      children: <Widget>[
                        new Icon(Icons.photo_album),
                        Padding(
                          padding: EdgeInsets.only(left: 3),
                        ),
                        new Text(
                          'Select from gallery',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                    onTap: getImage,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future singleImageCamera() async {
    image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      imageFile = image;
      final path = imageFile.readAsBytesSync();
      this.imageDecoded = base64Encode(path);
      print(imageFile);
    });
  }

  Future getImage() async {
    image = await ImagePicker.pickImage(source: ImageSource.gallery);
    //  image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      imageFile = image;
      final path = imageFile.readAsBytesSync();
      this.imageDecoded = base64Encode(path);
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
    listofLeaves= [];
    index = 1;
    final response = await http
        .get(url, headers: {"Content-Type": "application/json"}).then((res) {
      //print({"res", res.body});
      Map<String, dynamic> user = jsonDecode(res.body);
      leaveModel = LeaveModel.fromJson(user);
      print(user);
      if (leaveModel.leave == null) {
        print('error');
      } else {
        for (Leave leaves in leaveModel.leave.leavelist) {
          setState(() {
            listofLeaves.add(_commonRow(
                '${leaves.id}',
                '${leaves.date}',
                '${leaves.reason_for}',
                '${leaves.attachement}',
                '${leaves.status}'));
          });
          index++;
        }
      }
      loader = true;
      print(listofLeaves.length);
    }).catchError((onError) {
      print(onError);
    });
  }

  void _applyLeave() async {
    String _desc = description.text;
    final prefs = await SharedPreferences.getInstance();

    String url = 'http://sghps.cityschools.co/studentapi/leave_flutter';
    var dataMap = {
      'access_token': prefs.get('token'),
      "dates": _showDate,
      "reason": _desc,
      "file": this.imageDecoded
    };

    print(await apiRequest(url, dataMap));
  }

  Future<String> apiRequest(String url, Map dataMap) async {
    String jsonString = json.encode(dataMap);
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.contentType =
        new ContentType("application", "json", charset: "utf-8");
    request.headers.set('Content-Length', jsonString.length.toString());
    request.write(jsonString);
    print(jsonString);
    HttpClientResponse response = await request.close();
    String reply = await response.transform(utf8.decoder).join();
    Map<String, dynamic> user = jsonDecode(reply);
    setState(() {
      visible = false;
    });

    httpClient.close();
    return reply;
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
              style: TextStyle(
                  fontSize: 21, color: Color.fromRGBO(33, 23, 47, 1))),
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
    return Table(
      // defaultColumnWidth: FixedColumnWidth(90.0),
      border: TableBorder.all(color: Colors.black),
      children: [
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: new Text(this.index.toString()),
            ),
            Container(
                padding: EdgeInsets.only(left: 10), child: new Text(_dates)),
            Container(
                padding: EdgeInsets.only(left: 10), child: new Text(reasons)),
            IconButton(
                icon: files == ""
                    ? Text('')
                    : Icon(Icons.link, color: Colors.blue),
                onPressed: () {
                  print(files);
                  return showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      content: Image.network(
                        ('http://sghps.cityschools.co/uploads/leaves/' + files),
                        fit: BoxFit.fill,
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop(context);
                          },
                          child: Text(
                            'Close',
                            style:
                                TextStyle(color: Color.fromRGBO(33, 23, 47, 1)),
                          ),
                        )
                      ],
                    ),
                  );
                }),
            Container(
                color: status == 0 ? Colors.green : Colors.red,
                padding: EdgeInsets.only(left: 10),
                child: status == 0
                    ? new Text(
                        'Approved',
                        style: TextStyle(color: Colors.white),
                      )
                    : new Text('Not Approved',
                        style: TextStyle(color: Colors.white))),
          ],
        ),
      ],
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
      body: RefreshIndicator(
         onRefresh: () async {
                  _leaveListsShow();
                  return await Future.delayed(Duration(seconds: 3));
                },
              child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              Container(
                  width: 350,
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
                  width: 350,
                  padding: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: description,
                    autocorrect: true,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Enter Description",
                      fillColor: Colors.white,
                    ),
                  )),
              image == null
                  ? Text('')
                  : Container(
                      height: 100,
                      width: 100,
                      child: Image.file(image),
                    ),
              Padding(
                padding: const EdgeInsets.only(right: 200),
                child: SizedBox(
                  width: 150,
                  child: RaisedButton(
                    color: Color.fromRGBO(33, 23, 47, 1),
                    textColor: Colors.white,
                    child: Text('Attachment'),
                    onPressed: _singleImageDialogBox,
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 53),
                child: SizedBox(
                  height: 40.0,
                  width: 300,
                  child: RaisedButton(
                    onPressed: () {
                      setState(() {
                        _applyLeave();
                        visible = true;
                      });
                    },
                    color: Color.fromRGBO(33, 23, 47, 1),
                    textColor: Colors.white,
                    padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                    child: Text(
                      'Apply ',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                child: Visibility(
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
              ),

              Divider(),
              // loader ?
              _leavesList(),
              //  :
              ...listofLeaves,
              // bodyProgress,
            ],
          ),
        ),
      ),
    );
  }
}
