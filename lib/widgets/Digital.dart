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
  http.Client _httpClient = http.Client();
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

  // AwsS3 awsS3 = AwsS3(

  //         region: Regions.AP_NORTHEAST_1,
  //         bucketName: 'sghps');

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
                           print({"xmlDAtaaaaaaaa":"xml.toString()"});
                            // print('key:$endPoint/${content.key}');
                            bucket.signRequest(request);
                             spaces.getUri(Uri(host: 'https://sghps.ams3.digitaloceanspaces.com', path:content.key)).then((xml){
                           print({"xmlDAtaaaaaaaa":xml.toString()});

                            }).catchError((onError){
                           print({"xmlDAtaaaaaaaa":"errrrrr"});

                              print(onError);
                            });
                            if ('${content.key}'.contains("jpg")) {
                              int i = 5;
                              if (i < 2) {
                                i--;
                                print("hiiiiiiiiii");
                           


                              }
                
                              // dospace
                              // const url = s3.getSignedUrl('getObject', {
                              //   Bucket: 'example-space-name',
                              //   Key: 'file.ext',
                              //   Expires: expireSeconds
                              // });
                              imgContainer.add(Container(
                                height: 100,
                                width: 100,
                                child: Image.network('$endPoint/${content.key}'),
                              ));
                            }
                          }
                        }
                    // String spacesEndpoint =
                    //     "https://ams3.digitaloceanspaces.com";
                    // new Bucket(
                    //   region: "ams3",
                    //   accessKey: 'NEL6K7I7SHBNSOH343CF',
                    //   secretKey: 'orJ7QCymCWnjpwYeZeqHeO9EOjTBBVInRxDEwgOPWnU',
                    //   endpointUrl: "https://sghps.am3.digitaloceanspaces.com",
                    //   httpClient: httpClient,
                    // );

                    // const expireSeconds = 60 * 5;

                    // var url = spaces.signRequest(request);
                    // print('url:$url');
                  
                    // var url = this.s3.getSignedUrl('getObject', {
                    //   Bucket: 'sghps',
                    //   Key: "audio/" + audio,
                    //   Expires: expireSeconds
                    // });
                    // window.open(url, '_system');

                    // var url = new AwsS3(
                    //     file: singleImage,
                    //     fileNameWithExt: fileName,
                    //     awsFolderPath: singleImage.path.split('/').last,
                    //     poolId: null,
                    //     bucketName: 'sghps');

                    // const spacesEndpoint =
                    //     const aws.Endpoint('ams3.digitaloceanspaces.com');
                    // this.s3 = new aws.S3({
                    //   endpoint: 'ams3.digitaloceanspaces.com',
                    //   accessKeyId: 'NEL6K7I7SHBNSOH343CF',
                    //   secretAccessKey:
                    //       'orJ7QCymCWnjpwYeZeqHeO9EOjTBBVInRxDEwgOPWnU'
                    // });
                  },
                  child: Text('Get File'),
                  color: Colors.yellow,
                ),
                ...imgContainer
                // Container(
                //     height: 100,
                //     width: 100,
                //     child: Image.network(
                //         'https://sghps.ams3.digitaloceanspaces.com/prem/4f762e87-1058-4c5d-822a-83725daf7129.jpg'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
