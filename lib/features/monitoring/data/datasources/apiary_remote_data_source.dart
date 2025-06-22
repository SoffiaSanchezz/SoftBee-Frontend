// import 'package:sotfbee/features/monitoring/data/models/apiary_model.dart';

// abstract class ApiaryRemoteDataSource {
//   Future<List<ApiaryModel>> getUserApiaries(int userId);
// }
import 'package:sotfbee/features/monitoring/data/models/question_model.dart';

abstract class QuestionRemoteDataSource {
  Future<List<QuestionModel>> getApiaryQuestions(int apiaryId);
}
