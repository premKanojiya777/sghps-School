// import 'dart:convert';
// import 'dart:io';
// import 'package:google_live/models/SearchBookListModel.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class SearchBooks extends StatefulWidget {
//   @override
//   _SearchBooksState createState() => _SearchBooksState();
// }

// class _SearchBooksState extends State<SearchBooks> {
//   List<SearchBookListModel> searchList = [];
//   final titletext = TextEditingController();
//   final authortext = TextEditingController();
//   final publishertext = TextEditingController();
//   bool loader = false;
//   List data = List();
//   String _mySelection;
//   // var catagory_id;
//   bool isClicked = false;
//   @override
//   void initState() {
//     super.initState();
//     _getBookCatagory();
//   }

//   Future<String> _getBookCatagory() async {
//     final prefs = await SharedPreferences.getInstance();
//     String url =
//         'http://sghps.cityschools.co/studentapi/bookcat?access_token=' +
//             prefs.get('token');
//     final response = await http
//         .get(url, headers: {"Accept": "application/json"}).then((res) {
//       setState(() {
//         Map<String, dynamic> catagory = json.decode(res.body);
//         var bookcat = catagory['bookcat'];
//         data = bookcat;
//         loader = true;
//       });
//     }).catchError((onError) {
//       print(onError);
//     });
//   }

//   void _searchbook() async {
//     final prefs = await SharedPreferences.getInstance();
//     String _title = titletext.text;
//     String _author = authortext.text;
//     String _publisher = publishertext.text;
//     String url = 'http://sghps.cityschools.co/studentapi/searchbook';
//     Map dataMap = {
//       'url': url,
//       'cat_id': _mySelection,
//       'publisher': _publisher,
//       'access_token': prefs.get('token'),
//       'name': _title,
//       'author': _author,
//     };

//     await apiRequest(url, dataMap);
//   }

//   Future<List<SearchBookListModel>> apiRequest(String url, Map dataMap) async {
//     String jsonString = json.encode(dataMap);
//     HttpClient httpClient = new HttpClient();
//     HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
//     request.headers.contentType =
//         new ContentType("application", "json", charset: "utf-8");
//     request.headers.set('Content-Length', jsonString.length.toString());
//     request.write(jsonString);
//     print(jsonString);
//     HttpClientResponse response = await request.close();
//     String reply = await response.transform(utf8.decoder).join();
//     setState(() {
//       Map<String, dynamic> user = jsonDecode(reply);
//       var listofBooks = user['book'];

//       for (var b in listofBooks) {
//         SearchBookListModel model = SearchBookListModel(b['rfid'], b['name']);
//         searchList.add(model);
//       }
//       print('Lenght: ${searchList.length}');
//     });
//     setState(() {
//       isClicked = true;
//     });
//     return searchList;
//   }

//  var bodyProgress = new Container(
//     child: new Stack(
//       children: <Widget>[
//         new Container(
//           alignment: AlignmentDirectional.center,
//           decoration: new BoxDecoration(
//             color: Colors.white70,
//           ),
//           child: new Container(
//             decoration: new BoxDecoration(
//                 color: Colors.blue[100],
//                 borderRadius: new BorderRadius.circular(3.0)),
//             width: 140,
//             height: 70,
//             alignment: AlignmentDirectional.center,
//             child: new Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 new Center(
//                   child: new SizedBox(
//                     height: 30.0,
//                     width: 30.0,
//                     child: new CircularProgressIndicator(
//                       value: null,
//                       strokeWidth: 4.0,
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 9,
//                 ),
//                 new Container(
//                   // margin: const EdgeInsets.only(top: 25.0),
//                   child: new Center(
//                     child: new Text(
//                       "Loading",
//                       style: new TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     ),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromRGBO(33, 23, 47, 1),
//         title: Text('Search Books'),
//         centerTitle: true,
//       ),
//       body: loader
//           ? SingleChildScrollView(
//               child: Column(
//                 children: <Widget>[
//                   isClicked ? _bookList() : _searchUi(),
//                 ],
//               ),
//             )
//           : bodyProgress,
//     );
//   }

//   Widget _searchUi() {
//     return SingleChildScrollView(
//       child: Column(
//         children: <Widget>[
//           Container(
//             padding: EdgeInsets.fromLTRB(15, 20, 15, 5),
//             // height: 500,
//             child: Card(
//               child: Center(
//                 child: new Column(
//                   children: <Widget>[
//                     Padding(padding: EdgeInsets.only(top: 10)),
//                     Align(
//                       alignment: Alignment(-0.8, 0.0),
//                       child: Text(
//                         'Select Book Type',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 14,
//                             color: Color.fromRGBO(33, 23, 47, 1)),
//                       ),
//                     ),
//                     Align(
//                       alignment: Alignment(-0.8, 0.0),
//                       child: Container(
//                         width: 250,
//                         child: new DropdownButton(
//                           items: data.map((item) {
//                             return new DropdownMenuItem(
//                               child: new Text('${item['name']}'),
//                               value: item['id'].toString(),
//                             );
//                           }).toList(),
//                           onChanged: (newVal) {
//                             setState(() {
//                               _mySelection = newVal;
//                             });
//                           },
//                           value: _mySelection,
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Align(
//                         alignment: Alignment(-0.8, 0.0),
//                         child: Text(
//                           'Title',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                               color: Color.fromRGBO(33, 23, 47, 1)),
//                         )),
//                     Align(
//                         alignment: Alignment(-0.8, 0.0),
//                         child: Container(
//                             width: 300,
//                             padding: EdgeInsets.all(10.0),
//                             child: TextField(
//                               controller: titletext,
//                               autocorrect: true,
//                               decoration: InputDecoration(
//                                 hintText: "Enter Title",
//                                 fillColor: Colors.white,
//                                 border: new OutlineInputBorder(
//                                   borderRadius: new BorderRadius.circular(35.0),
//                                 ),
//                               ),
//                             ))),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Align(
//                         alignment: Alignment(-0.8, 0.0),
//                         child: Text(
//                           'Author',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                               color: Color.fromRGBO(33, 23, 47, 1)),
//                         )),
//                     Align(
//                         alignment: Alignment(-0.8, 0.0),
//                         child: Container(
//                             width: 300,
//                             padding: EdgeInsets.all(10.0),
//                             child: TextField(
//                               controller: authortext,
//                               autocorrect: true,
//                               decoration: InputDecoration(
//                                 hintText: "Author",
//                                 fillColor: Colors.white,
//                                 border: new OutlineInputBorder(
//                                   borderRadius: new BorderRadius.circular(35.0),
//                                 ),
//                               ),
//                             ))),
//                     SizedBox(
//                       height: 10,
//                     ),
//                     Align(
//                         alignment: Alignment(-0.8, 0.0),
//                         child: Text(
//                           'Publisher',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                               color: Color.fromRGBO(33, 23, 47, 1)),
//                         )),
//                     Align(
//                         alignment: Alignment(-0.8, 0.0),
//                         child: Container(
//                             width: 300,
//                             padding: EdgeInsets.all(10.0),
//                             child: TextField(
//                               controller: publishertext,
//                               autocorrect: true,
//                               decoration: InputDecoration(
//                                 hintText: "Publisher",
//                                 fillColor: Colors.white,
//                                 border: new OutlineInputBorder(
//                                   borderRadius: new BorderRadius.circular(35.0),
//                                 ),
//                               ),
//                             ))),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             width: 200,
//             child: RaisedButton(
//               shape: new RoundedRectangleBorder(
//                   borderRadius: new BorderRadius.circular(18.0),
//                   side: BorderSide(color: Colors.green)),
//               onPressed: _searchbook,
//               color: Color.fromRGBO(33, 23, 47, 1),
//               textColor: Colors.white,
//               padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
//               child: Text(
//                 'Submit',
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _bookList() {
//     return SingleChildScrollView(
//       child: Column(
//         children: <Widget>[
//           Container(
//             height: 30,
//             child: Card(
//               color: Colors.black,
//               child: Text(
//                 '${searchList.length} Result(s) Found Based On Your Search',
//                 style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white),
//               ),
//             ),
//           ),
//           Container(
//             padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
//             child: ListView.builder(
//               itemCount: searchList.length,
//               shrinkWrap: true,
//               itemBuilder: (BuildContext context, int i) {
//                 if (searchList.isEmpty) {
//                   return Container(
//                     child: Center(
//                       child: Text("${searchList.length} Results Founds"),
//                     ),
//                   );
//                 } else {
//                   return Container(
//                     height: 120,
//                     padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
//                     child: Card(
//                       child: Column(children: <Widget>[
//                         Text(
//                           'RFID: ${searchList[i].rfid}',
//                           style: TextStyle(fontSize: 15, color: Colors.green),
//                         ),
//                         Text(
//                           'Book Title: ${searchList[i].name}',
//                           style: TextStyle(fontSize: 15, color: Colors.green),
//                         ),
//                       ]),
//                     ),
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:google_live/models/SearchBookListModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchBooks extends StatefulWidget {
  @override
  _SearchBooksState createState() => _SearchBooksState();
}

class _SearchBooksState extends State<SearchBooks> {
  List<SearchBookListModel> searchList = [];
  final titletext = TextEditingController();
  final authortext = TextEditingController();
  final publishertext = TextEditingController();
  List data = List();
  String _mySelection;
  var catagory_id;
  bool isClicked = false;
  @override
  void initState() {
    super.initState();
    _getBookCatagory();
  }

  Future<String> _getBookCatagory() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/studentapi/bookcat?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      Map<String, dynamic> catagory = json.decode(res.body);
      var bookcat = catagory['bookcat'];
      setState(() {
        data = bookcat;
        print('Book List:$bookcat');
      });
    }).catchError((onError) {
      print(onError);
    });
  }

  void _searchbook() async {
    final prefs = await SharedPreferences.getInstance();
    String _title = titletext.text;
    String _author = authortext.text;
    String _publisher = publishertext.text;
    String url = 'http://sghps.cityschools.co/studentapi/searchbook';
    Map dataMap = {
      'url': url,
      'cat_id': _mySelection,
      'publisher': _publisher,
      'access_token': prefs.get('token'),
      'name': _title,
      'author': _author,
    };

    await apiRequest(url, dataMap);
  }

  Future<List<SearchBookListModel>> apiRequest(String url, Map dataMap) async {
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
    setState(() {
      Map<String, dynamic> user = jsonDecode(reply);
      var listofBooks = user['book'];

      for (var b in listofBooks) {
        SearchBookListModel model = SearchBookListModel(b['rfid'], b['name']);
        searchList.add(model);
      }
      print('Lenght: ${searchList.length}');
    });
    setState(() {
      isClicked = true;
    });
    return searchList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Search Books'),
          backgroundColor: Color.fromRGBO(33, 23, 47, 1),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              isClicked ? _bookList() : _searchUi(),
            ],
          ),
        ));
  }

  Widget _searchUi() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(15, 20, 15, 5),
            child: Card(
              child: Center(
                child: new Column(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(top: 10)),
                    Align(
                      alignment: Alignment(-0.95, 0.0),
                      child: Text(
                        'Select Book Type',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    Align(
                      alignment: Alignment(-0.7, 0.0),
                      child: Container(
                        width: 250,
                        child: new DropdownButton(
                          items: data.map((item) {
                            return new DropdownMenuItem(
                              child: new Text('${item['name']}'),
                              value: item['id'].toString(),
                            );
                          }).toList(),
                          onChanged: (newVal) {
                            setState(() {
                              _mySelection = newVal;
                            });
                          },
                          hint: Text("Select Book Type"),
                          value: _mySelection,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                        alignment: Alignment(-.95, 0.0),
                        child: Text(
                          'Title',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        )),
                    Align(
                        alignment: Alignment(-.7, 0.0),
                        child: Container(
                            width: MediaQuery.of(context).size.width * .8,
                            padding: EdgeInsets.all(10.0),
                            child: TextField(
                              controller: titletext,
                              autocorrect: true,
                              decoration: InputDecoration(
                                hintText: "Enter Title",
                                fillColor: Colors.white,
                                // border: new OutlineInputBorder(
                                //   borderRadius: new BorderRadius.circular(35.0),
                                // ),
                              ),
                            ))),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                        alignment: Alignment(-.95, 0.0),
                        child: Text(
                          'Author',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        )),
                    Align(
                        alignment: Alignment(-.7, 0.0),
                        child: Container(
                            width: MediaQuery.of(context).size.width * .8,
                            padding: EdgeInsets.all(10.0),
                            child: TextField(
                              controller: authortext,
                              autocorrect: true,
                              decoration: InputDecoration(
                                hintText: "Author",
                                fillColor: Colors.white,
                                // border: new OutlineInputBorder(
                                //   borderRadius: new BorderRadius.circular(35.0),
                                // ),
                              ),
                            ))),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                        alignment: Alignment(-.95, 0.0),
                        child: Text(
                          'Publisher',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        )),
                    Align(
                        alignment: Alignment(-0.7, 0.0),
                        child: Container(
                            width: MediaQuery.of(context).size.width * .8,
                            padding: EdgeInsets.all(10.0),
                            child: TextField(
                              controller: publishertext,
                              autocorrect: true,
                              decoration: InputDecoration(
                                hintText: "Publisher",
                                fillColor: Colors.white,
                                // border: new OutlineInputBorder(
                                //   borderRadius: new BorderRadius.circular(35.0),
                                // ),
                              ),
                            ))),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * .9,
            height: 35,
            child: RaisedButton(
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(16.0),
                  side: BorderSide(color: Color.fromRGBO(33, 23, 47, 1))),
              onPressed: _searchbook,
              color: Colors.white,
              textColor: Color.fromRGBO(33, 23, 47, 1),
              padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
              child: Text(
                'SUBMIT',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookList() {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            height: 30,
            child: Card(
              color: Colors.black,
              child: Text(
                '${searchList.length} Result(s) Found Based On Your Search',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: ListView.builder(
              itemCount: searchList.length,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int i) {
                if (searchList.isEmpty) {
                  return Container(
                    child: Center(
                      child: Text("${searchList.length} Results Founds"),
                    ),
                  );
                } else {
                  return Container(
                    height: 120,
                    padding: EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Card(
                      child: Column(children: <Widget>[
                        Text(
                          'RFID: ${searchList[i].rfid}',
                          style: TextStyle(fontSize: 15, color: Colors.green),
                        ),
                        Text(
                          'Book Title: ${searchList[i].name}',
                          style: TextStyle(fontSize: 15, color: Colors.green),
                        ),
                      ]),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
