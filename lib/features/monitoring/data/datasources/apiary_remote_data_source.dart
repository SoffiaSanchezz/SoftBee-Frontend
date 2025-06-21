import 'package:sotfbee/features/monitoring/data/models/apiary_model.dart';

abstract class ApiaryRemoteDataSource {
  Future<List<ApiaryModel>> getUserApiaries(int userId);
}
