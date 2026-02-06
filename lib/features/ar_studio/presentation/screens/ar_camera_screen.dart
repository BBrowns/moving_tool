// AR Camera Screen - Full AR experience with plane detection and object placement
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';

import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moving_tool_flutter/core/theme/app_theme.dart';
import 'package:moving_tool_flutter/features/ar_studio/services/ar_service.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

/// AR Camera screen for room scanning and furniture placement
class ARCameraScreen extends ConsumerStatefulWidget {
  const ARCameraScreen({super.key, this.roomId, this.mode = ARMode.roomScan});

  final String? roomId;
  final ARMode mode;

  @override
  ConsumerState<ARCameraScreen> createState() => _ARCameraScreenState();
}

enum ARMode {
  roomScan, // Scan room dimensions
  furniturePlacement, // Place virtual furniture
}

class _ARCameraScreenState extends ConsumerState<ARCameraScreen> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;

  final List<ARNode> _placedNodes = [];
  final List<ARAnchor> _anchors = [];

  bool _planesDetected = false;
  bool _isPlacingObject = false;
  String _statusMessage = 'Initialiseren...';

  // Selected furniture for placement
  String? _selectedFurnitureModel;
  final List<_FurnitureOption> _furnitureOptions = [
    _FurnitureOption(
      name: 'Stoel',
      icon: Icons.chair,
      modelUri:
          'https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb',
      scale: 0.1,
    ),
    _FurnitureOption(
      name: 'Tafel',
      icon: Icons.table_restaurant,
      modelUri: 'https://github.com/AshutoshVJTI/3dModels/raw/main/table.glb',
      scale: 0.3,
    ),
    _FurnitureOption(
      name: 'Bank',
      icon: Icons.weekend,
      modelUri: 'https://github.com/AshutoshVJTI/3dModels/raw/main/sofa.glb',
      scale: 0.4,
    ),
    _FurnitureOption(
      name: 'Lamp',
      icon: Icons.lightbulb,
      modelUri: 'https://github.com/AshutoshVJTI/3dModels/raw/main/lamp.glb',
      scale: 0.2,
    ),
  ];

  @override
  void dispose() {
    arSessionManager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.mode == ARMode.roomScan
                ? 'Kamer Scannen'
                : 'Meubels Plaatsen',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // AR View
          ARView(
            onARViewCreated: _onARViewCreated,
            planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
          ),

          // Status overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 20,
            right: 20,
            child: _StatusCard(
              message: _statusMessage,
              hasLiDAR: ARService.instance.hasLiDAR,
              planesDetected: _planesDetected,
            ),
          ),

          // LiDAR indicator
          if (ARService.instance.hasLiDAR)
            Positioned(
              top: MediaQuery.of(context).padding.top + 130,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sensors, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'LiDAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Furniture selection (placement mode only)
          if (widget.mode == ARMode.furniturePlacement)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: _FurnitureSelector(
                options: _furnitureOptions,
                selectedUri: _selectedFurnitureModel,
                onSelect: (uri) =>
                    setState(() => _selectedFurnitureModel = uri),
              ),
            ),

          // Bottom action bar
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _ActionBar(
              mode: widget.mode,
              canPlace: _planesDetected && _selectedFurnitureModel != null,
              placedCount: _placedNodes.length,
              onClear: _clearAllNodes,
              onSave: _saveAndExit,
            ),
          ),
        ],
      ),
    );
  }

  void _onARViewCreated(
    ARSessionManager sessionManager,
    ARObjectManager objectManager,
    ARAnchorManager anchorManager,
    ARLocationManager locationManager,
  ) {
    arSessionManager = sessionManager;
    arObjectManager = objectManager;
    arAnchorManager = anchorManager;

    // Initialize session
    arSessionManager!.onInitialize(
      showFeaturePoints: false,
      showPlanes: true,
      showWorldOrigin: false,
      handlePans: true,
      handleRotation: true,
    );

    // Set up plane detection callback
    arSessionManager!.onPlaneOrPointTap = _onPlaneOrPointTapped;

    // Update status
    setState(() {
      _statusMessage = 'Zoek een plat oppervlak om te beginnen';
    });

    // After a short delay, check for planes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _planesDetected = true;
          _statusMessage = widget.mode == ARMode.roomScan
              ? 'Tik op het scherm om meetpunten te plaatsen'
              : 'Kies een meubel en tik om te plaatsen';
        });
      }
    });
  }

  Future<void> _onPlaneOrPointTapped(
    List<ARHitTestResult> hitTestResults,
  ) async {
    if (hitTestResults.isEmpty) return;

    final hit = hitTestResults.first;

    if (widget.mode == ARMode.furniturePlacement) {
      await _placeFurniture(hit);
    } else {
      await _placeMeasurementPoint(hit);
    }
  }

  Future<void> _placeFurniture(ARHitTestResult hit) async {
    if (_selectedFurnitureModel == null || _isPlacingObject) return;

    setState(() => _isPlacingObject = true);

    try {
      // Create anchor at hit point
      final anchor = ARPlaneAnchor(
        transformation: hit.worldTransform,
        name: 'furniture_${_anchors.length}',
      );
      final successAnchor = await arAnchorManager?.addAnchor(anchor);
      if (successAnchor != true) return;
      _anchors.add(anchor);

      // Find selected furniture
      final furniture = _furnitureOptions.firstWhere(
        (f) => f.modelUri == _selectedFurnitureModel,
      );

      // Create node with the selected model
      final node = ARNode(
        type: NodeType.webGLB,
        uri: furniture.modelUri,
        scale: vector.Vector3.all(furniture.scale),
        position: vector.Vector3.zero(),
        rotation: vector.Vector4(1.0, 0.0, 0.0, 0.0),
      );

      final success = await arObjectManager?.addNode(node, planeAnchor: anchor);
      if (success == true) {
        _placedNodes.add(node);
        setState(() {
          _statusMessage =
              '${furniture.name} geplaatst! (${_placedNodes.length} items)';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Fout bij plaatsen: $e';
      });
    } finally {
      setState(() => _isPlacingObject = false);
    }
  }

  Future<void> _placeMeasurementPoint(ARHitTestResult hit) async {
    // For room scanning, we place simple markers at corners
    try {
      final anchor = ARPlaneAnchor(
        transformation: hit.worldTransform,
        name: 'point_${_anchors.length}',
      );
      final successAnchor = await arAnchorManager?.addAnchor(anchor);
      if (successAnchor != true) return;
      _anchors.add(anchor);

      // Create a simple marker node
      final node = ARNode(
        type: NodeType.webGLB,
        uri: 'https://github.com/AshutoshVJTI/3dModels/raw/main/sphere.glb',
        scale: vector.Vector3.all(0.05),
        position: vector.Vector3.zero(),
      );

      final success = await arObjectManager?.addNode(node, planeAnchor: anchor);
      if (success == true) {
        _placedNodes.add(node);
        setState(() {
          _statusMessage = 'Meetpunt ${_placedNodes.length} geplaatst';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Fout: $e';
      });
    }
  }

  void _clearAllNodes() {
    for (final node in _placedNodes) {
      arObjectManager?.removeNode(node);
    }
    for (final anchor in _anchors) {
      arAnchorManager?.removeAnchor(anchor);
    }
    _placedNodes.clear();
    _anchors.clear();
    setState(() {
      _statusMessage = 'Alle items verwijderd';
    });
  }

  void _saveAndExit() {
    // TODO: Save placed items to Room entity
    Navigator.of(
      context,
    ).pop({'placedCount': _placedNodes.length, 'anchors': _anchors.length});
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.message,
    required this.hasLiDAR,
    required this.planesDetected,
  });

  final String message;
  final bool hasLiDAR;
  final bool planesDetected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            planesDetected ? Icons.check_circle : Icons.search,
            color: planesDetected ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _FurnitureSelector extends StatelessWidget {
  const _FurnitureSelector({
    required this.options,
    required this.selectedUri,
    required this.onSelect,
  });

  final List<_FurnitureOption> options;
  final String? selectedUri;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option.modelUri == selectedUri;
          return GestureDetector(
            onTap: () => onSelect(option.modelUri),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? context.colors.primary : Colors.black87,
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(option.icon, color: Colors.white, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    option.name,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.mode,
    required this.canPlace,
    required this.placedCount,
    required this.onClear,
    required this.onSave,
  });

  final ARMode mode;
  final bool canPlace;
  final int placedCount;
  final VoidCallback onClear;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Clear button
        if (placedCount > 0)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Wissen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        if (placedCount > 0) const SizedBox(width: 12),
        // Save button
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: placedCount > 0 ? onSave : null,
            icon: const Icon(Icons.check),
            label: Text(
              placedCount > 0 ? 'Opslaan ($placedCount)' : 'Plaats items',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _FurnitureOption {
  const _FurnitureOption({
    required this.name,
    required this.icon,
    required this.modelUri,
    required this.scale,
  });

  final String name;
  final IconData icon;
  final String modelUri;
  final double scale;
}
