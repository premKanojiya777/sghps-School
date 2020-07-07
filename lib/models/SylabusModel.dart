import 'package:google_live/models/ValueSyllabus.dart';

class NewSyllabus{
  bool error;
  SyllabusList subjects;
  

  NewSyllabus({
    this.subjects,this.error
 });
 factory NewSyllabus.fromJson(Map<String, dynamic> parsedJson){
  print({ "parsedJson['subjects']" ,parsedJson['subjects'] });
    return NewSyllabus(
      error: parsedJson['error'],
      subjects: SyllabusList.fromJson(parsedJson['subjects']),// SyllabusList.fromJson(parsedJson[monday'],
      
    );
  }
}