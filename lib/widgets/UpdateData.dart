import 'dart:convert';
import 'dart:io';
import 'package:dospace/dospace.dart' as dospace;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:google_live/models/VideosModel.dart';
import 'package:google_live/widgets/Constant.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UpdateData extends StatefulWidget {
  final List<VideosModel> videoLink;
  final String textLink;
  final String liveClassLink;
  final String imageLink;
  final String pdfLink;
  final String audioLink;
  final DateTime dateT;
  final int classId;
  final int periodId;
  final int sectionId;
  final int subjectId;

  UpdateData(
      {this.videoLink,
      this.textLink,
      this.liveClassLink,
      this.imageLink,
      this.pdfLink,
      this.audioLink,
      this.dateT,
      this.classId,
      this.periodId,
      this.sectionId,
      this.subjectId});
  @override
  _UpdateDataState createState() => _UpdateDataState();
}

class _UpdateDataState extends State<UpdateData> {
  http.BaseRequest request;
  String audioPath;
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
  String imgUrl;
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
  var cards = <Card>[];

  void initState() {
    super.initState();
    getImage();
    widget.videoLink.forEach((f) {
      cards.add(createCard(f.title, f.link));
    });
    enterText.text = widget.textLink;
    liveClass.text = widget.liveClassLink;
    super.initState();
  }

  dospace.Spaces spaces = new dospace.Spaces(
    region: Constant.region,
    accessKey: Constant.accessKey,
    secretKey: Constant.secretKey,
  );

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

  getImage() {
    String endPoint = "https://sghps.ams3.digitaloceanspaces.com/images";
    request = http.Request("GET", Uri.parse('$endPoint/${widget.imageLink}'));
    this.imgUrl = spaces.signRequest(request, preSignedUrl: true);
    print(this.imgUrl);
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

  void _uploadImages() async {
    videoLinkTitle = [];
    _galleryImageUpload();
    _mp3Upload();
    _pdfUpload();

    for (int i = 0; i < _linkTitle.length; i++) {
      videoLinkTitle.add({
        'title': _linkTitle[i].text,
        'link': _link[i].text,
        'id': _linkID == null ? widget.videoLink[i].id : 0
      });
    }
    print(videoLinkTitle.length);
    print(videoLinkTitle);
    String _text = enterText.text;
    String _liveClass = liveClass.text;
    final prefs = await SharedPreferences.getInstance();
    String url = 'https://sghps.cityschools.co/studentapi/live_data_update';

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
      "image": this.imgFileName == null ? widget.imageLink : this.imgFileName,
      "pdf": this.pdfFileName == null ? widget.pdfLink : this.pdfFileName,
      "audio":
          this.audioFilename == null ? widget.audioLink : this.audioFilename,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
        title: Text('Update Data'),
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
              widget.imageLink == null || widget.imageLink == ""
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
                  widget.pdfLink == null || widget.pdfLink == ""
                      ? Text('No Pdf Selected')
                      : pdfFile == null
                          ? Text("${widget.pdfLink}")
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
                  widget.audioLink == null || widget.audioLink == ""
                      ? Text('No Audio Selected')
                      : audioFile == null
                          ? Text(" ${widget.audioLink}")
                          : Text(" $audioFile"),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: enterText,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(labelText: widget.textLink),
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
                    hintText: widget.liveClassLink,
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
                  _uploadImages();
                  setState(() {
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
      ),
    );
  }
}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  PDFScreen(this.pathPDF);

  @override
  Widget build(BuildContext context) {
    return PDFViewerScaffold(
        appBar: AppBar(
          title: Text("Document"),
        ),
        path: pathPDF);
  }
}
