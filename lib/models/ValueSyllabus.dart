class Syllabus {
  final String subject_name;
  final String pdf_file;

  Syllabus._({this.subject_name, this.pdf_file,});
  factory Syllabus.fromJson(Map<String, dynamic> json) {
    return new Syllabus._(
      subject_name: json['subject_name'],
      pdf_file: json['pdf_file'],
     
    );
  }
}

class SyllabusList {
  final List<Syllabus>  syllabusList;

  SyllabusList({
    this.syllabusList,
  });
  factory SyllabusList.fromJson(List<dynamic> parsedJson) {
    List<Syllabus> syllabuss = new List<Syllabus>();
    // print({"pappu:", parsedJson});
    syllabuss = parsedJson.map((i) => Syllabus.fromJson(i)).toList();
    return new SyllabusList(
      syllabusList: syllabuss,
    );
  }
}
