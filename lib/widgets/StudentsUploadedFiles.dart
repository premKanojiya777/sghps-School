import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:google_live/models/SubmitAssignment.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class StudentsUploadedFilesInfo extends StatefulWidget {
  final DateTime dateT;
  final int classId;
  final int periodId;
  final int sectionId;
  final int subjectId;
  final String video_link;
  final String audio_link;
  final String image_link;
  final String pdf_link;
  final String live_class_link;
  final String text_link;
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
      this.live_class_link});
  @override
  _StudentsUploadedFilesInfoState createState() =>
      _StudentsUploadedFilesInfoState();
}

class _StudentsUploadedFilesInfoState extends State<StudentsUploadedFilesInfo> {
  final assetsAudioPlayer = AssetsAudioPlayer();
  String pathPDF = "";
  @override
  void initState() {
    super.initState();
    super.initState();
  }

  _openVideo() async {
    var video = widget.video_link;
    var url = '$video';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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

  Future<void> _playSound() async {
    try {
      await assetsAudioPlayer.open(
        Audio.network(
            "http://sghps.cityschools.co/uploads/online/audio/${widget.audio_link}"),
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
        'http://sghps.cityschools.co/uploads/online/pdf/${widget.pdf_link}';
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
        title: Text('Uploaded Files Info'),
        centerTitle: true,
      ),
      body: Center(
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
                                onTap: _openVideo,
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
                            onTap: () {}, // button pressed
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
                                    : Row(
                                        children: <Widget>[
                                          Container(
                                            height: 40,
                                            width: 40,
                                            child: FloatingActionButton(
                                              backgroundColor:
                                                  Color.fromRGBO(33, 23, 47, 1),
                                              onPressed: _playSound,
                                              tooltip: 'Play',
                                              child: Icon(Icons.play_arrow),
                                              heroTag: 'btn1',
                                            ),
                                          ),
                                          SizedBox(
                                            width: 3,
                                          ),
                                          Container(
                                            height: 40,
                                            width: 40,
                                            child: FloatingActionButton(
                                              backgroundColor:
                                                  Color.fromRGBO(33, 23, 47, 1),
                                              onPressed: _pauseSound,
                                              tooltip: 'Play',
                                              child: Icon(Icons.pause),
                                              heroTag: 'btn2',
                                            ),
                                          ),
                                        ],
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
                            onTap: () {}, // button pressed

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                widget.image_link != null
                                    ? Container(
                                        width: 90,
                                        height: 90,
                                        child: GestureDetector(
                                          child: Image.network(
                                              'http://sghps.cityschools.co/uploads/online/images/${widget.image_link}'),
                                          onTap: () {
                                            return showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                content: Image.network(
                                                  ('http://sghps.cityschools.co/uploads/online/images/${widget.image_link}'),
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
                                        ),
                                      )
                                    : Text(
                                        'Image Content',
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
                            onTap: () {
                              _openPDF().then((f) {
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
                            }, // button pressed

                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                widget.pdf_link == null || widget.pdf_link == ""
                                    ? Text(
                                        'PDF EBook',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(widget.pdf_link)
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SubmitAssignment(
                                          periodIID: widget.periodId,
                                          sectionIID: widget.sectionId,
                                          subjectIID: widget.subjectId,
                                          classIID: widget.classId,
                                          dateTIME: widget.dateT,
                                        )),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Submit Assignment',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
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
            )
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
