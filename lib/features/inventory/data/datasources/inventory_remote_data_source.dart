import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_item_model.dart';
import '../models/inventory_output_model.dart';

class InventoryRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  InventoryRemoteDataSource({required this.client, required this.baseUrl});

  Future<List<InventoryItemModel>> getApiaryItems(int apiaryId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/apiaries/$apiaryId/inventory'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => InventoryItemModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load inventory items: ${response.statusCode}');
    }
  }

  Future<InventoryItemModel> createItem(
    int apiaryId,
    String itemName,
    int quantity,
    String unit,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/inventory'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'apiary_id': apiaryId,
        'item_name': itemName,
        'quantity': quantity,
        'unit': unit,
      }),
    );

    if (response.statusCode == 201) {
      return InventoryItemModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create item: ${response.statusCode}');
    }
  }

  Future<void> updateItem(int itemId, Map<String, dynamic> data) async {
    final response = await client.put(
      Uri.parse('$baseUrl/inventory/$itemId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item: ${response.statusCode}');
    }
  }

  Future<void> deleteItem(int itemId) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/inventory/$itemId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete item: ${response.statusCode}');
    }
  }

  Future<List<InventoryOutputModel>> getItemOutputs(int itemId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/inventory/$itemId/outputs'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList
          .map((json) => InventoryOutputModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to get outputs: ${response.statusCode}');
    }
  }

  Future<InventoryOutputModel> registerOutput(
    int itemId,
    int quantity,
    String person,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/inventory/output'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'item_id': itemId,
        'quantity': quantity,
        'person': person,
      }),
    );

    if (response.statusCode == 201) {
      return InventoryOutputModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to register output: ${response.statusCode}');
    }
  }
}
