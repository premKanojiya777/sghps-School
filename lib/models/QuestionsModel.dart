class QuestionModel {
  final String ques_desc;
  final String choice_1;
  final String choice_2;
  final String choice_3;
  bool isSelected;
  final int id;

  QuestionModel(this.ques_desc, this.choice_1, this.choice_2, this.choice_3,
      this.isSelected, this.id);
}
