import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/models/SectionModel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SendHomework extends StatefulWidget {
  @override
  _SendHomeworkState createState() => _SendHomeworkState();
}

class _SendHomeworkState extends State<SendHomework> {
  final descController = TextEditingController();
  SectionModel section;
  List<SectionModel> sectionList = [];
  String selectedSection = '';
  String _mySelection;
  String sectionselect;
  File singleImageFile;
  String singleImageDecoded;
  var singleImage;
  List data = List();
  SectionModelList sectionListBuffer;
  bool loader = false;
  int classid, sectionId;
  var desc;
  var attach;
  var oldID;
  bool logalert = false;

  @override
  void initState() {
    super.initState();
    _getClasses();
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
                    onTap: singleImageCamera,
                  ),
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
                    onTap: singleImageGallery,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future singleImageGallery() async {
    singleImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      singleImageFile = singleImage;
      final path = singleImageFile.readAsBytesSync();
      this.singleImageDecoded = base64Encode(path);
    });
  }

  Future singleImageCamera() async {
    singleImage = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      singleImageFile = singleImage;
      final path = singleImageFile.readAsBytesSync();
      this.singleImageDecoded = base64Encode(path);
    });
  }

  Future<List<SectionModel>> _getClasses() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/coordinator/class_sec?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      setState(() {
        Map<String, dynamic> classes = json.decode(res.body);
        var classname = classes['classes'];
        print(classname);
        data = classname;

        sectionListBuffer = SectionModelList.fromJson(classes['sections']);

        loader = true;
      });
    }).catchError((onError) {
      print(onError);
    });
    return sectionList;
  }

  Future<void> _getOldWork() async {
    this.desc = '';
    this.attach = '';
    this.oldID = '';
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/coordinator/getclasshw?access_token=' +
            prefs.get('token') +
            '&section_id=${this.sectionId}' +
            '&class_id=${this.classid}';
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      setState(() {
        Map<String, dynamic> classes = json.decode(res.body);
        var homework = classes['homework'];
        this.desc = homework['task'];
        this.attach = homework['attach'];
        this.oldID = homework['id'];

        print(this.desc);
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  Future<String> _sendHomeWork() async {
    var task = descController.text;
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/coordinator/updateclasshw_flutter';

    Map body = {
      'access_token': prefs.get('token'),
      'classid': this.classid.toString(),
      'section_id': this.sectionId.toString(),
      'task': task,
      'id': this.oldID.toString() == null ? 0 : this.oldID.toString(),
      'file': this.singleImageDecoded,
    };
    final response = await http.post(url,
        body: body, headers: {"Accept": "application/json"}).then((res) {
      setState(() {
        print(body);
        logalert = true;
      });
    }).catchError((onError) {
      print(onError);
    });
    return response;
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
          title: Text('Homework'),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(33, 23, 47, 1),
        ),
        body: loader
            ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 100),
                          child: Text('Class'),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 70),
                          width: 200,
                          child: new DropdownButton(
                            items: data.map((item) {
                              return new DropdownMenuItem(
                                child: new Text('${item['value']}'),
                                value: item['id'].toString(),
                              );
                            }).toList(),
                            onChanged: (newVal) {
                              setState(() {
                                _mySelection = newVal;
                                sectionList = [];
                                // isClassSelected = true;
                                for (section in sectionListBuffer.sectionlist) {
                                  if (section.class_id == int.parse(newVal)) {
                                    sectionList.add(section);
                                    selectedSection = section.section_name;
                                  }
                                }
                              });
                            },
                            value: _mySelection,
                            hint: Text('Select Class'),
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 1),
                      child: Column(
                        children: <Widget>[
                          new ListView.builder(
                            shrinkWrap: true,
                            itemCount: sectionList.length,
                            itemBuilder: (context, i) => Container(
                              margin: EdgeInsets.only(right: 25),
                              color: Color(0xfff9f9f9),
                              child: new ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(left: 83),
                                  child: new Text(
                                    "Section-${sectionList[i].section_name}",
                                    // 'Section A',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(selectedSection ==
                                          sectionList[i].section_name
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked),
                                  onPressed: () {
                                    print('${sectionList[i].id}');
                                    setState(() {
                                      selectedSection =
                                          sectionList[i].section_name;
                                      this.classid = sectionList[i].class_id;
                                      this.sectionId = sectionList[i].id;
                                      _getOldWork();
                                    });
                                  },
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 10),
                            child: TextField(
                              controller: descController,
                              autocorrect: true,
                              maxLines: 3,
                              style: TextStyle(fontStyle: FontStyle.normal),
                              decoration: InputDecoration(
                                hintText: this.desc == null || this.desc == ""
                                    ? "Description"
                                    : this.desc.toString(),
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 4.0),
                          this.attach == null || this.attach == ""
                              ? (singleImage == null
                                  ? Text('')
                                  : Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                      ),
                                      child:
                                          Card(child: Image.file(singleImage))))
                              : Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                  ),
                                  child: Card(
                                    child: singleImage == null
                                        ? GestureDetector(
                                            onTap: () {
                                              return showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  content: Image.network(
                                                    'http://sghps.cityschools.co/uploads/homework/${this.attach}',
                                                    fit: BoxFit.fill,
                                                  ),
                                                  actions: <Widget>[
                                                    new FlatButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(context);
                                                      },
                                                      child: Text('Close'),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Image.network(
                                                'http://sghps.cityschools.co/uploads/homework/${this.attach}'),
                                          )
                                        : GestureDetector(
                                            child: Image.file(singleImage),
                                            onTap: () {
                                              return showDialog(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                  content:
                                                      Image.file(singleImage),
                                                  actions: <Widget>[
                                                    new FlatButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop(context);
                                                      },
                                                      child: Text('Close'),
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Container(
                                    width: 130,
                                    height: 40,
                                    child: RaisedButton(
                                      onPressed: _singleImageDialogBox,
                                      color: Color.fromRGBO(33, 23, 47, 1),
                                      textColor: Colors.white,
                                      padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                                      child: Text(
                                        'ATTACHMENT',
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  width: 360,
                                  height: 40,
                                  child: RaisedButton(
                                    onPressed: () {
                                      setState(() {
                                        _sendHomeWork();
                                        logalert = true;
                                        showDialog(
                                          context: context,
                                          useRootNavigator: true,
                                          barrierDismissible: false,
                                          builder: (_) => AlertDialog(
                                            backgroundColor: Color.fromRGBO(
                                                213, 237, 242, 1),
                                            content: Row(
                                              children: [
                                                Visibility(
                                                    visible: logalert,
                                                    child:
                                                        CircularProgressIndicator()),
                                                Container(
                                                    margin: EdgeInsets.only(
                                                        left: 7),
                                                    child: Text("Loading...")),
                                              ],
                                            ),
                                          ),
                                        );
                                        // Navigator.pop(context);
                                      });
                                    },
                                    color: Color.fromRGBO(33, 23, 47, 1),
                                    textColor: Colors.white,
                                    padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                                    child: Text(
                                      'SEND',
                                    ),
                                  ),
                                ),
                              ])
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : bodyProgress);
  }
}
