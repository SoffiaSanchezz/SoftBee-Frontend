import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:sotfbee/core/errors/failures.dart';
import 'package:sotfbee/features/inventory/domain/entities/inventory_output.dart';
import 'package:sotfbee/features/inventory/domain/usecases/get_inventory_outputs.dart';
import 'package:sotfbee/features/inventory/domain/usecases/register_inventory_output.dart';

part 'output_event.dart';
part 'output_state.dart';

class OutputBloc extends Bloc<OutputEvent, OutputState> {
  final GetInventoryOutputs getInventoryOutputs;
  final RegisterInventoryOutput registerInventoryOutput;

  OutputBloc({
    required this.getInventoryOutputs,
    required this.registerInventoryOutput,
  }) : super(OutputInitial()) {
    on<LoadOutputsEvent>(_onLoadOutputs);
    on<RegisterOutputEvent>(_onRegisterOutput);
  }

  Future<void> _onLoadOutputs(
    LoadOutputsEvent event,
    Emitter<OutputState> emit,
  ) async {
    emit(OutputLoading());
    final result = await getInventoryOutputs(event.apiaryId);

    result.fold(
      (failure) => emit(OutputError(message: _mapFailureToMessage(failure))),
      (outputs) =>
          emit(OutputLoaded(outputs: outputs, apiaryId: event.apiaryId)),
    );
  }

  Future<void> _onRegisterOutput(
    RegisterOutputEvent event,
    Emitter<OutputState> emit,
  ) async {
    if (state is OutputLoaded) {
      final currentState = state as OutputLoaded;
      emit(OutputLoading());

      final result = await registerInventoryOutput(
        itemId: event.itemId,
        quantity: event.quantity,
        person: event.person,
      );

      result.fold(
        (failure) {
          emit(OutputError(message: _mapFailureToMessage(failure)));
          emit(currentState);
        },
        (newOutput) async {
          final outputsResult = await getInventoryOutputs(
            currentState.apiaryId,
          );
          outputsResult.fold(
            (failure) =>
                emit(OutputError(message: _mapFailureToMessage(failure))),
            (outputs) => emit(
              OutputLoaded(outputs: outputs, apiaryId: currentState.apiaryId),
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
