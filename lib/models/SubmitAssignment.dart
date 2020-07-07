import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubmitAssignment extends StatefulWidget {
  final DateTime dateTIME;
  final int classIID;
  final int periodIID;
  final int sectionIID;
  final int subjectIID;

  const SubmitAssignment(
      {this.dateTIME,
      this.classIID,
      this.periodIID,
      this.sectionIID,
      this.subjectIID});
  @override
  _SubmitAssignmentState createState() => _SubmitAssignmentState();
}

class _SubmitAssignmentState extends State<SubmitAssignment> {
  var singleImage;
  File singleImageFile;
  bool visible = false;

  String singleImageDecoded;

  @override
  void initState() {
    super.initState();
    print(widget.periodIID);
    super.initState();
  }

  Future singleImageCamera() async {
    singleImage = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      singleImageFile = singleImage;
      final path = singleImageFile.readAsBytesSync();
      this.singleImageDecoded = base64Encode(path);
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

  void _submitAssignment() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/test_image?access_token=' +
            prefs.get('token');
    Map dataMap = {
      "solo_image": this.singleImageDecoded,
      "period_id": widget.periodIID,
      "subject_id": widget.subjectIID,
      "class_id": widget.classIID,
      "section_id": widget.sectionIID,
      "date": widget.dateTIME.toString()
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
    setState(() {
      visible = false;
    });
    httpClient.close();

    print(singleImage);
    return reply;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Assignment'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            singleImage == null
                ? Text('No image selected.')
                : Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      // borderRadius:
                      //     BorderRadius.only(topLeft: Radius.circular(20)
                      //         // Radius.circular(100),
                      //         ),
                    ),
                    child: Card(child: Image.file(singleImage))),
            RaisedButton(
              color: Color.fromRGBO(33, 23, 47, 1),
              textColor: Colors.white,
              child: Text('Choose Files'),
              onPressed: _singleImageDialogBox,
            ),


            RaisedButton(
              color: Color.fromRGBO(33, 23, 47, 1),
              textColor: Colors.white,
              child: Text('Submit File'),
              onPressed: (){},
            ),
          ],
        ),
      ),
    );
  }
}
