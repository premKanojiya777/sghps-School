class Period {
  final String period;
  final String value;
  final String classs;

  Period._({this.period, this.value,this.classs});
  factory Period.fromJson(Map<String, dynamic> json) {
    return new Period._(
      period: json['period'],
      value: json['value'],
      classs: json['class'],
    );
  }
}

class PeriodList {
  final List<Period> periodList;

  PeriodList({
    this.periodList,
  });
  factory PeriodList.fromJson(List<dynamic> parsedJson) {
    List<Period> periods = new List<Period>();
    // print({"pappu:", parsedJson});
    periods = parsedJson.map((i) => Period.fromJson(i)).toList();
    return new PeriodList(
      periodList: periods,
    );
  }
}
