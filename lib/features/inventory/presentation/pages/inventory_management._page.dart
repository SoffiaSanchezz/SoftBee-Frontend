import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sotfbee/features/inventory/domain/entities/inventory_item.dart';
import 'package:sotfbee/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:sotfbee/features/inventory/presentation/widgets/inventory_item_card.dart';

class InventoryManagementPage extends StatelessWidget {
  final int apiaryId;

  const InventoryManagementPage({Key? key, required this.apiaryId})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<InventoryBloc>().add(
                LoadInventoryItemsEvent(apiaryId),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is InventoryError) {
            return Center(child: Text(state.message));
          } else if (state is InventoryLoaded) {
            return _buildInventoryList(state.items);
          }
          return const Center(
            child: Text('Presiona recargar para ver los items'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInventoryList(List<InventoryItem> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No hay items en el inventario'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InventoryItemCard(
          item: item,
          onEdit: () => _showEditItemDialog(context, item),
          onDelete: () => _deleteItem(context, item.id),
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final unitController = TextEditingController(text: 'unidad');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre del item'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unidad'),
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
                final bloc = context.read<InventoryBloc>();
                bloc.add(
                  AddInventoryItemEvent(
                    apiaryId: apiaryId,
                    itemName: nameController.text,
                    quantity: int.tryParse(quantityController.text) ?? 0,
                    unit: unitController.text,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(BuildContext context, InventoryItem item) {
    final nameController = TextEditingController(text: item.itemName);
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final unitController = TextEditingController(text: item.unit);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre del item'),
              ),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unidad'),
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
                final bloc = context.read<InventoryBloc>();
                bloc.add(
                  UpdateInventoryItemEvent(
                    itemId: item.id,
                    itemName: nameController.text,
                    quantity: int.tryParse(quantityController.text) ?? 0,
                    unit: unitController.text,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(BuildContext context, int itemId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar'),
          content: const Text('¿Estás seguro de eliminar este item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<InventoryBloc>().add(
                  DeleteInventoryItemEvent(itemId),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}
