import 'package:dartz/dartz.dart';
import 'package:sotfbee/core/errors/failures.dart';
import 'package:sotfbee/features/inventory/domain/repositories/inventory_repository.dart';

class UpdateInventoryItem {
  final InventoryRepository repository;

  UpdateInventoryItem(this.repository);

  Future<Either<Failure, void>> call({
    required int itemId,
    required Map<String, dynamic> data,
  }) async {
    return await repository.updateItem(itemId, data);
  }
}
