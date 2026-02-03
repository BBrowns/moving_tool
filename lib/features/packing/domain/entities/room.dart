import 'package:flutter/material.dart';

class Room {
  final String id;
  final String name;
  final String icon;
  final String color;
  final double? budget;
  final double squareMeters;
  final String notes;
  final DateTime createdAt;

  const Room({
    required this.id,
    required this.name,
    this.icon = '📦',
    this.color = '#6366F1',
    this.budget,
    this.squareMeters = 0,
    this.notes = '',
    required this.createdAt,
  });

  IconData get iconData {
    switch (icon) {
      case '🛋️': return Icons.chair_rounded;
      case '🛏️': return Icons.bed_rounded;
      case '🍳': return Icons.kitchen_rounded;
      case '🚿': return Icons.shower_rounded;
      case '👶': return Icons.child_care_rounded;
      case '🧑‍💻': return Icons.computer_rounded;
      case '📦': return Icons.inventory_2_rounded;
      case '🔧': return Icons.build_rounded;
      default: return Icons.weekend_rounded;
    }
  }

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
