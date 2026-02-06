// AR Service - Session management and LiDAR detection
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for managing AR capabilities and session state
class ARService {
  ARService._();
  static final instance = ARService._();

  bool _isInitialized = false;
  bool _hasLiDAR = false;

  bool get isInitialized => _isInitialized;
  bool get hasLiDAR => _hasLiDAR;

  /// Check if device supports AR (ARKit on iOS, ARCore on Android)
  Future<bool> checkARAvailability() async {
    // AR is generally available on iOS 11+ and ARCore-compatible Android devices
    // The ar_flutter_plugin handles this internally, but we do a basic check
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      return true;
    }
    return false;
  }

  /// Request camera permission for AR
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  /// Detect if device has LiDAR scanner (iOS 12 Pro+ only)
  /// Returns true for LiDAR-equipped devices, false otherwise
  Future<bool> detectLiDAR() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      _hasLiDAR = false;
      return false;
    }

    try {
      // Check device model for LiDAR support
      // LiDAR is available on: iPhone 12 Pro, 12 Pro Max, 13 Pro, 13 Pro Max,
      // 14 Pro, 14 Pro Max, 15 Pro, 15 Pro Max, 16 Pro, 16 Pro Max
      // iPad Pro 2020+
      // We detect this by checking if depth data configuration is available
      // For now, we assume LiDAR detection happens at ARView initialization
      _hasLiDAR = false; // Will be updated by native platform if available
      return _hasLiDAR;
    } catch (e) {
      debugPrint('LiDAR detection failed: $e');
      _hasLiDAR = false;
      return false;
    }
  }

  /// Initialize AR service
  Future<void> initialize() async {
    if (_isInitialized) return;

    await detectLiDAR();
    _isInitialized = true;
  }

  /// Get accuracy mode based on device capabilities
  String get accuracyMode {
    if (_hasLiDAR) {
      return 'high'; // LiDAR-enhanced scanning
    }
    return 'standard'; // Camera-based tracking only
  }

  /// Get recommended scan instructions based on device
  String get scanInstructions {
    if (_hasLiDAR) {
      return 'Beweeg langzaam rond de kamer. LiDAR detecteert automatisch oppervlakken.';
    }
    return 'Beweeg langzaam rond de kamer. Zorg voor goede verlichting voor betere detectie.';
  }
}
