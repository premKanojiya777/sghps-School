import 'dart:convert';
import 'package:google_live/models/FIlterModel.dart';
import 'package:google_live/models/SectionModel.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class SendNotification extends StatefulWidget {
  @override
  _SendNotificationState createState() => _SendNotificationState();
}

class _SendNotificationState extends State<SendNotification> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  Future<List<FilterModel>> _filter;
  List<FilterModel> _filterList = [];

  List<SectionModel> sectionList = [];
  String _mySelection;
  String sectionselect;
  List data = List();
  String selectedSection = '';
  SectionModelList sectionListBuffer;
  bool loader = false;
  bool isClassSelected = false;
  bool isClick = false;
  bool isBoth = false;
  int classid, sectionId;
  List selectedStuList = [];

  List listForFilters = [];
  int bothSection;
  bool isSelected = false;
  String status = 'F';
  SectionModel section;
  bool isFilter = false;

  @override
  void initState() {
    super.initState();
    _getClasses();
  }

  Future<List<SectionModel>> _getClasses() async {
    final prefs = await SharedPreferences.getInstance();
    String url =
        'http://sghps.cityschools.co/coordinator/class_sec?access_token=' +
            prefs.get('token');
    final response = await http
        .get(url, headers: {"Accept": "application/json"}).then((res) {
      setState(() {
        Map<String, dynamic> classes = json.decode(res.body);
        var classname = classes['classes'];
        
        data = classname;
        sectionListBuffer = SectionModelList.fromJson(classes['sections']);
        print(sectionList.length);
        loader = true;
      });
    }).catchError((onError) {
      print(onError);
    });
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

  Future<void> _sendToAll() async {
    String _title = titleController.text;
    String _desc = descriptionController.text;
    final prefs = await SharedPreferences.getInstance();
    Map _body = {
      'access_token': prefs.get('token'),
      'classid': this.classid.toString(),
      'section_id': this.sectionId.toString(),
      'desc': _desc,
      'title': _title
    };
    String url = 'http://sghps.cityschools.co/coordinator/send_noti';

    final response = await http.post(url,
        body: _body, headers: {"Accept": "application/json"}).then((res) {
      setState(() {});
      print(_body);
      print('res:${res.body}');
    }).catchError((onError) {
      print(onError);
    });
  }

  Future<List<FilterModel>> _filterSection() async {
    // print(this.bothSection);
    final prefs = await SharedPreferences.getInstance();
    Map _body = {
      'access_token': prefs.get('token'),
      'class_id': this.classid.toString(),
      'section_id': this.sectionId.toString(),
    };
    String url = 'http://sghps.cityschools.co/coordinator/filter_stu';

    final response = await http.post(url,
        body: _body, headers: {"Accept": "application/json"}).then((res) {
      setState(() {
        Map<String, dynamic> dataresponse = json.decode(res.body);
        var students = dataresponse['students'];
        print(students);
        for (var s in students) {
          FilterModel filterModel = FilterModel(s['class_roll_no'],
              s['first_name'], s['class_id'], s['section_id'], s['id']);
          _filterList.add(filterModel);
          listForFilters.add(({"first_name": "", "id": 0}));
        }
      });

      print(_filterList.length);
    }).catchError((onError) {
      print(onError);
    });
    return _filterList;
  }

  Future<void> _sendToSelected() async {
    String _title = titleController.text;
    String _desc = descriptionController.text;

    final prefs = await SharedPreferences.getInstance();
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };

    var _body = {
      'access_token': prefs.get('token'),
      'class_id': this.classid.toString(),
      'section_id': this.sectionId.toString(),
      'ids': selectedStuList,
      'desc': _desc,
      'title': _title
    };
    String url = 'http://sghps.cityschools.co/coordinator/send_to_selected';

    final response = await http
        .post(url, body: jsonEncode(_body), headers: headers)
        .then((res) {
      setState(() {});
      print(_body);
      print(res.body);
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Send Notification'),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(33, 23, 47, 1),
        ),
        body: loader
            ? SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    showClass(),
                    isClassSelected
                        ? _sectionWidget()
                        // Text(
                        //     'hiiii',
                        //     style: TextStyle(fontSize: 50),
                        //   )
                        : Container(),
                    _filteredStudents()
                  ],
                ),
              )
            : bodyProgress);
  }

  Widget showClass() {
    return Column(children: <Widget>[
      Container(
        padding: EdgeInsets.all(10.0),
        child: TextField(
          controller: titleController,
          autocorrect: true,
          decoration: InputDecoration(
            hintText: "Title",
            fillColor: Colors.white,
          ),
        ),
      ),
      SizedBox(height: 10.0),
      Container(
          // width: 320,
          padding: EdgeInsets.all(10.0),
          child: TextField(
            controller: descriptionController,
            autocorrect: true,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Description",
              fillColor: Colors.white,
            ),
          )),
      SizedBox(height: 10.0),
      Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 100),
            child: Text('Class'),
          ),
          Container(
            padding: EdgeInsets.only(left: 70),
            width: 200,
            child: new DropdownButton(
              items: data.map((item) {
                return new DropdownMenuItem(
                  child: new Text('${item['value']}'),
                  value: item['id'].toString(),
                );
              }).toList(),
              onChanged: (newVal) {
                setState(() {
                  _mySelection = newVal;
                  sectionList = [];
                  for (section in sectionListBuffer.sectionlist) {
                    if (section.class_id == int.parse(newVal)) {
                      print(section.section_name);
                      isClassSelected = true;
                      selectedSection = section.section_name;
                      sectionList.add(section);
                    }
                  }
                });
              },
              value: _mySelection,
              hint: Text('Select Class'),
            ),
          ),
          Divider(),
        ],
      ),
    ]);
  }

  Widget _filteredStudents() {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: FutureBuilder(
          future: _filter,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Text('');
            } else {
              return Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: <Widget>[
                            Text('Roll No',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: 80,
                            ),
                            Text('Name',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                            SizedBox(
                              width: 80,
                            ),
                            Text('Select',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                    height: 350,
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.all(1),
                      itemCount: _filterList.length,
                      itemBuilder: (BuildContext context, int i) {
                        Spacer();
                        return Table(
                          defaultColumnWidth: FixedColumnWidth(90.0),
                          border: TableBorder.all(),
                          children: [
                            TableRow(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: new Text(snapshot.data[i].class_roll_no
                                      .toString()),
                                ),
                                Container(
                                    padding: EdgeInsets.only(left: 10),
                                    child:
                                        new Text(snapshot.data[i].first_name)),
                                IconButton(
                                  icon: Icon(listForFilters[i]['first_name']
                                              .toString() ==
                                          _filterList[i].first_name
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked),
                                  onPressed: () {
                                    setState(() {
                                      isSelected = true;
                                      isFilter = true;
                                      listForFilters.removeAt(i);
                                      listForFilters.insert(i, {
                                        'first_name': _filterList[i].first_name,
                                        'id': 2,
                                      });
                                      isSelected ? status = 'T' : status = 'F';
                                      var stuIDs = snapshot.data[i].stu_id;
                                      var selectedStudents = {
                                        "id": stuIDs,
                                        'status': status
                                      };
                                      this
                                          .selectedStuList
                                          .add(selectedStudents);

                                      print(selectedStuList);
                                    });
                                  },
                                )
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    // ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  isFilter
                      ? Container(
                          width: 360,
                          height: 45,
                          child: RaisedButton(
                            onPressed: () {
                              setState(() {
                                _sendToSelected();
                              });
                            },
                            color: Color.fromRGBO(33, 23, 47, 1),
                            textColor: Colors.white,
                            padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                            child: Text(
                              'Send Selected Students',
                            ),
                          ),
                        )
                      : Container(),
                  SizedBox(
                    height: 30,
                  ),
                ],
              );
            }
          }),
    );
  }

  Widget _sectionWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 1),
      child: Column(
        children: <Widget>[
          new ListView.builder(
              shrinkWrap: true,
              itemCount: sectionList.length,
              itemBuilder: (context, i) {
                if (sectionList.length == 0) {
                  return CircularProgressIndicator();
                } else {
                  return Container(
                    margin: EdgeInsets.only(right: 25),
                    color: Color(0xfff9f9f9),
                    child: new ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(left: 83),
                        child: new Text(
                          "Section-${sectionList[i].section_name}",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                            selectedSection == sectionList[i].section_name
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked),
                        onPressed: () {
                          isClick = true;
                          // print('name:${sectionList[i].section_name}');
                          setState(() {
                            selectedSection = sectionList[i].section_name;
                            this.classid = sectionList[i].class_id;
                            this.sectionId = sectionList[i].id;
                          });
                        },
                        color: Colors.black,
                      ),
                    ),
                  );
                }
              }),
          sectionList.length > 1
              ? Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 96, vertical: 10),
                      child: Text(
                        'Both Section',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 0),
                      child: IconButton(
                        icon: selectedSection == section.class_id.toString()
                            ? Icon(Icons.radio_button_checked)
                            : Icon(Icons.radio_button_unchecked),
                        onPressed: () {
                          setState(() {
                            this.sectionId = 0;
                            this.classid = sectionList[0].class_id;
                            selectedSection = section.class_id.toString();
                            isClick = true;
                            this.bothSection = 0;
                            // print(this.sectionId);
                            // print(this.classid);
                          });
                        },
                      ),
                    ),
                  ],
                )
              : Container(),
          (isClick
              ? Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: 360,
                      height: 45,
                      child: RaisedButton(
                        onPressed: () {
                          _sendToAll();
                        },
                        color: Color.fromRGBO(33, 23, 47, 1),
                        textColor: Colors.white,
                        padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                        child: Text(
                          'Send To All',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    width: 360,
                    height: 45,
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          _filterList = [];
                          if (this.sectionId == 0) {
                            Toast.show('Please Select Section A or B', context,
                                duration: Toast.LENGTH_LONG,
                                gravity: Toast.BOTTOM);
                          } else {
                            _filter = _filterSection();
                          }
                        });
                      },
                      color: Color.fromRGBO(33, 23, 47, 1),
                      textColor: Colors.white,
                      padding: EdgeInsets.fromLTRB(9, 9, 9, 9),
                      child: Text(
                        'Filter',
                      ),
                    ),
                  ),
                ])
              : Container()),
        ],
      ),
    );
  }
}
