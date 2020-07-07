import 'dart:convert';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:google_live/widgets/OnlineTeaching.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateData extends StatefulWidget {
  final String videoLink;
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
  final assetsAudioPlayer = AssetsAudioPlayer();
  String pathPDF = "";
  bool isPlaying;
  bool visible = false;
  var image;
  var singleImage;
  var audioFile;
  File audio;
  File imageFile;
  File singleImageFile;
  List<File> _imageList = [];
  File _video;
  List<String> _imageLists = new List();
  String imageDecoded;
  String audioDecoded;
  String singleImageDecoded;
  final enterText = TextEditingController();
  final videoLink = TextEditingController();
  final liveClass = TextEditingController();
  bool _play = false;

  void initState() {
    super.initState();

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

  Future getAudioGallery() async {
    audioFile = await FilePicker.getFile(type: FileType.audio);

    setState(() {
      audio = audioFile;
      final audiopath = audioFile.readAsBytesSync();
      this.audioDecoded = base64Encode(audiopath);
    });
  }

  void _uploadImages() async {
    String _text = enterText.text;
    String _videoLink = videoLink.text;
    String _liveClass = liveClass.text;
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/test_image?access_token=' +
            prefs.get('token');
    Map dataMap = {
      "solo_image": this.singleImageDecoded,
      "image": _imageLists.toString(),
      "audio": this.audioDecoded,
      "text": _text,
      "video_link": _videoLink,
      "live_class": _liveClass,
      "period_id": widget.periodId,
      "subject_id": widget.subjectId,
      "class_id": widget.classId,
      "section_id": widget.sectionId,
      "date": widget.dateT.toString()
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
    Map<String, dynamic> respond = jsonDecode(reply);
    // var error = respond['error'];
    // if (error == 'true') {
    //   print('updated');
    //   return showDialog(
    //     context: context,
    //     builder: (_) => AlertDialog(
    //       title: Text('Data Updated Successfully'),
    //       actions: <Widget>[
    //         new FlatButton(
    //           onPressed: () {
    //             Navigator.pushReplacement(
    //                         context,
    //                         MaterialPageRoute(
    //                           builder: (context) => OnlineTeaching(),
    //                         ),
    //                       );
    //           },
    //           child: Text('Close'),
    //         )
    //       ],
    //     ),
    //   );
    // }
    setState(() {
      visible = false;
    });
    httpClient.close();
    print(_imageList.length);
    return reply;
  }

  _openVideo() async {
    var video = widget.videoLink;
    var url = '$video';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _openLiveClass() async {
    var video = widget.liveClassLink;
    var url = '$video';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Future<Null> _load() async {
  //   final ByteData data = await rootBundle.load(widget.audioLink);
  //   String tempDir = (await getApplicationDocumentsDirectory()).path;
  //   File tempFile = File('$tempDir/${widget.audioLink}');
  //   await tempFile.writeAsBytes((await data.buffer.asUint8List()));
  //   final result = await advancedPlayer.play(tempFile.path, isLocal: true);
  //   // mp3Uri = tempFile.uri.toString();
  //   print('finished loading, uri=$result');
  // }

  Future<void> _playSound() async {
    try {
      await assetsAudioPlayer.open(
        Audio.network(
            "http://sghps.cityschools.co/uploads/online/audio/${widget.audioLink}"),
      );
    } catch (t) {}
  }

  Future<void> _pauseSound() async {
    try {
      await assetsAudioPlayer.pause();
    } catch (t) {}
  }

  Future<File> _openPDF() async {
    var url =
        'http://sghps.cityschools.co/uploads/online/pdf/${widget.pdfLink}';
    final filename = url.substring(url.lastIndexOf("/") + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = new File('$dir/$filename');
    await file.writeAsBytes(bytes);
    return file;
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
              Divider(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     Text(
              //       'Old Video Link',
              //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              //     ),
              //     SizedBox(
              //       width: 5,
              //     ),
              //     RaisedButton(
              //       color: Color.fromRGBO(33, 23, 47, 1),
              //       textColor: Colors.white,
              //       child: Text('Link'),
              //       onPressed: _openVideo,
              //     ),
              //   ],
              // ),
              // Divider(),
              Container(
                width: 340,
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  controller: videoLink,
                  autocorrect: true,
                  decoration: InputDecoration(
                    hintText: widget.videoLink == null || widget.videoLink == ""
                        ? "Enter New Video Link"
                        : widget.videoLink,
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              Divider(),
              Container(
                width: 340,
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  controller: enterText,
                  autocorrect: true,
                  decoration: InputDecoration(
                    hintText: widget.textLink == null || widget.textLink == ""
                        ? "Enter New Text"
                        : widget.textLink,
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              Divider(),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     Text(
              //       'Old Live Class Link',
              //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              //     ),
              //     SizedBox(
              //       width: 5,
              //     ),
              //     RaisedButton(
              //       color: Color.fromRGBO(33, 23, 47, 1),
              //       textColor: Colors.white,
              //       child: Text('Link'),
              //       onPressed: _openLiveClass,
              //     ),
              //   ],
              // ),
              // Divider(),
              Container(
                width: 340,
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  controller: liveClass,
                  autocorrect: true,
                  decoration: InputDecoration(
                    hintText: widget.liveClassLink == null ||
                            widget.liveClassLink == ""
                        ? "Enter New Live Class Link"
                        : widget.liveClassLink,
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              // widget.imageLink == null || widget.imageLink == ""
              //     ? Text('No image selected.')
                  // :
                   Container(
                      // height: 100,
                      // width: 100,
                      // decoration: BoxDecoration(
                      //   color: Colors.black,
                      // ),
                      child: Card(
                        child: singleImage == null
                            ? Text('No image selected.')
                            // GestureDetector(
                            //     child: Image.network(
                            //         'http://sghps.cityschools.co/uploads/online/images/${widget.imageLink}'),
                            //     onTap: () {
                            //       return showDialog(
                            //         context: context,
                            //         builder: (_) => AlertDialog(
                            //           content: Image.network(
                            //             ('http://sghps.cityschools.co/uploads/online/images/${widget.imageLink}'),
                            //             fit: BoxFit.fill,
                            //           ),
                            //           actions: <Widget>[
                            //             new FlatButton(
                            //               onPressed: () {
                            //                 Navigator.of(context).pop(context);
                            //               },
                            //               child: Text('Close'),
                            //             )
                            //           ],
                            //         ),
                            //       );
                            //     },
                            //   )
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
              RaisedButton(
                color: Color.fromRGBO(33, 23, 47, 1),
                textColor: Colors.white,
                child: Text('Choose Images'),
                onPressed: _singleImageDialogBox,
              ),
              Divider(),
              // widget.pdfLink == null || widget.pdfLink == ""
              //     ? Text('No Image Selected')
                   _imageList.length == 0
                      ? Text('No Image Selected')
                      : 
                      Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                          ),
                          child: _imageList.length == 0
                              ? 
                              Text('No Image Selected')
                              : Card(
                                  child: GridView.count(
                                    shrinkWrap: true,
                                    primary: false,
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 5.0,
                                    crossAxisSpacing: 5.0,
                                    children: _imageList.map((File file) {
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
              // RaisedButton(
              //   color: Color.fromRGBO(33, 23, 47, 1),
              //   textColor: Colors.white,
              //   child: Text('Open PDF'),
              //   onPressed: () {
              //     _openPDF().then((f) {
              //       setState(() {
              //         pathPDF = f.path;
              //         print(pathPDF);
              //       });
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => PDFScreen(pathPDF),
              //         ),
              //       );
              //     });
              //   },
              // ),
              // Divider(),
              RaisedButton(
                color: Color.fromRGBO(33, 23, 47, 1),
                textColor: Colors.white,
                child: Text('Choose PDF'),
                onPressed: _optionsDialogBox,
              ),
              Divider(),
              // Column(
              //   children: <Widget>[
              //     Text(
              //       'Old Audio Link:${widget.audioLink}',
              //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              //     ),
              //   ],
              // ),
              // SizedBox(
              //   width: 5,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     FloatingActionButton(
              //       backgroundColor: Color.fromRGBO(33, 23, 47, 1),
              //       onPressed: _playSound,
              //       tooltip: 'Play',
              //       child: const Icon(Icons.play_arrow),
              //       heroTag: 'btn1',
              //     ),
              //     SizedBox(
              //       width: 5,
              //     ),
              //     FloatingActionButton(
              //       backgroundColor: Color.fromRGBO(33, 23, 47, 1),
              //       onPressed: _pauseSound,
              //       tooltip: 'Play',
              //       child: const Icon(Icons.pause),
              //       heroTag: 'btn2',
              //     ),
              //   ],
              // ),
              // widget.audioLink == null || widget.audioLink == ""
              //     ? Text('No Audio Selected')
                  // :
                   audio == null
                       ?Text('No Audio Selected') //Text("Audio is Selected ${widget.audioLink}")
                      : Text("Audio is Selected $audio"),
              RaisedButton(
                color: Color.fromRGBO(33, 23, 47, 1),
                textColor: Colors.white,
                child: Text('Choose audio'),
                onPressed: getAudioGallery,
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
                  print(_imageLists.length);
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
