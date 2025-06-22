class QuestionModel {
  final int id;
  final int apiaryId;
  final String questionText;
  final String questionType;

  QuestionModel({
    required this.id,
    required this.apiaryId,
    required this.questionText,
    required this.questionType,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      apiaryId: json['apiary_id'],
      questionText: json['question_text'],
      questionType: json['question_type'],
    );
  }
}
