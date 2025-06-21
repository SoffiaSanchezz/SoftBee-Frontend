import 'package:sotfbee/features/monitoring/domain/entities/apiary_entity.dart';

abstract class ApiaryRepository {
  Future<List<ApiaryEntity>> getUserApiaries(int userId);
}
