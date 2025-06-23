import 'package:dartz/dartz.dart';
import 'package:sotfbee/core/errors/failures.dart';
import 'package:sotfbee/features/inventory/domain/entities/inventory_item.dart';
import 'package:sotfbee/features/inventory/domain/entities/inventory_output.dart';

abstract class InventoryRepository {
  Future<Either<Failure, List<InventoryItem>>> getApiaryItems(int apiaryId);

  Future<Either<Failure, InventoryItem>> createItem(
    int apiaryId,
    String itemName,
    int quantity,
    String unit,
  );

  Future<Either<Failure, void>> updateItem(
    int itemId,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, void>> deleteItem(int itemId);

  Future<Either<Failure, List<InventoryOutput>>> getItemOutputs(int itemId);

  Future<Either<Failure, InventoryOutput>> registerOutput(
    int itemId,
    int quantity,
    String person,
  );
}
