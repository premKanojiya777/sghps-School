class DateValue {
  final String date_sheet;
  final String type;

  DateValue._({this.date_sheet,this.type});
  factory DateValue.fromJson(Map<String, dynamic> json) {
    return new DateValue._(
      date_sheet: json['date_sheet'],
      type: json['type'],
    );
  }
}

class DateSheetList {
  final List<DateValue> datesheetList;

  DateSheetList({
    this.datesheetList,
  });
  factory DateSheetList.fromJson(List<dynamic> parsedJson) {
    List<DateValue> periods = new List<DateValue>();
    // print({"pappu:", parsedJson});
    periods = parsedJson.map((i) => DateValue.fromJson(i)).toList();
    return new DateSheetList(
      datesheetList: periods,
    );
  }
}
