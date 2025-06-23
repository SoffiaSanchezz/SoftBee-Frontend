class InventoryItem {
  final int id;
  final int apiaryId;
  final String itemName;
  final int quantity;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItem({
    required this.id,
    required this.apiaryId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });
}
