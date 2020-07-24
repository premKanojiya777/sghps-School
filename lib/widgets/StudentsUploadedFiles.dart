import 'dart:convert';
import 'dart:io';

import 'package:dospace/dospace.dart' as dospace;
import 'package:google_live/widgets/Constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentsUploadedFilesInfo extends StatefulWidget {
  final DateTime dateT;
  final int classId;
  final int periodId;
  final int sectionId;
  final int subjectId;
  final List video_link;
  final List image_List;
  final String audio_link;
  final String image_link;
  final String pdf_link;
  final String live_class_link;
  final String text_link;
  final int liveClassID;
  var assignment;
  StudentsUploadedFilesInfo(
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
      this.liveClassID,
      this.assignment,
      this.image_List});
  @override
  _StudentsUploadedFilesInfoState createState() =>
      _StudentsUploadedFilesInfoState();
}

class _StudentsUploadedFilesInfoState extends State<StudentsUploadedFilesInfo> {
  http.BaseRequest request;
  String assignmentImagesUrl;
  bool imageClick = false;
  bool isAssignmet = false;
  bool showMarks = false;
  bool image = false;
  List<File> _imageList = [];
  List<String> _fileNameList = [];
  var singleImage;
  File singleImageFile;
  String imgUrl;
  String pdfUrl;
  String audioUrl;
  String imgFileName;
  String remarks;
  String marks;
  @override
  void initState() {
    super.initState();
    getImage();
    getAudio();
    getPDF();
    print('Assignment:${widget.assignment}');
    this.remarks = widget.assignment['remarks'];
    this.marks = widget.assignment['marks'];
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
                        // singleImageCamera(String selectedImage,1);
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
                    onTap: singleImageGallery,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> singleImageGallery() async {
    String extension = 'jpg';

    singleImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      singleImageFile = singleImage;
      _imageList.add(singleImageFile);
      this.imgFileName = "${DateTime.now().millisecondsSinceEpoch}.$extension";
      _fileNameList.add(this.imgFileName);
      // print(this.imgFileName);
    });
  }

  Future singleImageCamera() async {
    String extension = 'jpg';
    singleImage = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      singleImageFile = singleImage;
      _imageList.add(singleImageFile);
      this.imgFileName = "${DateTime.now().millisecondsSinceEpoch}.$extension";
      _fileNameList.add(this.imgFileName);
    });
  }

  void _galleryImageUpload() async {
    String extension = 'jpg';
    String folderName = "images";
    this.imgFileName = "${DateTime.now().millisecondsSinceEpoch}.$extension";

    print(this.imgFileName);
    for (var i = 0; i < _imageList.length; i++) {
      dospace.Bucket bucket1 = spaces.bucket('sghps');
      String etagal = await bucket1.uploadFile(
          folderName + '/' + _fileNameList[i].toString(),
          _imageList[i],
          'image/jpeg',
          dospace.Permissions.private);

      print('upload: $etagal');
      print('done');
    }
  }

  Future<void> _uploadAssignment() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    var _body = {
      'access_token': prefs.get('token'),
      'class_id': widget.classId,
      'section_id': widget.sectionId,
      'subject_id': widget.subjectId,
      'period_id': widget.periodId,
      'date': widget.dateT.toString(),
      'names': _fileNameList,
      'id': widget.liveClassID,
    };
    String url = 'http://sghps.cityschools.co/studentapi/upload_assignment';

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

  Widget _showAssignmentMarks() {
    print(widget.image_List.length);
    return Column(
      children: <Widget>[
        Text(
          'Uploaded Assignment ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(
          height: 12,
        ),
        GridView.builder(
          shrinkWrap: true,
          itemCount: widget.image_List.length,
          gridDelegate:
              new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
          itemBuilder: (BuildContext context, int i) {
            String endPoint =
                "https://sghps.ams3.digitaloceanspaces.com/images";
            request = http.Request("GET",
                Uri.parse('$endPoint/' + '${widget.image_List[i].image}'));

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
                String endPoint =
                    "https://sghps.ams3.digitaloceanspaces.com/images";
                request = http.Request("GET",
                    Uri.parse('$endPoint/' + '${widget.image_List[i].image}'));

                this.assignmentImagesUrl =
                    spaces.signRequest(request, preSignedUrl: true);

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
                          style:
                              TextStyle(color: Color.fromRGBO(33, 23, 47, 1)),
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
        Divider(),
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Remarks : ${this.remarks}',
                style: TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                'Marks : ${this.marks}',
                style: TextStyle(fontSize: 17),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
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
                          color: widget.video_link == null ||
                                  widget.video_link == ""
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
                                              itemCount:
                                                  widget.video_link.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int i) {
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
                                                            .video_link[i]
                                                            .link);
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
                                              Navigator.of(context)
                                                  .pop(context);
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
                    ],
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color:
                          widget.audio_link == null || widget.audio_link == ""
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
                                              'No Audio',
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
                                  ]  ),
                             
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
                      color:
                          widget.image_link == null || widget.image_link == ""
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
                                  widget.pdf_link == null ||
                                          widget.pdf_link == ""
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
                      color:
                          widget.assignment == "" || widget.assignment == null
                              ? Colors.red
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
                                  if (widget.assignment == null ||
                                      widget.assignment == "") {
                                    Toast.show(
                                        'Submit Your Assignment Here ', context,
                                        duration: Toast.LENGTH_LONG,
                                        gravity: Toast.BOTTOM);
                                    isAssignmet = true;
                                    showMarks = false;
                                  } else if (widget.assignment != null ||
                                      widget.assignment != "") {
                                    Toast.show('Your Assignment Marks', context,
                                        duration: Toast.LENGTH_LONG,
                                        gravity: Toast.BOTTOM);
                                    isAssignmet = false;
                                    showMarks = true;
                                    // for(var assi in widget.image_link)
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
                              // imageClick = true;
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
              isAssignmet
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Upload Assignment Files',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Divider(),
                          RaisedButton(
                            onPressed: () {
                              _singleImageDialogBox();
                              print('hii');
                            },
                            child: Text('Add Images'),
                          ),
                          _imageList.length == 0
                              ? Text('')
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                  ),
                                  child: Card(
                                    child: GridView.count(
                                      shrinkWrap: true,
                                      primary: false,
                                      crossAxisCount: 4,
                                      mainAxisSpacing: 5.0,
                                      crossAxisSpacing: 5.0,
                                      children: _imageList.map((File file) {
                                        setState(() {
                                          image = true;
                                        });

                                        return GestureDetector(
                                          onTap: () {},
                                          child: new GridTile(
                                            child: new Image.file(
                                              file,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    )
                  : Container(),
              showMarks ? _showAssignmentMarks() : Container(),
              image
                  ? Container(
                      width: 380,
                      child: RaisedButton(
                        color: Color.fromRGBO(33, 23, 47, 1),
                        textColor: Colors.white,
                        child: Text('Upload'),
                        onPressed: () {
                          print(_imageList.length);
                          print(_fileNameList);
                          _uploadAssignment();
                          _galleryImageUpload();
                        },
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
