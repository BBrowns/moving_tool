class Room {

  const Room({
    required this.id,
    required this.name,
    required this.createdAt, this.icon = '📦',
    this.color = '#6366F1',
    this.budget,
    this.squareMeters = 0,
    this.notes = '',
  });
  final String id;
  final String name;
  final String icon;
  final String color;
  final double? budget;
  final double squareMeters;
  final String notes;
  final DateTime createdAt;

  Room copyWith({
    String? name,
    String? icon,
    String? color,
    double? budget,
    double? squareMeters,
    String? notes,
  }) {
    return Room(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budget: budget ?? this.budget,
      squareMeters: squareMeters ?? this.squareMeters,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}
