import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/full_pdf_viewer_scaffold.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewUploadedData extends StatefulWidget {
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

  ViewUploadedData(
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
  _ViewUploadedDataState createState() => _ViewUploadedDataState();
}

class _ViewUploadedDataState extends State<ViewUploadedData> {
  
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

  // Future<void> _optionsDialogBox() {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           content: new SingleChildScrollView(
  //             child: new ListBody(
  //               children: <Widget>[
  //                 GestureDetector(
  //                   child: Row(
  //                     children: <Widget>[
  //                       new Icon(Icons.photo_camera),
  //                       Padding(
  //                         padding: EdgeInsets.only(left: 3),
  //                       ),
  //                       new Text('Take a picture',
  //                           style: TextStyle(color: Colors.redAccent)),
  //                     ],
  //                   ),
  //                   onTap: openCamera,
  //                 ),
  //                 Divider(),
  //                 Padding(
  //                   padding: EdgeInsets.all(8.0),
  //                 ),
  //                 GestureDetector(
  //                   child: Row(
  //                     children: <Widget>[
  //                       new Icon(Icons.photo_album),
  //                       Padding(
  //                         padding: EdgeInsets.only(left: 3),
  //                       ),
  //                       new Text(
  //                         'Select from gallery',
  //                         style: TextStyle(color: Colors.redAccent),
  //                       ),
  //                     ],
  //                   ),
  //                   onTap: openGallery,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

  // Future<void> _singleImageDialogBox() {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           content: new SingleChildScrollView(
  //             child: new ListBody(
  //               children: <Widget>[
  //                 GestureDetector(
  //                   child: Row(
  //                     children: <Widget>[
  //                       new Icon(Icons.photo_camera),
  //                       Padding(
  //                         padding: EdgeInsets.only(left: 3),
  //                       ),
  //                       new Text('Take a picture',
  //                           style: TextStyle(color: Colors.redAccent)),
  //                     ],
  //                   ),
  //                   onTap: singleImageCamera,
  //                 ),
  //                 Divider(),
  //                 Padding(
  //                   padding: EdgeInsets.all(8.0),
  //                 ),
  //                 GestureDetector(
  //                   child: Row(
  //                     children: <Widget>[
  //                       new Icon(Icons.photo_album),
  //                       Padding(
  //                         padding: EdgeInsets.only(left: 3),
  //                       ),
  //                       new Text(
  //                         'Select from gallery',
  //                         style: TextStyle(color: Colors.redAccent),
  //                       ),
  //                     ],
  //                   ),
  //                   onTap: singleImageGallery,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

  // Future singleImageGallery() async {
  //   singleImage = await ImagePicker.pickImage(source: ImageSource.gallery);

  //   setState(() {
  //     singleImageFile = singleImage;
  //     final path = singleImageFile.readAsBytesSync();
  //     this.singleImageDecoded = base64Encode(path);
  //   });
  // }

  // Future singleImageCamera() async {
  //   singleImage = await ImagePicker.pickImage(source: ImageSource.camera);

  //   setState(() {
  //     singleImageFile = singleImage;
  //     final path = singleImageFile.readAsBytesSync();
  //     this.singleImageDecoded = base64Encode(path);
  //   });
  // }

  // Future openGallery() async {
  //   image = await ImagePicker.pickImage(source: ImageSource.gallery);

  //   setState(() {
  //     imageFile = image;
  //     final path = imageFile.readAsBytesSync();
  //     this.imageDecoded = base64Encode(path);
  //     _imageLists.add(this.imageDecoded);
  //     _imageList.add(imageFile);
  //     // print(imageFile);
  //   });
  // }

  // Future openCamera() async {
  //   image = await ImagePicker.pickImage(source: ImageSource.camera);

  //   setState(() {
  //     imageFile = image;
  //     final path = imageFile.readAsBytesSync();
  //     this.imageDecoded = base64Encode(path);
  //     _imageLists.add(this.imageDecoded);
  //     _imageList.add(imageFile);
  //     // print(imageFile);
  //   });
  // }

  // Future getAudioGallery() async {
  //   audioFile = await FilePicker.getFile(type: FileType.audio);

  //   setState(() {
  //     audio = audioFile;
  //     final audiopath = audioFile.readAsBytesSync();
  //     this.audioDecoded = base64Encode(audiopath);
  //   });
  // }

 

  _openMap() async {
    var video = widget.videoLink;
    var url = '$video';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
        title: Text('View Uploded Data'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Card(
              margin: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Video Link',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      RaisedButton(
                        color: Color.fromRGBO(33, 23, 47, 1),
                        textColor: Colors.white,
                        child: Text('Link'),
                        onPressed: _openMap,
                      ),
                    ],
                  ),
                 
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Live Class Link',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      RaisedButton(
                        color: Color.fromRGBO(33, 23, 47, 1),
                        textColor: Colors.white,
                        child: Text('Link'),
                        onPressed: _openMap,
                      ),
                    ],
                  ),
                  Divider(),
                  
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
                                    child: Image.network(
                                        'http://sghps.cityschools.co/uploads/online/images/${widget.imageLink}'),
                                    onTap: () {
                                      return showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          content: Image.network(
                                            ('http://sghps.cityschools.co/uploads/online/images/${widget.imageLink}'),
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
                  widget.pdfLink == null || widget.pdfLink == ""
                      ? Text('No Image Selected')
                      : _imageList.length == 0
                          ? Text(widget.pdfLink)
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                              ),
                              child: _imageList.length == 0
                                  ? Text(widget.pdfLink)
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
                  RaisedButton(
                    color: Color.fromRGBO(33, 23, 47, 1),
                    textColor: Colors.white,
                    child: Text('Open PDF'),
                    onPressed: (){
                       _openPDF()
                                .then((f) {
                              setState(() {
                                pathPDF = f.path;
                                print(pathPDF);
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFScreen(pathPDF),
                                ),
                              );
                            });
                    },
                  ),
                  Divider(),
               
                  Column(
                    children: <Widget>[
                      Text(
                        'Old Audio Link:${widget.audioLink}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FloatingActionButton(
                        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
                        onPressed: null,
                        tooltip: 'Play',
                        child: const Icon(Icons.play_arrow),
                        heroTag: 'btn1',
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      FloatingActionButton(
                        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
                        onPressed: null,
                        tooltip: 'Play',
                        child: const Icon(Icons.pause),
                        heroTag: 'btn2',
                      ),
                    ],
                  ),
            
                 
                ],
              ),
            ),
            // RaisedButton(
            //   child: Text("Finish",style: TextStyle(color: Colors.white),),
            //   color: Color.fromRGBO(33, 23, 47, 1),
            //   onPressed: (){
            //    Navigator.pushReplacement(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) => OnlineTeaching(),
            //                 ),
            //               );
                          
            // })
          ],
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
