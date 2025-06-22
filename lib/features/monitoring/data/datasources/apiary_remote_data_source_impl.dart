import 'package:dio/dio.dart';
import 'package:sotfbee/features/monitoring/data/datasources/apiary_remote_data_source.dart';
import 'package:sotfbee/features/monitoring/data/models/question_model.dart';

class QuestionRemoteDataSourceImpl implements QuestionRemoteDataSource {
  final Dio dio;

  QuestionRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<QuestionModel>> getApiaryQuestions(int apiaryId) async {
    try {
      final response = await dio.get('/apiaries/$apiaryId/questions');

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => QuestionModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Error al obtener preguntas');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    }
  }
}
