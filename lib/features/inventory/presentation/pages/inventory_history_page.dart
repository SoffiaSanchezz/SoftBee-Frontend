import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sotfbee/features/inventory/domain/entities/inventory_output.dart';
import 'package:sotfbee/features/inventory/presentation/bloc/output_bloc.dart';
import 'package:sotfbee/features/inventory/presentation/widgets/output_history_card.dart';

class InventoryHistoryPage extends StatelessWidget {
  final int apiaryId;

  const InventoryHistoryPage({Key? key, required this.apiaryId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Salidas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OutputBloc>().add(LoadOutputsEvent(apiaryId));
            },
          ),
        ],
      ),
      body: BlocBuilder<OutputBloc, OutputState>(
        builder: (context, state) {
          if (state is OutputLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OutputError) {
            return Center(child: Text(state.message));
          } else if (state is OutputLoaded) {
            return _buildHistoryList(state.outputs);
          }
          return const Center(
            child: Text('Presiona recargar para ver el historial'),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList(List<InventoryOutput> outputs) {
    if (outputs.isEmpty) {
      return const Center(child: Text('No hay registros de salidas'));
    }

    return ListView.builder(
      itemCount: outputs.length,
      itemBuilder: (context, index) {
        final output = outputs[index];
        return OutputHistoryCard(output: output);
      },
    );
  }
}
