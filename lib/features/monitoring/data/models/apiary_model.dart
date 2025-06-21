import 'package:sotfbee/features/monitoring/domain/entities/apiary_entity.dart';

class ApiaryModel extends ApiaryEntity {
  ApiaryModel({required super.id, required super.name, super.location});

  factory ApiaryModel.fromJson(Map<String, dynamic> json) {
    return ApiaryModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }
}
