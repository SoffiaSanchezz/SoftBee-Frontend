class InventoryItemModel {
  final int id;
  final int apiaryId;
  final String itemName;
  final int quantity;
  final String unit;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItemModel({
    required this.id,
    required this.apiaryId,
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'],
      apiaryId: json['apiary_id'],
      itemName: json['item_name'],
      quantity: json['quantity'],
      unit: json['unit'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apiary_id': apiaryId,
      'item_name': itemName,
      'quantity': quantity,
      'unit': unit,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
