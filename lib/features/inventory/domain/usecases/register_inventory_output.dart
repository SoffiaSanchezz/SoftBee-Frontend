import 'package:dartz/dartz.dart';
import 'package:sotfbee/core/errors/failures.dart';
import 'package:sotfbee/features/inventory/domain/entities/inventory_output.dart';
import 'package:sotfbee/features/inventory/domain/repositories/inventory_repository.dart';

class RegisterInventoryOutput {
  final InventoryRepository repository;

  RegisterInventoryOutput(this.repository);

  Future<Either<Failure, InventoryOutput>> call({
    required int itemId,
    required int quantity,
    required String person,
  }) async {
    return await repository.registerOutput(itemId, quantity, person);
  }
}
