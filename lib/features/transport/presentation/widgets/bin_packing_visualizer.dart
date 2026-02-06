import 'dart:math' as math;
import 'package:ditredi/ditredi.dart';
import 'package:flutter/material.dart';
import 'package:moving_tool_flutter/core/models/item_dimensions.dart';
import 'package:moving_tool_flutter/features/transport/application/bin_packing_service.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class BinPackingVisualizer extends StatefulWidget {
  const BinPackingVisualizer({
    required this.containerDimensions,
    required this.packedItems,
    super.key,
  });

  final ItemDimensions containerDimensions;
  final List<PackedItem> packedItems;

  @override
  State<BinPackingVisualizer> createState() => _BinPackingVisualizerState();
}

class _BinPackingVisualizerState extends State<BinPackingVisualizer> {
  final _controller = DiTreDiController(
    rotationX: -20,
    rotationY: 30,
    light: vector.Vector3(-10, -10, 10),
  );

  @override
  Widget build(BuildContext context) {
    return DiTreDi(
      figures: [
        // Container Wireframe
        ..._buildContainerWireframe(),
        // Axis lines for reference (optional)
        ..._buildAxes(),
        // Packed Items
        ..._buildPackedItems(),
      ],
      controller: _controller,
      config: const DiTreDiConfig(supportZIndex: true, perspective: true),
    );
  }

  Iterable<Line3D> _buildContainerWireframe() {
    // Draw edges of the container box
    final w = widget.containerDimensions.widthCm ?? 100;
    final h = widget.containerDimensions.heightCm ?? 100;
    final d = widget.containerDimensions.depthCm ?? 100;

    // Define vertices
    final v000 = vector.Vector3(0, 0, 0);
    final v100 = vector.Vector3(w, 0, 0);
    final v010 = vector.Vector3(0, h, 0);
    final v001 = vector.Vector3(0, 0, d);
    final v110 = vector.Vector3(w, h, 0);
    final v101 = vector.Vector3(w, 0, d);
    final v011 = vector.Vector3(0, h, d);
    final v111 = vector.Vector3(w, h, d);

    final color = Colors.grey.withValues(alpha: 0.5);
    const width = 2.0;

    return [
      // Bottom face
      Line3D(v000, v100, color: color, width: width),
      Line3D(v100, v101, color: color, width: width),
      Line3D(v101, v001, color: color, width: width),
      Line3D(v001, v000, color: color, width: width),
      // Top face
      Line3D(v010, v110, color: color, width: width),
      Line3D(v110, v111, color: color, width: width),
      Line3D(v111, v011, color: color, width: width),
      Line3D(v011, v010, color: color, width: width),
      // Verticals
      Line3D(v000, v010, color: color, width: width),
      Line3D(v100, v110, color: color, width: width),
      Line3D(v101, v111, color: color, width: width),
      Line3D(v001, v011, color: color, width: width),
    ];
  }

  Iterable<Line3D> _buildAxes() {
    return [
      Line3D(
        vector.Vector3(0, 0, 0),
        vector.Vector3(50, 0, 0),
        color: Colors.red,
        width: 3,
      ), // X
      Line3D(
        vector.Vector3(0, 0, 0),
        vector.Vector3(0, 50, 0),
        color: Colors.green,
        width: 3,
      ), // Y
      Line3D(
        vector.Vector3(0, 0, 0),
        vector.Vector3(0, 0, 50),
        color: Colors.blue,
        width: 3,
      ), // Z
    ];
  }

  Iterable<Cube3D> _buildPackedItems() {
    return widget.packedItems.map((item) {
      final dim = item.dimensions;
      final w = dim.widthCm ?? 0;
      final h = dim.heightCm ?? 0;
      final d = dim.depthCm ?? 0;

      final pos = item.position;

      // DiTreDi Cube3D takes a center position.
      // Our packing service uses bottom-left-back corner (0,0,0 relative to item).
      // So we need to shift the center.
      final center = vector.Vector3(
        pos.x + w / 2,
        pos.y + h / 2,
        pos.z + d / 2,
      );

      // Generate a color based on hash or index?
      // Need a way to distinguish. Random color for now.
      final color = Color(
        (math.Random(dim.hashCode).nextDouble() * 0xFFFFFF).toInt(),
      ).withValues(alpha: 1.0);

      return Cube3D(
        w,
        vector.Vector3(center.x, center.y, center.z),
        color: color,
      );
    });
  }
}
