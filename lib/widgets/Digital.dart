import 'dart:io';
import 'package:google_live/widgets/Constant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:dospace/dospace.dart' as dospace;
import 'package:image_picker/image_picker.dart';

class DOSpacesFileUpload extends StatefulWidget {
  @override
  _DOSpacesFileUploadState createState() => _DOSpacesFileUploadState();
}

class _DOSpacesFileUploadState extends State<DOSpacesFileUpload> {
  http.BaseRequest request;
  String fileName;
  File singleImageFile;
  Map<String, dynamic> params = new Map<String, dynamic>();
  var singleImage;
  String uploadedFileUrl;
  String endPoint = "https://sghps.ams3.digitaloceanspaces.com";

  File file;
  List<Container> imgContainer = [];
  dospace.Spaces spaces = new dospace.Spaces(
    region: Constant.region,
    accessKey: Constant.accessKey,
    secretKey: Constant.secretKey,
  );

  Future singleImageGallery() async {
    singleImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      file = singleImage;

      print(file);
    });
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
                    // singleImage = await FilePicker.getFile(
                    //   type: FileType.audio,
                    //   allowedExtensions: [
                    //     'pdf',
                    //   ],
                    // );

                    // setState(() {
                    //   file = singleImage;

                    //   print(file);
                    // });

                    // change with your project's name
                    String projectName = "sghps";
                    // change with your project's region
                    String region = "ams3";
                    // change with your project's folder
                    String extension = 'jpg';
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
                        'image/jpeg',
                        dospace.Permissions.private);

                    print('upload: $etag');
                    print('done');
                  },
                )),
                RaisedButton(
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
                  child: Text('Get File'),
                  color: Colors.yellow,
                ),
                ...imgContainer
              ],
            ),
          ),
        ),
      ),
    );
  }
}
