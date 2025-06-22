import 'package:sotfbee/features/monitoring/data/models/question_model.dart';

abstract class QuestionRepository {
  Future<List<QuestionModel>> getApiaryQuestions(int apiaryId);
}
