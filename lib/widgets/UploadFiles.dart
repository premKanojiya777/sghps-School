import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/widgets/Constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dospace/dospace.dart' as dospace;
import 'package:uuid/uuid.dart';

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
  bool visible = false;
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
  List<String> _imageLists = new List();
  List videoLinkTitle = [];
  String imageDecoded;
  String audioDecoded;
  String singleImageDecoded;
  final enterText = TextEditingController();
  final videoLink = TextEditingController();
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
          // Text('Person ${cards.length + 1}'),
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

  Future<void> _optionsDialogBox() {
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
                    onTap: openCamera,
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
                    onTap: openGallery,
                  ),
                ],
              ),
            ),
          );
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
                    onTap: () async{
                      // singleImageCamera(String selectedImage,1);
                    } 
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

  Future<void> singleImageGallery() async {
    String extension = 'jpg';
    int number;
    singleImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      singleImageFile = singleImage;
    });
    // change with your project's name
    String projectName = "sghps";
    // change with your project's region
    String region = "ams3";
    // change with your project's folder
    String folderName = "prem";
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.$extension";
    //  Uuid().v4() + '.jpg'; //singleImage.path.split('/').last;

    print(fileName);
    String uploadedFileUrl = "https://" +
        projectName +
        "." +
        region +
        ".digitaloceanspaces.com/" +
        folderName +
        "/" +
        fileName.toString();
    print('url: $uploadedFileUrl');
    dospace.Bucket bucket1 = spaces.bucket('sghps');
    String etagal = await bucket1.uploadFile(
        folderName + '/' + fileName.toString(),
        singleImage,
        'image/jpeg',
        dospace.Permissions.private);

    print('upload: $etagal');
    print('done');

   

    // final path = singleImageFile.readAsBytesSync();
    // this.singleImageDecoded = base64Encode(path);
  }

  Future singleImageCamera() async {
    String extension = 'jpg';
    int number;
    singleImage = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      singleImageFile = singleImage;
    });
    // change with your project's name
    String projectName = "sghps";
    // change with your project's region
    String region = "ams3";
    // change with your project's folder
    String folderName = "prem";
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.$extension";
    // Uuid().v4() + '.jpg'; //singleImage.path.split('/').last;

    print(fileName);
    String uploadedFileUrl = "https://" +
        projectName +
        "." +
        region +
        ".digitaloceanspaces.com/" +
        folderName +
        "/" +
        fileName.toString();
    print('url: $uploadedFileUrl');
    dospace.Bucket bucketcam = spaces.bucket('sghps');
    String etagcam = await bucketcam.uploadFile(
        folderName + '/' + fileName.toString(),
        singleImage,
        'image/jpeg',
        dospace.Permissions.private);

    print('upload: $etagcam');
    print('done');

    

    // final path = singleImageFile.readAsBytesSync();
    // this.singleImageDecoded = base64Encode(path);
  }

  Future openGallery() async {
    image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      imageFile = image;
      final path = imageFile.readAsBytesSync();
      this.imageDecoded = base64Encode(path);
      _imageLists.add(this.imageDecoded);
      _imageList.add(imageFile);
      // print(imageFile);
    });
  }

  Future openCamera() async {
    image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      imageFile = image;
      final path = imageFile.readAsBytesSync();
      this.imageDecoded = base64Encode(path);
      _imageLists.add(this.imageDecoded);
      _imageList.add(imageFile);
      // print(imageFile);
    });
  }

  // Future getAudioGallery() async {
  //   audioFile = await FilePicker.getFile(type: FileType.audio);

  //   setState(() {
  //     audio = audioFile;
  //     final audiopath = audioFile.readAsBytesSync();
  //     this.audioDecoded = base64Encode(audiopath);
  //   });
  // }

  void _uploadImages() async {
    //   String _text = enterText.text;
    //   List videoLinkTitle = [];
    //   for (int i = 0; i < _linkTitle.length; i++) {
    //     videoLinkTitle.add({
    //       'title': _linkTitle[i].text,
    //       'link': _link[i].text,
    //     });
    //   }

    //   print(videoLinkTitle);
    //   String _liveClass = liveClass.text;
    //   final prefs = await SharedPreferences.getInstance();
    //   String url =
    //       'http://sghps.cityschools.co/studentapi/test_image?access_token=' +
    //           prefs.get('token');
    //   Map dataMap = {
    //     "text": _text,
    //     "video_link": videoLinkTitle,
    //     "live_class": _liveClass,
    //     "period_id": widget.periodId,
    //     "subject_id": widget.subjectId,
    //     "class_id": widget.classId,
    //     "section_id": widget.sectionId,
    //     "date": widget.dateT.toString(),
    //     "solo_image": this.singleImageDecoded,
    //     "image": _imageLists.toString(),
    //     "audio": this.audioDecoded,
    //   };

    //   print(await apiRequest(url, dataMap));
    // }

    // Future<String> apiRequest(String url, Map dataMap) async {
    //   String jsonString = json.encode(dataMap);
    //   HttpClient httpClient = new HttpClient();
    //   HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    //   request.headers.contentType =
    //       new ContentType("application", "json", charset: "utf-8");
    //   request.headers.set('Content-Length', jsonString.length.toString());
    //   request.write(jsonString);
    //   print(jsonString);
    //   HttpClientResponse response = await request.close();
    //   String reply = await response.transform(utf8.decoder).join();
    //   setState(() {
    //     visible = false;
    //   });
    //   httpClient.close();

    //   print(_imageList.length);
    //   return reply;
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
                              pdfFile = await FilePicker.getFile(
                                type: FileType.custom,
                                allowedExtensions: [
                                  'pdf',
                                ],
                              );

                              setState(() {
                                pdfFiles = pdfFile;

                                print(pdfFiles);
                              });
                              // change with your project's name
                              String projectName = "sghps";
                              // change with your project's region
                              String region = "ams3";
                              // change with your project's folder
                               String extension = 'pdf';
                              String folderName = "prem";
                              String fileName = "${DateTime.now().millisecondsSinceEpoch}.$extension";
                              this.pdfPath = pdfFile.path.split('/').last;

                              print(fileName);
                              String uploadedFileUrl = "https://" +
                                  projectName +
                                  "." +
                                  region +
                                  ".digitaloceanspaces.com/" +
                                  folderName +
                                  "/" +
                                  fileName.toString();
                              print('url: $uploadedFileUrl');
                              dospace.Bucket bucketpdf = spaces.bucket('sghps');
                              String etagpdf = await bucketpdf.uploadFile(
                                  folderName + '/' + fileName.toString(),
                                  pdfFile,
                                  'application/pdf',
                                  dospace.Permissions.private);

                              print('upload: $etagpdf');
                              print('done');

                              
                            }),
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

                                print(audioFile);
                              });
                              // change with your project's name
                              String projectName = "sghps";
                              // change with your project's region
                              String region = "ams3";
                              // change with your project's folder
                               String extension = 'mp3';
                              String folderName = "prem";
                              String fileName = "${DateTime.now().millisecondsSinceEpoch}.$extension";
                              this.audioPath = audioFile.path.split('/').last;

                              print(fileName);
                              String uploadedFileUrl = "https://" +
                                  projectName +
                                  "." +
                                  region +
                                  ".digitaloceanspaces.com/" +
                                  folderName +
                                  "/" +
                                  fileName.toString();
                              print('url: $uploadedFileUrl');
                              dospace.Bucket bucketmp3 = spaces.bucket('sghps');
                              String etagmp3 = await bucketmp3.uploadFile(
                                  folderName + '/' + fileName.toString(),
                                  audioFile,
                                  'audio/mpeg',
                                  dospace.Permissions.private);

                              print('upload: $etagmp3');
                              print('done');

                             
                            }),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: audioFile == null ? Text('') : Text(audioPath),
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
                    // border: new OutlineInputBorder(
                    //   borderRadius: new BorderRadius.circular(10.0),
                    // ),
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
                    _uploadImages();
                    setState(() {
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

// class PersonEntry {
//   final String title;
//   final String link;

//   PersonEntry(this.title, this.link);
//   @override
//   String toString() {
//     return 'Person: title= $title, link= $link';
//   }
// }
