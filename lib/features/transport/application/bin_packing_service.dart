import 'package:moving_tool_flutter/core/models/item_dimensions.dart';
import 'package:vector_math/vector_math_64.dart';

class PackedItem {
  PackedItem({
    required this.dimensions,
    required this.position,
    this.isRotated = false,
  });

  final ItemDimensions dimensions;
  final Vector3 position; // Bottom-left-back corner
  final bool isRotated; // Simple rotation flag (swapping width/depth)
}

class BinPackingService {
  /// Packs items into a container using First Fit Decreasing algorithm.
  /// Returns a list of packed items with their positions.
  /// Items that don't fit are excluded from the result (or we could return them separately).
  List<PackedItem> packItems(
    List<ItemDimensions> items,
    ItemDimensions container,
  ) {
    // 1. Sort items by volume (descending)
    final sortedItems = List<ItemDimensions>.from(items)
      ..sort((a, b) => b.volumeM3.compareTo(a.volumeM3));

    final packedItems = <PackedItem>[];

    for (final item in sortedItems) {
      final position = _findPosition(item, packedItems, container);
      if (position != null) {
        packedItems.add(PackedItem(dimensions: item, position: position));
      } else {
        // Try rotating? (Swap width/depth)
        // For MVP, let's stick to simple orientation first.
        // We can add rotation logic later if needed.
        // If it doesn't fit, it's left out.
      }
    }

    return packedItems;
  }

  /// Finds the first valid position for the item.
  /// This is a simplified "Bottom-Left-Back" heuristic.
  /// We check potential placement points relative to already packed items.
  Vector3? _findPosition(
    ItemDimensions item,
    List<PackedItem> packedItems,
    ItemDimensions container,
  ) {
    if (packedItems.isEmpty) {
      // First item goes at (0,0,0) if it fits
      if (_fitsInContainer(item, Vector3.zero(), container)) {
        return Vector3.zero();
      }
      return null;
    }

    // Potential points: (0,0,0) and corners of existing items
    // We want to pack tightly.
    // A naive approach for "3D Bin Packing" is complex.
    // Let's implement a "Shelf" or "Layer" approach or a simple coordinate checking.
    // Given the complexity of true 3D packing, we'll use a brute-force check on "candidate points".
    // Candidate points are generated from the corners of packed items.

    final candidatePoints = <Vector3>{Vector3.zero()};

    for (final packed in packedItems) {
      final pos = packed.position;
      final dim = _getDimensions(packed);

      // Add points extending from this item
      candidatePoints.add(Vector3(pos.x + dim.x, pos.y, pos.z)); // Right
      candidatePoints.add(Vector3(pos.x, pos.y + dim.y, pos.z)); // Up
      candidatePoints.add(Vector3(pos.x, pos.y, pos.z + dim.z)); // Forward

      // Also potentially check alignment with other axes...
    }

    // Sort candidate points to prefer bottom-back-left (y, z, x priorities vary)
    // Let's verify y (height) last to stack up? Or y first?
    // Usually Y is up in 3D. let's assume Y is up.
    // X is width, Z is depth.
    // We prefer lower Y, then back Z, then left X.
    final sortedPoints = candidatePoints.toList()
      ..sort((a, b) {
        if (a.y != b.y) return a.y.compareTo(b.y);
        if (a.z != b.z) return a.z.compareTo(b.z);
        return a.x.compareTo(b.x);
      });

    for (final point in sortedPoints) {
      if (_fitsInContainer(item, point, container) &&
          !_overlapsAny(item, point, packedItems)) {
        return point;
      }
    }

    return null;
  }

  bool _fitsInContainer(
    ItemDimensions item,
    Vector3 pos,
    ItemDimensions container,
  ) {
    // Assuming container dimensions are in cm
    // item dimensions are in cm

    // Check boundaries
    if (pos.x + item.widthCm! > container.widthCm!) return false;
    if (pos.y + item.heightCm! > container.heightCm!) return false;
    if (pos.z + item.depthCm! > container.depthCm!) return false;

    return true;
  }

  bool _overlapsAny(
    ItemDimensions item,
    Vector3 pos,
    List<PackedItem> packedItems,
  ) {
    for (final packed in packedItems) {
      if (_intersect(item, pos, packed)) return true;
    }
    return false;
  }

  bool _intersect(ItemDimensions itemA, Vector3 posA, PackedItem packedB) {
    final dimB = _getDimensions(packedB);
    final posB = packedB.position;

    // AABB intersection check
    // A: [posA.x, posA.x + itemA.width]
    // B: [posB.x, posB.x + dimB.x]

    final aMinX = posA.x;
    final aMaxX = posA.x + itemA.widthCm!;
    final aMinY = posA.y;
    final aMaxY = posA.y + itemA.heightCm!;
    final aMinZ = posA.z;
    final aMaxZ = posA.z + itemA.depthCm!;

    final bMinX = posB.x;
    final bMaxX = posB.x + dimB.x;
    final bMinY = posB.y;
    final bMaxY = posB.y + dimB.y;
    final bMinZ = posB.z;
    final bMaxZ = posB.z + dimB.z;

    final xOverlap = aMinX < bMaxX && aMaxX > bMinX;
    final yOverlap = aMinY < bMaxY && aMaxY > bMinY;
    final zOverlap = aMinZ < bMaxZ && aMaxZ > bMinZ;

    return xOverlap && yOverlap && zOverlap;
  }

  Vector3 _getDimensions(PackedItem packed) {
    // If rotated, we might swap. For now assuming not rotated.
    return Vector3(
      packed.dimensions.widthCm!,
      packed.dimensions.heightCm!,
      packed.dimensions.depthCm!,
    );
  }
}
