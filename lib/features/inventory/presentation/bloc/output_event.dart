part of 'output_bloc.dart';

abstract class OutputEvent extends Equatable {
  const OutputEvent();

  @override
  List<Object> get props => [];
}

class LoadOutputsEvent extends OutputEvent {
  final int apiaryId;

  const LoadOutputsEvent(this.apiaryId);

  @override
  List<Object> get props => [apiaryId];
}

class RegisterOutputEvent extends OutputEvent {
  final int itemId;
  final int quantity;
  final String person;

  const RegisterOutputEvent({
    required this.itemId,
    required this.quantity,
    required this.person,
  });

  @override
  List<Object> get props => [itemId, quantity, person];
}
