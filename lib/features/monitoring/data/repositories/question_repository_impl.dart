import 'package:sotfbee/features/monitoring/data/datasources/apiary_remote_data_source.dart';
import 'package:sotfbee/features/monitoring/data/models/question_model.dart';
import 'package:sotfbee/features/monitoring/domain/repositories/question_repository.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  final QuestionRemoteDataSource remoteDataSource;

  QuestionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<QuestionModel>> getApiaryQuestions(int apiaryId) async {
    return await remoteDataSource.getApiaryQuestions(apiaryId);
  }
}
