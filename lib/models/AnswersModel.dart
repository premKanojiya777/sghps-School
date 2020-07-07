class AnswerModel {
  final String ques_desc;
  final String choice_1;
  final String choice_2;
  final String choice_3;
  final answer;
  final user_answer;

  AnswerModel(this.ques_desc, this.choice_1, this.choice_2, this.choice_3,
      this.answer, this.user_answer);
}
