import 'package:dartz/dartz.dart';
import 'package:sotfbee/core/errors/failures.dart';
import 'package:sotfbee/features/inventory/domain/entities/inventory_output.dart';
import 'package:sotfbee/features/inventory/domain/repositories/inventory_repository.dart';

class GetInventoryOutputs {
  final InventoryRepository repository;

  GetInventoryOutputs(this.repository);

  Future<Either<Failure, List<InventoryOutput>>> call(int apiaryId) async {
    return await repository.getItemOutputs(apiaryId);
  }
}
