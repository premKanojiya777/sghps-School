import 'package:google_live/models/DateSheetValue.dart';

class DateSheetModel{
  bool error;
  DateSheetList resulttype;

  DateSheetModel({
    this.resulttype,this.error,
 });
 factory DateSheetModel.fromJson(Map<String, dynamic> parsedJson){
   print({ "parsedJson['resulttype']" ,parsedJson['resulttype'] });
    return DateSheetModel(
      error: parsedJson['error'],
      resulttype: DateSheetList.fromJson(parsedJson['resulttype']),
      // PeriodList.fromJson(parsedJson[monday'],
     
      
    );
  }
}

// class DateSheetModel{
//   final String date_sheet;
  

//   DateSheetModel(this.date_sheet);
// }