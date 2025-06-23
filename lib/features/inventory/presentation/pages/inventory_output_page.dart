import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sotfbee/features/inventory/domain/entities/inventory_output.dart';
import 'package:sotfbee/features/inventory/presentation/bloc/output_bloc.dart';
import 'package:sotfbee/features/inventory/presentation/widgets/output_history_card.dart';

class InventoryOutputPage extends StatelessWidget {
  final int itemId;
  final String itemName;

  const InventoryOutputPage({
    Key? key,
    required this.itemId,
    required this.itemName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Salidas de $itemName')),
      body: BlocBuilder<OutputBloc, OutputState>(
        builder: (context, state) {
          if (state is OutputLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OutputError) {
            return Center(child: Text(state.message));
          } else if (state is OutputLoaded) {
            return _buildOutputsList(state.outputs);
          }
          return const Center(child: Text('No hay registros de salidas'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRegisterOutputDialog(context),
        child: const Icon(Icons.exit_to_app),
      ),
    );
  }

  Widget _buildOutputsList(List<InventoryOutput> outputs) {
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

  void _showRegisterOutputDialog(BuildContext context) {
    final quantityController = TextEditingController();
    final personController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Registrar Salida'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: personController,
                decoration: const InputDecoration(labelText: 'Persona'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final bloc = context.read<OutputBloc>();
                bloc.add(
                  RegisterOutputEvent(
                    itemId: itemId,
                    quantity: int.tryParse(quantityController.text) ?? 0,
                    person: personController.text,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Registrar'),
            ),
          ],
        );
      },
    );
  }
}
