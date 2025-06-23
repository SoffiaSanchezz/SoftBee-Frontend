part of 'inventory_bloc.dart';

abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object> get props => [];
}

class LoadInventoryItemsEvent extends InventoryEvent {
  final int apiaryId;

  const LoadInventoryItemsEvent(this.apiaryId);

  @override
  List<Object> get props => [apiaryId];
}

class AddInventoryItemEvent extends InventoryEvent {
  final int apiaryId;
  final String itemName;
  final int quantity;
  final String unit;

  const AddInventoryItemEvent({
    required this.apiaryId,
    required this.itemName,
    required this.quantity,
    required this.unit,
  });

  @override
  List<Object> get props => [apiaryId, itemName, quantity, unit];
}

class UpdateInventoryItemEvent extends InventoryEvent {
  final int itemId;
  final String itemName;
  final int quantity;
  final String unit;

  const UpdateInventoryItemEvent({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unit,
  });

  @override
  List<Object> get props => [itemId, itemName, quantity, unit];
}

class DeleteInventoryItemEvent extends InventoryEvent {
  final int itemId;

  const DeleteInventoryItemEvent(this.itemId);

  @override
  List<Object> get props => [itemId];
}
