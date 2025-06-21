import 'package:sotfbee/features/monitoring/domain/entities/apiary_entity.dart';
import 'package:sotfbee/features/monitoring/domain/repositories/apiary_repository.dart';

class GetUserApiaries {
  final ApiaryRepository repository;

  GetUserApiaries(this.repository);

  Future<List<ApiaryEntity>> call(int userId) async {
    return await repository.getUserApiaries(userId);
  }
}
