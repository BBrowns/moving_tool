enum TransportType { legs, car, van, truck, trailer }

enum TransportCapacity {
  small, // e.g. backpack, bike
  medium, // e.g. car trunk
  large, // e.g. van
  extraLarge, // e.g. truck
}

class TransportResource {
  final String id;
  final String projectId;
  final String name;
  final TransportType type;
  final TransportCapacity capacity;
  final bool weatherSensitive;
  final double costPerHour;

  TransportResource({
    required this.id,
    required this.projectId,
    required this.name,
    required this.type,
    required this.capacity,
    required this.weatherSensitive,
    required this.costPerHour,
  });

  // Basic validation or helper methods could go here

  // Create a copyWith method
  TransportResource copyWith({
    String? id,
    String? projectId,
    String? name,
    TransportType? type,
    TransportCapacity? capacity,
    bool? weatherSensitive,
    double? costPerHour,
  }) {
    return TransportResource(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      weatherSensitive: weatherSensitive ?? this.weatherSensitive,
      costPerHour: costPerHour ?? this.costPerHour,
    );
  }
}
