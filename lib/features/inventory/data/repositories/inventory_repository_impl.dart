class InventoryOutputModel {
  final int id;
  final int itemId;
  final int quantity;
  final String person;
  final DateTime date;

  InventoryOutputModel({
    required this.id,
    required this.itemId,
    required this.quantity,
    required this.person,
    required this.date,
  });

  factory InventoryOutputModel.fromJson(Map<String, dynamic> json) {
    return InventoryOutputModel(
      id: json['id'],
      itemId: json['item_id'],
      quantity: json['quantity'],
      person: json['person'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_id': itemId,
      'quantity': quantity,
      'person': person,
      'date': date.toIso8601String(),
    };
  }
}
