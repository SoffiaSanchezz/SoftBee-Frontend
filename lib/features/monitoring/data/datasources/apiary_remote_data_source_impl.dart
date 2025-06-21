import 'package:dio/dio.dart';
import 'package:sotfbee/features/monitoring/data/datasources/apiary_remote_data_source.dart';
import 'package:sotfbee/features/monitoring/data/models/apiary_model.dart';

class ApiaryRemoteDataSourceImpl implements ApiaryRemoteDataSource {
  final Dio dio;

  ApiaryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ApiaryModel>> getUserApiaries(int userId) async {
    try {
      final response = await dio.get('/users/$userId/apiaries');

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((json) => ApiaryModel.fromJson(json))
              .toList();
        } else if (response.data['empty'] == true) {
          return [];
        } else {
          throw Exception('Formato de respuesta inesperado');
        }
      } else {
        throw Exception('Error en la respuesta del servidor');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión: ${e.message}');
    }
  }
}
