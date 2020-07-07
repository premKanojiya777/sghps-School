import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_live/models/ImageGalleryModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ImageGallery extends StatefulWidget {
  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  ImageGalleryModel imageGalleryModel;
  Future<List<ImageGalleryModel>> imagelist;
  var image;

  @override
  void initState() {
    super.initState();
    imagelist = _getImageGallery();
  }

  Future<List<ImageGalleryModel>> _getImageGallery() async {
    List<ImageGalleryModel> imagelist = [];
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/studentgallery?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Content-Type": "application/json"}).then((res) {
      //print({"res", res.body});
      Map<String, dynamic> imageDecode = jsonDecode(res.body);
      for (var a in imageDecode['select']) {
        ImageGalleryModel imag =
            ImageGalleryModel(a["id"], a["class_id"], a["image"]);

        imagelist.add(imag);
      }
      print(imagelist.length);
    }).catchError((onError) {
      print(onError);
    });
    return imagelist;
  }

  var bodyProgress = new Container(
    child: new Stack(
      children: <Widget>[
        new Container(
          alignment: AlignmentDirectional.center,
          decoration: new BoxDecoration(
            color: Colors.white70,
          ),
          child:  new Container(
            decoration: new BoxDecoration(
                color: Colors.grey,
                borderRadius: new BorderRadius.circular(10.0)),
            width: 140,
            height: 120,
            alignment: AlignmentDirectional.center,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Center(
                  child: new SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: new CircularProgressIndicator(
                      value: null,
                      strokeWidth: 7.0,
                    ),
                  ),
                ),
                new Container(
                  margin: const EdgeInsets.only(top: 25.0),
                  child: new Center(
                    child: new Text(
                      "loading.. wait...",
                      style: new TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(33, 23, 47, 1),
        title: Text('Student Image Gallery'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _getImageGallery();
          return await Future.delayed(Duration(seconds: 3));
        },
              child: new FutureBuilder(
          future: imagelist,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return bodyProgress;
            } else {
              return GridView.builder(
                itemCount: snapshot.data.length,
                gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4),
                itemBuilder: (BuildContext context, int i) {
                  return GestureDetector(
                    child: GridTile(
                      child: Image.network(
                        ('http://sghps.cityschools.co/uploads/gallery/${snapshot.data[i].image}'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    onTap: () {
                      return showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          content: Image.network(
                            ('http://sghps.cityschools.co/uploads/gallery/${snapshot.data[i].image}'),
                            fit: BoxFit.fill,
                          ),
                          actions: <Widget>[
                            new FlatButton(
                              onPressed: () {
                                Navigator.of(context).pop(context);
                              },
                              child: Text('Close',style: TextStyle(color: Color.fromRGBO(33, 23, 47, 1)),),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
