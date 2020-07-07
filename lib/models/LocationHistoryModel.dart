import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ListViewModel{
  final String longitude;
  final String latitude;
  final String route;
  final String speed;
  final String accuracy;
  final int routeid;
  final int vehicleid;
  final String timestamp;
  
  

  ListViewModel( {
    this.longitude,
    this.latitude,
    this.speed,
    this.route,
    this.routeid,
    this.vehicleid, 
    this.accuracy, 
    this.timestamp,
  });
}



List listViewData = [ListViewModel()];

class DisplayListView extends StatefulWidget {
  @override
  _DisplayListViewState createState() => _DisplayListViewState();
}

class _DisplayListViewState extends State {
  @override
  Widget build(BuildContext context) {
    return ListView.builder( 
      itemCount: listViewData.length,
      itemBuilder: (BuildContext context, int i) {
        var listTile = new ListTile(
            title: new Text(listViewData[i].latitude.toString()),
            subtitle: new Text(listViewData[i].longitude.toString()),
            onTap: (){},
            onLongPress: (){
              print(
                Text("Long Pressed"),
              );
            },
          );
        return Column(
        children: [
          listTile,
        ],
      );
      },
    );
  }
}