import 'package:dartz/dartz.dart';
import 'package:sotfbee/core/errors/failures.dart';
import 'package:sotfbee/features/inventory/domain/entities/inventory_item.dart';
import 'package:sotfbee/features/inventory/domain/repositories/inventory_repository.dart';

class GetInventoryItems {
  final InventoryRepository repository;

  GetInventoryItems(this.repository);

  Future<Either<Failure, List<InventoryItem>>> call(int apiaryId) async {
    return await repository.getApiaryItems(apiaryId);
  }
}
