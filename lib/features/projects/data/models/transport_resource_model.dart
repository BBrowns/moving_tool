import 'package:moving_tool_flutter/features/projects/domain/entities/transport_resource.dart';

class TransportResourceModel extends TransportResource {
  TransportResourceModel({
    required super.id,
    required super.projectId,
    required super.name,
    required super.type,
    required super.capacity,
    required super.weatherSensitive,
    required super.costPerHour,
  });

  factory TransportResourceModel.fromEntity(TransportResource entity) {
    return TransportResourceModel(
      id: entity.id,
      projectId: entity.projectId,
      name: entity.name,
      type: entity.type,
      capacity: entity.capacity,
      weatherSensitive: entity.weatherSensitive,
      costPerHour: entity.costPerHour,
    );
  }

  factory TransportResourceModel.fromJson(Map<String, dynamic> json) {
    return TransportResourceModel(
      id: json['id'] as String,
      projectId: json['projectId'] as String? ?? 'p1', // Default for migration
      name: json['name'] as String,
      type: TransportType.values.firstWhere(
        (e) => e.name == (json['type'] as String),
        orElse: () => TransportType.car,
      ),
      capacity: TransportCapacity.values.firstWhere(
        (e) => e.name == (json['capacity'] as String),
        orElse: () => TransportCapacity.medium,
      ),
      weatherSensitive: json['weatherSensitive'] as bool? ?? false,
      costPerHour: (json['costPerHour'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'type': type.name,
      'capacity': capacity.name,
      'weatherSensitive': weatherSensitive,
      'costPerHour': costPerHour,
    };
  }
}
