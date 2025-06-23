import 'package:dartz/dartz.dart';
import 'package:sotfbee/core/errors/failures.dart';
import 'package:sotfbee/features/inventory/domain/entities/inventory_item.dart';
import 'package:sotfbee/features/inventory/domain/repositories/inventory_repository.dart';

class CreateInventoryItem {
  final InventoryRepository repository;

  CreateInventoryItem(this.repository);

  Future<Either<Failure, InventoryItem>> call({
    required int apiaryId,
    required String itemName,
    required int quantity,
    required String unit,
  }) async {
    return await repository.createItem(apiaryId, itemName, quantity, unit);
  }
}
