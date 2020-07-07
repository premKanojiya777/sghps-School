class Leave {
  final String date;
  final String reason_for;
  final String attachement;
  final int status;
  final int id;

  Leave._({this.date, this.reason_for,this.attachement,this.status,this.id});
  factory Leave.fromJson(Map<String, dynamic> json) {
    // print({ "parsedJson['leave']" ,json['date'] });
    return new Leave._(
      date: json['date'],
      reason_for: json['reason_for'],
      attachement: json['attachement'],
      status: json['status'],
      id: json['id'],
      
    );
  }
}

class LeaveList {
  final List<Leave> leavelist;

  LeaveList({
    this.leavelist,
  });
  factory LeaveList.fromJson(List<dynamic> parsedJson) {
    List<Leave> periods = new List<Leave>();
    // print({"pappu:", parsedJson});
    periods = parsedJson.map((i) => Leave.fromJson(i)).toList();
    return new LeaveList(
      leavelist: periods,
    );
  }
}
