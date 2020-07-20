class SingleTimeTable {
  final String subject_name;
  final String class_name;
  final String period_name;
  final int class_id;
  final int section_id;
  final int subject_id;
  final int period_ID;
  final bool isData;
  final String section_name;
  final String teacher_name;

  SingleTimeTable(
      this.subject_name,
      this.class_name,
      this.period_name,
      this.class_id,
      this.period_ID,
      this.section_id,
      this.subject_id,
      this.isData,
      this.section_name,this.teacher_name);
}
