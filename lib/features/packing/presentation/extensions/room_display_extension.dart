import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/room.dart';

extension RoomDisplay on Room {
  IconData get iconData {
    switch (icon) {
      case '🛋️':
        return Icons.chair_rounded;
      case '🛏️':
        return Icons.bed_rounded;
      case '🍳':
        return Icons.kitchen_rounded;
      case '🚿':
        return Icons.shower_rounded;
      case '👶':
        return Icons.child_care_rounded;
      case '🧑‍💻':
        return Icons.computer_rounded;
      case '📦':
        return Icons.inventory_2_rounded;
      case '🔧':
        return Icons.build_rounded;
      default:
        return Icons.weekend_rounded;
    }
  }

  Color get uiColor {
    try {
      final buffer = StringBuffer();
      if (color.length == 6 || color.length == 7) buffer.write('ff');
      buffer.write(color.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
}
