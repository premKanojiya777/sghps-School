class ExamModel {
  final String name;
  final String subject_name;
  final int total_marks;
  final int pass_marks;
  final int duration;
  final String start_date;
  final String end_date;
  final String description;
  final bool startexam;
  final bool cancel;
  final int id;
  final bool isSubmit;

  ExamModel(
      this.name,
      this.total_marks,
      this.pass_marks,
      this.duration,
      this.start_date,
      this.end_date,
      this.description,
      this.subject_name,
      this.startexam,
      this.cancel,
      this.id,this.isSubmit);
}
