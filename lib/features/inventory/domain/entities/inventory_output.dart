class InventoryOutput {
  final int id;
  final int itemId;
  final String itemName; // Se completará desde el frontend
  final int quantity;
  final String person;
  final DateTime date;

  InventoryOutput({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.person,
    required this.date,
  });
}
