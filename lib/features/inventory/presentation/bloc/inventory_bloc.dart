import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sotfbee/core/errors/failures.dart';
import 'package:sotfbee/features/inventory/domain/entities/inventory_item.dart';
import 'package:sotfbee/features/inventory/domain/usecases/create_inventory_item.dart';
import 'package:sotfbee/features/inventory/domain/usecases/delete_inventory_item.dart';
import 'package:sotfbee/features/inventory/domain/usecases/get_inventory_items.dart';
import 'package:sotfbee/features/inventory/domain/usecases/update_inventory_item.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetInventoryItems getInventoryItems;
  final CreateInventoryItem createInventoryItem;
  final UpdateInventoryItem updateInventoryItem;
  final DeleteInventoryItem deleteInventoryItem;

  InventoryBloc({
    required this.getInventoryItems,
    required this.createInventoryItem,
    required this.updateInventoryItem,
    required this.deleteInventoryItem,
  }) : super(InventoryInitial()) {
    on<LoadInventoryItemsEvent>(_onLoadInventoryItems);
    on<AddInventoryItemEvent>(_onAddInventoryItem);
    on<UpdateInventoryItemEvent>(_onUpdateInventoryItem);
    on<DeleteInventoryItemEvent>(_onDeleteInventoryItem);
  }

  Future<void> _onLoadInventoryItems(
    LoadInventoryItemsEvent event,
    Emitter<InventoryState> emit,
  ) async {
    emit(InventoryLoading());
    final result = await getInventoryItems(event.apiaryId);

    result.fold(
      (failure) => emit(InventoryError(message: _mapFailureToMessage(failure))),
      (items) => emit(InventoryLoaded(items: items, apiaryId: event.apiaryId)),
    );
  }

  Future<void> _onAddInventoryItem(
    AddInventoryItemEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      emit(InventoryLoading());

      final result = await createInventoryItem(
        apiaryId: event.apiaryId,
        itemName: event.itemName,
        quantity: event.quantity,
        unit: event.unit,
      );

      result.fold(
        (failure) {
          emit(InventoryError(message: _mapFailureToMessage(failure)));
          emit(currentState);
        },
        (newItem) async {
          final itemsResult = await getInventoryItems(event.apiaryId);
          itemsResult.fold(
            (failure) =>
                emit(InventoryError(message: _mapFailureToMessage(failure))),
            (items) =>
                emit(InventoryLoaded(items: items, apiaryId: event.apiaryId)),
          );
        },
      );
    }
  }

  Future<void> _onUpdateInventoryItem(
    UpdateInventoryItemEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      emit(InventoryLoading());

      final updateResult = await updateInventoryItem(
        itemId: event.itemId,
        data: {
          'item_name': event.itemName,
          'quantity': event.quantity,
          'unit': event.unit,
        },
      );

      updateResult.fold(
        (failure) {
          emit(InventoryError(message: _mapFailureToMessage(failure)));
          emit(currentState);
        },
        (_) async {
          final itemsResult = await getInventoryItems(currentState.apiaryId);
          itemsResult.fold(
            (failure) =>
                emit(InventoryError(message: _mapFailureToMessage(failure))),
            (items) => emit(
              InventoryLoaded(items: items, apiaryId: currentState.apiaryId),
            ),
          );
        },
      );
    }
  }

  Future<void> _onDeleteInventoryItem(
    DeleteInventoryItemEvent event,
    Emitter<InventoryState> emit,
  ) async {
    if (state is InventoryLoaded) {
      final currentState = state as InventoryLoaded;
      emit(InventoryLoading());

      final deleteResult = await deleteInventoryItem(event.itemId);

      deleteResult.fold(
        (failure) {
          emit(InventoryError(message: _mapFailureToMessage(failure)));
          emit(currentState);
        },
        (_) async {
          final itemsResult = await getInventoryItems(currentState.apiaryId);
          itemsResult.fold(
            (failure) =>
                emit(InventoryError(message: _mapFailureToMessage(failure))),
            (items) => emit(
              InventoryLoaded(items: items, apiaryId: currentState.apiaryId),
            ),
          );
        },
      );
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    }
    return 'Error desconocido';
  }
}
