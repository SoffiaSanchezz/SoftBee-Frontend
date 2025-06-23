part of 'output_bloc.dart';

abstract class OutputState extends Equatable {
  const OutputState();

  @override
  List<Object> get props => [];
}

class OutputInitial extends OutputState {}

class OutputLoading extends OutputState {}

class OutputLoaded extends OutputState {
  final List<InventoryOutput> outputs;
  final int apiaryId;

  const OutputLoaded({required this.outputs, required this.apiaryId});

  @override
  List<Object> get props => [outputs, apiaryId];
}

class OutputError extends OutputState {
  final String message;

  const OutputError({required this.message});

  @override
  List<Object> get props => [message];
}
