import 'package:sotfbee/features/monitoring/data/models/question_model.dart';
import 'package:sotfbee/features/monitoring/domain/repositories/question_repository.dart';

class GetApiaryQuestions {
  final QuestionRepository repository;

  GetApiaryQuestions(this.repository);

  Future<List<QuestionModel>> call(int apiaryId) async {
    return await repository.getApiaryQuestions(apiaryId);
  }
}
