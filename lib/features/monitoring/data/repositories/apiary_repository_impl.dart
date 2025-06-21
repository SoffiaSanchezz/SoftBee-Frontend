import 'package:sotfbee/features/monitoring/data/datasources/apiary_remote_data_source.dart';
import 'package:sotfbee/features/monitoring/domain/entities/apiary_entity.dart';
import 'package:sotfbee/features/monitoring/domain/repositories/apiary_repository.dart';

class ApiaryRepositoryImpl implements ApiaryRepository {
  final ApiaryRemoteDataSource remoteDataSource;

  ApiaryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ApiaryEntity>> getUserApiaries(int userId) async {
    try {
      final apiaries = await remoteDataSource.getUserApiaries(userId);
      return apiaries;
    } catch (e) {
      throw Exception('Error al obtener apiarios: $e');
    }
  }
}
