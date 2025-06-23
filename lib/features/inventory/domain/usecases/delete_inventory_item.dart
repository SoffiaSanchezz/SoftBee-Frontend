import 'package:dartz/dartz.dart';
import 'package:sotfbee/core/errors/failures.dart';
import 'package:sotfbee/features/inventory/domain/repositories/inventory_repository.dart';

class DeleteInventoryItem {
  final InventoryRepository repository;

  DeleteInventoryItem(this.repository);

  Future<Either<Failure, void>> call(int itemId) async {
    return await repository.deleteItem(itemId);
  }
}
