import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sotfbee/features/inventory/domain/entities/inventory_output.dart';

class OutputHistoryCard extends StatelessWidget {
  final InventoryOutput output;

  const OutputHistoryCard({Key? key, required this.output}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              output.itemName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Cantidad: ${output.quantity}'),
            const SizedBox(height: 4),
            Text('Persona: ${output.person}'),
            const SizedBox(height: 4),
            Text(
              'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(output.date)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
