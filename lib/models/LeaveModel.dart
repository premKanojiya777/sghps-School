import 'package:google_live/models/LeaveValueModel.dart';

class LeaveModel{
  LeaveList leave;

  LeaveModel({
    this.leave
 });
 factory LeaveModel.fromJson(Map<String, dynamic> parsedJson){
  //  print({ "parsedJson['leave']" ,parsedJson['leave'] });
    return LeaveModel(
      leave: LeaveList.fromJson(parsedJson['leave']),// PeriodList.fromJson(parsedJson[monday'],
     
      
    );
  }
}