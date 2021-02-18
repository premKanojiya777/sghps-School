import 'dart:convert';
import 'package:google_live/models/LibraryModel.dart';
import 'package:google_live/widgets/SearchBooks.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryList extends StatefulWidget {
  @override
  _LibraryListState createState() => _LibraryListState();
}

class _LibraryListState extends State<LibraryList> {
  Future<List<LibraryModel>> libraryM;
  List<LibraryModel> list = [];
  bool isOverdue = false;
  bool isnotDue = false;
  bool loader = false;
  @override
  void initState() {
    super.initState();
    libraryM = _getLibrary();
  }

  Future<List<LibraryModel>> _getLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'https://sghps.cityschools.co/studentapi/issuebooks?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Content-Type": "application/json"}).then((res) {
      Map<String, dynamic> library = jsonDecode(res.body);
      setState(() {
        loader = true;
        var books = library['books'];
        for (var u in books) {
          var issueDate = u['issue_date'];
          var returnDate = u['return_date'];
          var userReturnDate = u['return_date_user'];
          List<String> issueDataaArray = issueDate.toString().split("/");
          // print('day:${issueDataaArray[0]}');
          // print('month:${issueDataaArray[1]}');
          // print('year:${issueDataaArray[2]}');

          List<String> returnDateArray = returnDate.toString().split("-");
          print(returnDateArray);

          DateTime issueDateTime = DateTime.utc(
              int.parse('20${issueDataaArray[2]}'),
              int.parse('${issueDataaArray[1]}'),
              int.parse('${issueDataaArray[0]}'),
              0,
              0,
              0);
          DateTime returnDateTime = DateTime.utc(
              int.parse('${returnDateArray[0]}'),
              int.parse('${returnDateArray[1]}'),
              int.parse('${returnDateArray[2]}'),
              0,
              0,
              0);

          DateTime currentDateTime = DateTime.utc(DateTime.now().year,
              DateTime.now().month, DateTime.now().day, 0, 0, 0);
          // print(currentDateTime); // DateTime type in UTC
          // print(returnDateTime); // DateTime type in UTC
          // print(currentDateTime.difference(returnDateTime).inHours);
          // print(currentDateTime.difference(returnDateTime).inMinutes);
          // print(currentDateTime.difference(returnDateTime).inSeconds);

          if (userReturnDate == null) {
            if (currentDateTime.difference(returnDateTime).inHours > 0) {
              this.isOverdue = true;
              this.isnotDue = false;
            } else if (currentDateTime.difference(returnDateTime).inHours < 0) {
              this.isnotDue = true;
              this.isOverdue = false;
            }
          }

          // if (userReturnDate != null) {
          //   if (userReturnDate.difference(returnDateTime).inHours > 0) {
          //     this.isOverdue = true;
          //     this.isnotDue = false;
          //   } else if (userReturnDate.difference(returnDateTime).inHours < 0) {
          //     this.isnotDue = true;
          //     this.isOverdue = false;
          //   }
          //   // 2020-04-24
          // }
          LibraryModel libraryModel = LibraryModel(
              u["book"]['name'],
              u["issue_date"],
              u["return_date"],
              u['book']["rfid"],
              this.isOverdue,
              this.isnotDue);

          list.add(libraryModel);
        }
      });
      print(list.length);
      print(loader);
    }).catchError((onError) {
      print(onError);
    });
    return list;
  }

  var bodyProgress = new Container(
    child: new Stack(
      children: <Widget>[
        new Container(
          alignment: AlignmentDirectional.center,
          decoration: new BoxDecoration(
            color: Colors.white70,
          ),
          child: new Container(
            decoration: new BoxDecoration(
                color: Colors.blue[100],
                borderRadius: new BorderRadius.circular(3.0)),
            width: 140,
            height: 70,
            alignment: AlignmentDirectional.center,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Center(
                  child: new SizedBox(
                    height: 30.0,
                    width: 30.0,
                    child: new CircularProgressIndicator(
                      value: null,
                      strokeWidth: 4.0,
                    ),
                  ),
                ),
                SizedBox(
                  width: 9,
                ),
                new Container(
                  // margin: const EdgeInsets.only(top: 25.0),
                  child: new Center(
                    child: new Text(
                      "Loading",
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
        title: Text('Library'),
        centerTitle: true,
      ),
      body: loader == false
          ? bodyProgress
          : RefreshIndicator(
              onRefresh: () async {
                list = [];
                _getLibrary();
                return await Future.delayed(Duration(seconds: 3));
              },
              child: Column(
                children: <Widget>[
                  list.length == 0
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                          ),
                          height: 40,
                          child: Card(
                            color: Colors.black,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Currently No Book Issue Search Books',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                          ),
                          height: 40,
                          child: Card(
                            color: Colors.black,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${list.length} Books are Issued',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                  Container(
                    child: FutureBuilder(
                      future: libraryM,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.data == null) {
                          return Container();
                          // Center(
                          //   child: bodyProgress,
                          // );
                        } else {
                          return Container(
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.fromLTRB(15, 30, 15, 10),
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int i) {
                                // print('${snapshot.data[i].name}');
                                return Column(
                                  children: <Widget>[
                                    Stack(
                                      children: <Widget>[
                                        Container(
                                          height: 150,
                                          child: Card(
                                            child: ListTile(
                                              leading: Image.asset(
                                                'book.jpg',
                                                height: 70,
                                                fit: BoxFit.cover,
                                              ),
                                              title: Text(
                                                  '${snapshot.data[i].name}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              subtitle: Text(
                                                'ISSUE DATE:${snapshot.data[i].issue_date}'
                                                '\n'
                                                'DUE DATE:${snapshot.data[i].return_date}'
                                                '\n'
                                                'RF ID:${snapshot.data[i].rfid}',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ),
                                        ),
                                        snapshot.data[i].isOverdue
                                            ? new Positioned(
                                                left: 230.0,
                                                top: 75,
                                                child: new Image.asset(
                                                  'overdue.jpeg',
                                                  height: 50,
                                                  //width: 60,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : (!isnotDue
                                                ? new Positioned(
                                                    left: 230.0,
                                                    top: 75,
                                                    child: new Image.asset(
                                                      'returned.jpeg',
                                                      height: 50,
                                                      //width: 60,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Container())
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * .7,
                    child: RaisedButton(
                      shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                          side:
                              BorderSide(color: Color.fromRGBO(33, 23, 47, 1))),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SearchBooks()),
                        );
                      },
                      color: Colors.white,
                      textColor: Color.fromRGBO(33, 23, 47, 1),
                      padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                      child: Text(
                        'SEARCH',
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
