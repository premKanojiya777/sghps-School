import 'package:http/http.dart' as http;
import 'package:dospace/dospace.dart' as dospace;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:google_live/widgets/Constant.dart';
import 'package:google_live/widgets/UpdateData.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadedFilesInfo extends StatefulWidget {
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
      this.live_class_link});
  @override
  _UploadedFilesInfoState createState() => _UploadedFilesInfoState();
}

class _UploadedFilesInfoState extends State<UploadedFilesInfo> {
  final assetsAudioPlayer = AssetsAudioPlayer();
  http.BaseRequest request;

  String pathPDF = "";
  String imgUrl;
  String pdfUrl;
  String audioUrl;
  @override
  void initState() {
    super.initState();
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

  _openVideo() async {
    var video = widget.video_link;
    var url = '$video';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

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
                                              onPressed: () async {
                                                var url = this.audioUrl;
                                                if (await canLaunch(url)) {
                                                  await launch(url);
                                                } else {
                                                  throw 'Could not launch $url';
                                                }
                                              },
                                              tooltip: 'Play',
                                              child: Icon(Icons.play_arrow),
                                              heroTag: 'btn1',
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
            Spacer(),
            RaisedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdateData(
                            videoLink: widget.video_link,
                            textLink: widget.text_link,
                            liveClassLink: widget.live_class_link,
                            imageLink: widget.image_link,
                            pdfLink: widget.pdf_link,
                            audioLink: widget.audio_link,
                            dateT: widget.dateT,
                            periodId: widget.periodId,
                            sectionId: widget.sectionId,
                            subjectId: widget.subjectId,
                            classId: widget.classId,
                          )),
                );
                print(widget.pdf_link);
              },
              color: Color.fromRGBO(33, 23, 47, 1),
              shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(18.0),
              ),
              child: Text(
                'Update Data',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              height: 200,
            ),
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
