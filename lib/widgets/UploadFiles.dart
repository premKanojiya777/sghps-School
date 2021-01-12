import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/widgets/Constant.dart';
import 'package:google_live/widgets/ShowSubjects.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dospace/dospace.dart' as dospace;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class UploadFiles extends StatefulWidget {
  final DateTime dateT;
  final int classId;
  final int periodId;
  final int sectionId;
  final int subjectId;
  UploadFiles(
      {this.dateT,
      this.periodId,
      this.classId,
      this.sectionId,
      this.subjectId});
  @override
  _UploadFilesState createState() => _UploadFilesState();
}

class _UploadFilesState extends State<UploadFiles> {
  String imgFileName;
  String pdfFileName;
  String audioFilename;
  bool visible = false;
  bool audioDone = false;
  bool pdfDone = false;
  bool imageDone = false;
  var image;
  String pdfPath;
  String audioPath;
  var audioFile;
  var pdfFile;
  File pdfFiles;
  File audio;
  File imageFile;
  File singleImageFile;
  var singleImage;
  List<File> _imageList = [];
  List videoLinkTitle = [];
  String imageDecoded;
  String audioDecoded;
  String singleImageDecoded;
  final enterText = TextEditingController();
  final liveClass = TextEditingController();
  List<TextEditingController> _linkTitle = new List();
  List<TextEditingController> _link = new List();
  var cards = <Card>[];

  Card createCard() {
    var titleController = TextEditingController();
    var linkController = TextEditingController();

    _linkTitle.add(titleController);
    _link.add(linkController);

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: titleController,
            style: TextStyle(color: Colors.blue),
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
              controller: linkController,
              decoration: InputDecoration(labelText: 'Link')),
        ],
      ),
    );
  }

  dospace.Spaces spaces = new dospace.Spaces(
    region: Constant.region,
    accessKey: Constant.accessKey,
    secretKey: Constant.secretKey,
  );

  void initState() {
    super.initState();
    cards.add(createCard());
    super.initState();
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
    imageDone = true;
    String extension = 'jpg';

    singleImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      singleImageFile = singleImage;
    });
  }

  Future singleImageCamera() async {
    imageDone = true;

    singleImage = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      singleImageFile = singleImage;
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
    // setState(() {
    //   if (etagmp3 == null) {
    //     Toast.show('Error Uploading File', context,
    //         duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    //     audioDone = false;
    //   } else {
    //     audioDone = false;
    //   }
    // });

    print('upload: $etagmp3');
    print('done');
  }

  void _uploadFiles() async {
   singleImage == null ? print('noImage') :  _galleryImageUpload();
   audioFile == null ? print('noAudio') : _mp3Upload();
   pdfFile == null ? print('noPDF') : _pdfUpload();
    String _text = enterText.text;
    List videoLinkTitle = [];
    for (int i = 0; i < _linkTitle.length; i++) {
      videoLinkTitle.add({
        'title': _linkTitle[i].text,
        'link': _link[i].text,
      });
    }

    print(videoLinkTitle);
    String _liveClass = liveClass.text;
    final prefs = await SharedPreferences.getInstance();
    String url = 'http://sghps.cityschools.co/studentapi/live_data_upload';

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
      "image": this.imgFileName,
      "pdf": this.pdfFileName,
      "audio": this.audioFilename,
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

    print(_imageList.length);
    return reply;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
        title: Text('Upload Files'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Video Details',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    IconButton(
                        icon: Icon(Icons.add, color: Colors.blue),
                        onPressed: () =>
                            setState(() => cards.add(createCard()))),
                    IconButton(
                        icon: Icon(Icons.remove, color: Colors.blue),
                        onPressed: () => setState(() {
                              cards.removeAt(0);
                            })),
                  ],
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: cards.length,
                itemBuilder: (BuildContext context, int index) {
                  return cards[index];
                },
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      'Single Image',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              singleImage == null
                  ? Text('')
                  : Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.black,
                      ),
                      child: Card(
                        child: Image.file(singleImage),
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
                            pdfDone = true;
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: pdfFile == null ? Text('') : Text('$pdfFile'),
                  ),
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
                        Visibility(
                          visible: audioDone,
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Uploading Please Wait....",
                                style: TextStyle(color: Colors.blueAccent),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: audioFile == null
                        ? Text('')
                        : Text('${this.audioPath}'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: enterText,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(labelText: 'Text'),
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
                    hintText: "Live Class Link",
                    fillColor: Colors.white,
                  ),
                ),
              ),
              Divider(),
              Container(
                width: 340,
                child: RaisedButton(
                  color: Color.fromRGBO(33, 23, 47, 1),
                  textColor: Colors.white,
                  child: Text('Upload Files'),
                  onPressed: () {
                    _uploadFiles();
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
                      style: TextStyle(color: Colors.blueAccent),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
