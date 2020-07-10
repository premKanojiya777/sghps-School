import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:google_live/widgets/Constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:dospace/dospace.dart' as dospace;
import 'package:url_launcher/url_launcher.dart';

class DOSpacesFileUpload extends StatefulWidget {
  @override
  _DOSpacesFileUploadState createState() => _DOSpacesFileUploadState();
}

class _DOSpacesFileUploadState extends State<DOSpacesFileUpload> {
  http.BaseRequest request;
  String pathPDF = "";
  String fileName;
  File singleImageFile;
  Map<String, dynamic> params = new Map<String, dynamic>();
  var singleImage;
  String uploadedFileUrl;
  String pdfUrl;
  String endPoint = "https://sghps.ams3.digitaloceanspaces.com/prem";

  File file;
  List<Container> imgContainer = [];
  List pdfContainer = [];
  List mp3Container = [];
  dospace.Spaces spaces = new dospace.Spaces(
    region: Constant.region,
    accessKey: Constant.accessKey,
    secretKey: Constant.secretKey,
  );

  Future singleImageGallery() async {
    // singleImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    singleImage = await FilePicker.getFile(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
      ],
    );
    setState(() {
      file = singleImage;

      print(file);
    });
  }

  void initState() {
    super.initState();
    // _pdfFile();
    // _mp3File();
  }

  Future<void> _mp3File() async {
    mp3Container = [];
    for (String name in await spaces.listAllBuckets()) {
      print('bucket: $name');
      dospace.Bucket bucket = spaces.bucket(name);

      await for (dospace.BucketContent content
          in bucket.listContents(maxKeys: 1)) {
        setState(() {
          if ('${content.key}'.contains("mp3")) {
            request =
                http.Request("GET", Uri.parse('$endPoint/${content.key}'));
            String mp3Url = spaces.signRequest(request, preSignedUrl: true);

            mp3Container.add(mp3Url);
            print('mp3Container::  ${mp3Container.length}');
          }
        });
      }
    }
  }

  Future<void> _pdfFile() async {
    pdfContainer = [];
    for (String name in await spaces.listAllBuckets()) {
      print('bucket: $name');
      dospace.Bucket bucket = spaces.bucket(name);

      await for (dospace.BucketContent content
          in bucket.listContents(maxKeys: 1)) {
        setState(() {
          if ('${content.key}'.contains("pdf")) {
            request =
                http.Request("GET", Uri.parse('$endPoint/${content.key}'));
            this.pdfUrl = spaces.signRequest(request, preSignedUrl: true);

            pdfContainer.add(pdfUrl);
            print('pdfContainer::  ${pdfContainer.length}');
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: <Widget>[
                RaisedButton(
                  onPressed: singleImageGallery,
                  child: Text('take image'),
                ),
                Center(
                    child: RaisedButton(
                  child: Text('Upload File to DO Spaces'),
                  onPressed: () async {
                    String projectName = "sghps";

                    String region = "ams3";

                    String extension = 'pdf';
                    String folderName = "prem";
                    fileName =
                        "${DateTime.now().millisecondsSinceEpoch}.$extension";

                    print(fileName);
                    uploadedFileUrl = "https://" +
                        projectName +
                        "." +
                        region +
                        ".digitaloceanspaces.com/" +
                        folderName +
                        "/" +
                        fileName;
                    print('url: $uploadedFileUrl');
                    dospace.Bucket bucket = spaces.bucket('sghps');
                    // bucket.signRequest(request);
                    String etag = await bucket.uploadFile(
                        folderName + '/' + fileName,
                        singleImage,
                        'application/pdf',
                        dospace.Permissions.private);

                    print('upload: $etag');
                    print('done');
                  },
                )),
                Container(
                  // padding: EdgeInsets.all(15),
                  child: RaisedButton(
                    onPressed: () async {
                      for (String name in await spaces.listAllBuckets()) {
                        print('bucket: $name');
                        dospace.Bucket bucket = spaces.bucket(name);

                        await for (dospace.BucketContent content
                            in bucket.listContents(maxKeys: 1)) {
                          if ('${content.key}'.contains("jpg")) {
                            request = http.Request(
                                "GET", Uri.parse('$endPoint/${content.key}'));
                            String sighenUrl =
                                spaces.signRequest(request, preSignedUrl: true);
                            print(sighenUrl);
                            setState(() {
                              imgContainer.add(Container(
                                height: 100,
                                width: 100,
                                child: Image.network(sighenUrl),
                              ));
                            });
                          }
                        }
                      }
                    },
                    child: Text('Images File'),
                    color: Colors.yellow,
                  ),
                ),
                ...imgContainer,
                RaisedButton(
                  onPressed: () async {
                    print('$endPoint/1594362675038.pdf');
                    request =
                        http.Request("GET", Uri.parse('$endPoint/1594362675038.pdf'));
                    this.pdfUrl =
                        spaces.signRequest(request, preSignedUrl: true);
                    print(this.pdfUrl);
                    var url = this.pdfUrl;
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Text('PDF File'),
                  color: Colors.yellow,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(1),
                      itemCount: pdfContainer.length,
                      itemBuilder: (BuildContext context, int i) {
                        return RaisedButton(
                          onPressed: () async {
                            print(pdfContainer[i]);
                            var url = pdfContainer[i];
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: Text('Single Pdf File:$i'),
                        );
                      }),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(1),
                      itemCount: mp3Container.length,
                      itemBuilder: (BuildContext context, int i) {
                        return RaisedButton(
                          onPressed: () async {
                            print(mp3Container[i]);
                            var url = mp3Container[i];
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: Text('Single Mp3 File:$i'),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
