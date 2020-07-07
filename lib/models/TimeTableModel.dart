import 'package:google_live/models/PeriodValue.dart';

class TimeTableModel{
  bool error;
  PeriodList monday;
  PeriodList tuesday;
  PeriodList wednesday;
  PeriodList thursday;
  PeriodList friday;
  PeriodList saturday;

  TimeTableModel({
    this.monday,this.tuesday,this.wednesday,this.thursday,this.friday,this.saturday,this.error
 });
 factory TimeTableModel.fromJson(Map<String, dynamic> parsedJson){
  // print({ "parsedJson['monday']" ,parsedJson['monday'] });
    return TimeTableModel(
      error: parsedJson['error'],
      monday: PeriodList.fromJson(parsedJson['monday']),// PeriodList.fromJson(parsedJson[monday'],
      tuesday : PeriodList.fromJson(parsedJson['tuesday']),
      wednesday: PeriodList.fromJson(parsedJson['wednesday']),
      thursday : PeriodList.fromJson(parsedJson['thursday']),
      friday: PeriodList.fromJson(parsedJson['friday']),
      saturday : PeriodList.fromJson(parsedJson['saturday']),
      
    );
  }
}