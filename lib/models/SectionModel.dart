// class SectionModel {
//  final String section_name;
//  final int id;
//  final int class_id;

//  SectionModel(this.section_name,this.id,this.class_id);
 
// }

class SectionModel {
  final String section_name;
 final int id;
 final int class_id;

  SectionModel._({this.section_name,this.id,this.class_id});
  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return new SectionModel._(
      section_name: json['section_name'],
      id: json['id'],
      class_id: json['class_id']
    );
  }
}

class SectionModelList {
  final List<SectionModel> sectionlist;

  SectionModelList({
    this.sectionlist,
  });
  factory SectionModelList.fromJson(List<dynamic> parsedJson) {
    List<SectionModel> sections = new List<SectionModel>();
    // print({"pappu:", parsedJson});
    sections = parsedJson.map((i) => SectionModel.fromJson(i)).toList();
    return new SectionModelList(
      sectionlist: sections,
    );
  }
}
