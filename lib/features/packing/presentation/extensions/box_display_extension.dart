import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/packing/domain/entities/packing_box.dart';

extension BoxStatusDisplay on BoxStatus {
  String get label {
    switch (this) {
      case BoxStatus.empty:
        return 'Leeg';
      case BoxStatus.packing:
        return 'Bezig';
      case BoxStatus.packed:
        return 'Ingepakt';
      case BoxStatus.moved:
        return 'Verhuisd';
      case BoxStatus.unpacked:
        return 'Uitgepakt';
    }
  }

  IconData get icon {
    switch (this) {
      case BoxStatus.empty:
        return Icons.check_box_outline_blank_rounded;
      case BoxStatus.packing:
        return Icons.hourglass_empty_rounded;
      case BoxStatus.packed:
        return Icons.check_circle_rounded;
      case BoxStatus.moved:
        return Icons.local_shipping_rounded;
      case BoxStatus.unpacked:
        return Icons.celebration_rounded;
    }
  }

  Color get color {
    switch (this) {
      case BoxStatus.empty:
        return Colors.grey;
      case BoxStatus.packing:
        return Colors.blue;
      case BoxStatus.packed:
        return Colors.green;
      case BoxStatus.moved:
        return Colors.purple;
      case BoxStatus.unpacked:
        return Colors.orange;
    }
  }
}

extension PackingBoxDisplay on PackingBox {
  IconData get displayIcon {
    if (status == BoxStatus.packed) return Icons.check_circle;
    if (isFragile) return Icons.broken_image_outlined;
    return status.icon;
  }

  Color get displayColor {
    if (status == BoxStatus.packed) return Colors.green;
    if (isFragile) return AppTheme.error;
    return status.color;
  }
}
