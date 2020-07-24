import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:google_live/models/AssignmentImageModel.dart';
import 'package:google_live/models/AssignmentModel.dart';
import 'package:google_live/widgets/ShowSubjects.dart';
import 'package:http/http.dart' as http;
import 'package:dospace/dospace.dart' as dospace;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/widgets/Constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadedFilesInfo extends StatefulWidget {
  final DateTime dateT;
  final int classId;
  final int periodId;
  final int sectionId;
  final int subjectId;
  final List video_link;
  final String audio_link;
  final String image_link;
  final String pdf_link;
  final String live_class_link;
  final String text_link;
  final int check_assign;
  final int liveClassId;
  UploadedFilesInfo(
      {this.dateT,
      this.periodId,
      this.classId,
      this.sectionId,
      this.subjectId,
      this.video_link,
      this.audio_link,
      this.image_link,
      this.pdf_link,
      this.text_link,
      this.live_class_link,
      this.check_assign,
      this.liveClassId});
  @override
  _UploadedFilesInfoState createState() => _UploadedFilesInfoState();
}

class _UploadedFilesInfoState extends State<UploadedFilesInfo> {
  List<AssignmentModel> assignList = [];
  ImageModel imageModel;
  List<ImageModel> listImage = [];
  http.BaseRequest request;
  bool isUpdateClick = false;
  bool imageClick = false;
  bool isAssignmentClick = false;
  bool view = false;
  bool mainWidget = true;
  String audioPath;
  String imgUrl;
  String assignmentImagesUrl;
  int assignID;
  String pdfUrl;
  String audioUrl;
  String imgFileName;
  String pdfFileName;
  String audioFilename;
  File pdfFiles;
  bool visible = false;
  var pdfFile;
  String pdfPath;
  var image;
  var singleImage;
  var audioFile;
  File audio;
  File imageFile;
  File singleImageFile;
  // String image
  String singleImageDecoded;
  var enterText = TextEditingController();
  List videoLinkTitle = [];
  var liveClass = TextEditingController();
  List<TextEditingController> _linkTitle = new List();
  List<TextEditingController> _link = new List();
  List<TextEditingController> _linkID = new List();
  final remarks = TextEditingController();
  final marks = TextEditingController();
  var cards = <Card>[];
  @override
  void initState() {
    super.initState();
    getImage();
    widget.video_link.forEach((f) {
      cards.add(createCard(f.title, f.link));
    });
    enterText.text = widget.text_link;
    liveClass.text = widget.live_class_link;
    getImage();
    getAudio();
    getPDF();
    super.initState();
  }

  dospace.Spaces spaces = new dospace.Spaces(
    region: Constant.region,
    accessKey: Constant.accessKey,
    secretKey: Constant.secretKey,
  );

  getImage() {
    String endPoint = "https://sghps.ams3.digitaloceanspaces.com/images";
    request = http.Request("GET", Uri.parse('$endPoint/${widget.image_link}'));
    this.imgUrl = spaces.signRequest(request, preSignedUrl: true);
    print(this.imgUrl);
  }

  getAudio() {
    String endPoint = "https://sghps.ams3.digitaloceanspaces.com/audio";
    request = http.Request("GET", Uri.parse('$endPoint/${widget.audio_link}'));
    this.audioUrl = spaces.signRequest(request, preSignedUrl: true);
    print(this.audioUrl);
  }

  getPDF() {
    String endPoint = "https://sghps.ams3.digitaloceanspaces.com/pdf";
    request = http.Request("GET", Uri.parse('$endPoint/${widget.pdf_link}'));
    this.pdfUrl = spaces.signRequest(request, preSignedUrl: true);
    print(this.pdfUrl);
  }

  _openLiveClass() async {
    var video = widget.live_class_link;
    var url = '$video';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _getAssignments() async {
    assignList = [];
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/get_assignment?access_token=' +
            prefs.get('token') +
            '&date=' +
            widget.dateT.toString() +
            '&id=' +
            widget.liveClassId.toString();
    final response = await http
        .get(url, headers: {'Accept': 'application/json'}).then((res) {
      setState(() {
        var assignments = json.decode(res.body);
        var assign_gets = assignments['assignment_check'];

        for (var asm in assign_gets) {
          this.assignID = asm['id'];
          // print(this.assignID);
          var img = asm['image'];
          AssignmentModel assignmentModel =
              AssignmentModel(asm['stu']['first_name'], asm['id'], img);
          assignList.add(assignmentModel);

          for (var i in assignList[0].image) {
            imageModel = ImageModel(i['image'], i['student_assignment_id']);

            // listImage.add(imageModel);
          }
          // print(imageModel.assignId);
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
        title: Text('Uploaded Files Info'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            mainWidget
                ? _mainWidget()
                : Column(
                    children: <Widget>[
                      Text(
                        'Students Submit Assignments',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Divider(),
                      _assignmentWidget(),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  Widget _mainWidget() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color:
                            widget.video_link == null || widget.video_link == ""
                                ? Colors.redAccent
                                : Colors.green,
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
                                  return showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      content: Container(
                                        width: 400,
                                        height: 400,
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            padding: EdgeInsets.all(1),
                                            itemCount: widget.video_link.length,
                                            itemBuilder:
                                                (BuildContext context, int i) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(widget
                                                      .video_link[i].title),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  RaisedButton(
                                                    onPressed: () async {
                                                      print(widget
                                                          .video_link[i].link);
                                                      var url = widget
                                                          .video_link[i].link;
                                                      if (await canLaunch(
                                                          url)) {
                                                        await launch(url);
                                                      } else {
                                                        throw 'Could not launch $url';
                                                      }
                                                    },
                                                    child: Text('Link'),
                                                    color: Colors.blue,
                                                  ),
                                                ],
                                              );
                                            }),
                                      ),
                                      actions: <Widget>[
                                        new FlatButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(context);
                                          },
                                          child: Text('Close'),
                                        )
                                      ],
                                    ),
                                  );
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'Video Lecture',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Text('Video Lecture'),
                  ],
                ),
                SizedBox(
                  width: 6,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: widget.audio_link == null || widget.audio_link == ""
                        ? Colors.redAccent
                        : Colors.green,
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
                            onTap: () async {
                              var url = this.audioUrl;
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            }, // button pressed
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                widget.audio_link == null ||
                                        widget.audio_link == ""
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            'Audio Lecture',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Audio Lecture',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 6,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: widget.image_link == null || widget.image_link == ""
                        ? Colors.redAccent
                        : Colors.green,
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
                              setState(() {
                                imageClick = true;
                                isAssignmentClick = false;
                                isUpdateClick = false;
                              });
                            }, // button pressed

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                widget.image_link != null
                                    ? Text(
                                        'Image Content ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        'No Image',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: widget.pdf_link == null || widget.pdf_link == ""
                        ? Colors.redAccent
                        : Colors.green,
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
                            onTap: () async {
                              var url = this.pdfUrl;
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            }, // button pressed

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                widget.pdf_link == null || widget.pdf_link == ""
                                    ? Text(
                                        'No PDF EBook',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        'PDF EBook',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 6,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: widget.text_link == null || widget.text_link == ""
                        ? Colors.redAccent
                        : Colors.green,
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
                              return showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  content: Text(widget.text_link),
                                  actions: <Widget>[
                                    new FlatButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(context);
                                      },
                                      child: Text('Close'),
                                    )
                                  ],
                                ),
                              );
                            }, // button pressed

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Text',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 6,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: widget.live_class_link == null ||
                            widget.live_class_link == ""
                        ? Colors.redAccent
                        : Colors.green,
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
                            onTap: _openLiveClass,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Live Class',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
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
                            onTap: () async {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => UpdateData(
                              //             videoLink: widget.video_link,
                              //             textLink: widget.text_link,
                              //             liveClassLink: widget.live_class_link,
                              //             imageLink: widget.image_link,
                              //             pdfLink: widget.pdf_link,
                              //             audioLink: widget.audio_link,
                              //             dateT: widget.dateT,
                              //             periodId: widget.periodId,
                              //             sectionId: widget.sectionId,
                              //             subjectId: widget.subjectId,
                              //             classId: widget.classId,
                              //           )),
                              // );
                              // print(widget.pdf_link);
                              setState(() {
                                isUpdateClick = true;
                                isAssignmentClick = false;
                                imageClick = false;
                              });
                            }, // button pressed

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Update',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 6,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: widget.check_assign == 0 ? Colors.red : Colors.green,
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
                              setState(() {
                                if (widget.check_assign == 0) {
                                  print('noData');
                                } else {
                                  isAssignmentClick = true;
                                  isUpdateClick = false;
                                  imageClick = false;
                                  mainWidget = false;
                                  _getAssignments();
                                }
                              });
                            }, // button pressed

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Assignment',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            imageClick == true
                ? Row(
                    children: <Widget>[
                      Container(
                        width: 120,
                        height: 100,
                        child: GestureDetector(
                          child: Image.network(this.imgUrl),
                          onTap: () {
                            return showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                content: Image.network(
                                  (this.imgUrl),
                                  fit: BoxFit.fill,
                                ),
                                actions: <Widget>[
                                  new FlatButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(context);
                                    },
                                    child: Text('Close'),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : Container(),
            SizedBox(
              height: 10,
            ),
            isUpdateClick == true
                ? Column(
                    children: <Widget>[
                      Text(
                        'Update Form',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Divider(),
                      _updateDataWidget(),
                    ],
                  )
                : Container(),
            isAssignmentClick
                ? Column(
                    children: <Widget>[
                      Text(
                        'Students Submit Assignments',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      Divider(),
                      _assignmentWidget(),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _assignmentWidget() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(1),
              itemCount: assignList.length,
              itemBuilder: (BuildContext context, int i) {
                return Padding(
                  padding: const EdgeInsets.only(left: 120),
                  child: Row(
                    children: <Widget>[
                      Text('${assignList[i].first_name}'),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: RaisedButton(
                          color: Color.fromRGBO(33, 23, 47, 1),
                          onPressed: () {
                            setState(() {
                              listImage = [];
                              view = true;
                              for (var im in assignList[i].image) {
                                ImageModel imageModel = ImageModel(
                                    im['image'], im['student_assignment_id']);
                                listImage.add(imageModel);
                              }

                              // print(this.assignmentImagesUrl);
                            });
                          },
                          child: Text(
                            'View',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          view
              ? GridView.builder(
                  shrinkWrap: true,
                  itemCount: listImage.length,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4),
                  itemBuilder: (BuildContext context, int i) {
                    String endPoint =
                        "https://sghps.ams3.digitaloceanspaces.com/images";
                    request = http.Request("GET",
                        Uri.parse('$endPoint/' + '${listImage[i].image}'));
                    print(request);
                    this.assignmentImagesUrl =
                        spaces.signRequest(request, preSignedUrl: true);
                    return GestureDetector(
                      child: GridTile(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                            ),
                          ),
                          child: Card(
                            child: Image.network(
                              ('${this.assignmentImagesUrl}'),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ),
                      onTap: () {
                        print('${listImage[i].image}');
                        return showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            content: Image.network(
                              ('${this.assignmentImagesUrl}'),
                              fit: BoxFit.fill,
                            ),
                            actions: <Widget>[
                              new FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop(context);
                                },
                                child: Text(
                                  'Close',
                                  style: TextStyle(
                                      color: Color.fromRGBO(33, 23, 47, 1)),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                )
              : Container(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: remarks,
              style: TextStyle(color: Colors.blue),
              decoration: InputDecoration(labelText: 'Remarks'),
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: marks,
              autocorrect: true,
              decoration: InputDecoration(
                hintText: "Marks Like 100/40",
                fillColor: Colors.white,
              ),
            ),
          ),
          Container(
            width: 380,
            child: RaisedButton(
              color: Color.fromRGBO(33, 23, 47, 1),
              onPressed: () {
                setState(() {
                   _updateAssignMent();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowSubjects(
                              datepick: widget.dateT,
                            )),
                  );
                  visible =true;
                });
               
              },
              child: Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  Card createCard([String optTitleText, String optLinkText]) {
    var titleController = TextEditingController();
    var linkController = TextEditingController();
    titleController.text = optTitleText;
    linkController.text = optLinkText;
    _linkTitle.add(titleController);
    _link.add(linkController);
    _linkID.add(titleController);

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: titleController,
            // style: TextStyle(color: Colors.blue),
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
              controller: linkController,
              decoration: InputDecoration(labelText: 'Link')),
        ],
      ),
    );
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

  void _pdfUpload() async {
    String projectName = "sghps";

    String region = "ams3";

    String extension = 'pdf';
    String folderName = "pdf";
    this.pdfFileName = "${DateTime.now().millisecondsSinceEpoch}.$extension";

    print(this.pdfFileName);
    String uploadedFileUrl = "https://" +
        projectName +
        "." +
        region +
        ".digitaloceanspaces.com/" +
        folderName +
        "/" +
        this.pdfFileName.toString();
    print('url: $uploadedFileUrl');
    dospace.Bucket bucketpdf = spaces.bucket('sghps');
    String etagpdf = await bucketpdf.uploadFile(
        folderName + '/' + this.pdfFileName.toString(),
        pdfFile,
        'application/pdf',
        dospace.Permissions.private);

    print('upload: $etagpdf');
    print('done');
  }

  void _galleryImageUpload() async {
    String extension = 'jpg';
    String projectName = "sghps";

    String region = "ams3";

    String folderName = "images";
    this.imgFileName = "${DateTime.now().millisecondsSinceEpoch}.$extension";

    print(this.imgFileName);
    String uploadedFileUrl = "https://" +
        projectName +
        "." +
        region +
        ".digitaloceanspaces.com/" +
        folderName +
        "/" +
        this.imgFileName.toString();
    print('url: $uploadedFileUrl');
    dospace.Bucket bucket1 = spaces.bucket('sghps');
    String etagal = await bucket1.uploadFile(
        folderName + '/' + this.imgFileName.toString(),
        singleImage,
        'image/jpeg',
        dospace.Permissions.private);

    print('upload: $etagal');
    print('done');
  }

  void _mp3Upload() async {
    String projectName = "sghps";

    String region = "ams3";

    String extension = 'mp3';
    String folderName = "audio";
    this.audioFilename = "${DateTime.now().millisecondsSinceEpoch}.$extension";

    print(this.audioFilename);
    String uploadedFileUrl = "https://" +
        projectName +
        "." +
        region +
        ".digitaloceanspaces.com/" +
        folderName +
        "/" +
        this.audioFilename.toString();
    print('url: $uploadedFileUrl');
    dospace.Bucket bucketmp3 = spaces.bucket('sghps');
    String etagmp3 = await bucketmp3.uploadFile(
        folderName + '/' + this.audioFilename.toString(),
        audioFile,
        'audio/mpeg',
        dospace.Permissions.private);

    print('upload: $etagmp3');
    print('done');
  }

  Future<void> _updateAssignMent() async {
    String _remark = remarks.text;
    String _mark = marks.text;
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    var _body = {
      'access_token': prefs.get('token'),
      'id': this.assignID,
      'remarks': _remark,
      'marks': _mark,
      // 'date':widget.dateT.toString()
    };
    String url = 'http://sghps.cityschools.co/studentapi/updateremarks';
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

  void _updateFiles() async {
    videoLinkTitle = [];
    _galleryImageUpload();
    _mp3Upload();
    _pdfUpload();

    for (int i = 0; i < _linkTitle.length; i++) {
      videoLinkTitle.add({
        'title': _linkTitle[i].text,
        'link': _link[i].text,
        'id': _linkID == null ? widget.video_link[i].id : 0
      });
    }
    print(videoLinkTitle.length);
    print(videoLinkTitle);
    String _text = enterText.text;
    String _liveClass = liveClass.text;
    final prefs = await SharedPreferences.getInstance();
    String url = 'http://sghps.cityschools.co/studentapi/live_data_update';

    Map dataMap = {
      "access_token": prefs.get('token'),
      "text": _text,
      "video": videoLinkTitle,
      "live_class": _liveClass,
      "period_id": widget.periodId,
      "subject_id": widget.subjectId,
      "class_id": widget.classId,
      "section_id": widget.sectionId,
      "date": widget.dateT.toString(),
      "image": this.imgFileName == null ? widget.image_link : this.imgFileName,
      "pdf": this.pdfFileName == null ? widget.pdf_link : this.pdfFileName,
      "audio":
          this.audioFilename == null ? widget.audio_link : this.audioFilename,
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
    // Map<String, dynamic> respond = jsonDecode(reply);

    setState(() {
      visible = false;
    });
    httpClient.close();
    print(cards.length);
    return reply;
  }

  Widget _updateDataWidget() {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Video Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                      icon: Icon(Icons.add, color: Colors.blue),
                      onPressed: () => setState(() => cards.add(createCard()))),
                  IconButton(
                      icon: Icon(Icons.remove, color: Colors.blue),
                      onPressed: () => setState(() {
                            cards.removeAt(cards.length - 1);
                          })),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cards.length,
                itemBuilder: (BuildContext context, int i) {
                  return cards[i];
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    'Single Image',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                      icon: Icon(Icons.add, color: Colors.blue),
                      onPressed: () {
                        _singleImageDialogBox();
                      }),
                ],
              ),
            ),
            widget.image_link == null || widget.image_link == ""
                ? Text('No image selected.')
                : Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Card(
                      child: singleImage == null
                          ? GestureDetector(
                              child: Image.network(this.imgUrl),
                              onTap: () {
                                return showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    content: Image.network(
                                      this.imgUrl,
                                      fit: BoxFit.fill,
                                    ),
                                    actions: <Widget>[
                                      new FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(context);
                                        },
                                        child: Text('Close'),
                                      )
                                    ],
                                  ),
                                );
                              },
                            )
                          : GestureDetector(
                              child: Image.file(singleImage),
                              onTap: () {
                                return showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    content: Image.file(singleImage),
                                    actions: <Widget>[
                                      new FlatButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(context);
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
            Divider(),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'PDF',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Colors.blue,
                        ),
                        onPressed: () async {
                          pdfFile = await FilePicker.getFile(
                            type: FileType.custom,
                            allowedExtensions: [
                              'pdf',
                            ],
                          );

                          setState(() {
                            pdfFiles = pdfFile;
                            this.pdfPath = pdfFile.path.split('/').last;
                            print(pdfFiles);
                          });
                        },
                      ),
                    ],
                  ),
                ),
                widget.pdf_link == null || widget.pdf_link == ""
                    ? Text('No Pdf Selected')
                    : pdfFile == null
                        ? Text("${widget.pdf_link}")
                        : Text(" $pdfPath"),
              ],
            ),
            Divider(),
            Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        'Audio',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            audioFile = await FilePicker.getFile(
                              type: FileType.audio,
                            );

                            setState(() {
                              audio = audioFile;
                              this.audioPath = audioFile.path.split('/').last;

                              print(audioFile);
                            });
                          }),
                    ],
                  ),
                ),
                widget.audio_link == null || widget.audio_link == ""
                    ? Text('No Audio Selected')
                    : audioFile == null
                        ? Text(" ${widget.audio_link}")
                        : Text(" $audioFile"),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: enterText,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(labelText: widget.text_link),
              ),
            ),
            Divider(),
            Container(
              // width: 340,
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: liveClass,
                autocorrect: true,
                decoration: InputDecoration(
                  hintText: widget.live_class_link,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Divider(),
            RaisedButton(
              color: Color.fromRGBO(33, 23, 47, 1),
              textColor: Colors.white,
              child: Text('Update Files'),
              onPressed: () {
                _updateFiles();
                setState(() {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ShowSubjects(
                              datepick: widget.dateT,
                            )),
                  );

                  visible = true;
                });
              },
            ),
            SizedBox(
              height: 5,
            ),
            Visibility(
              visible: visible,
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Please Wait....",
                    style: TextStyle(color: Color.fromRGBO(33, 23, 47, 1)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
