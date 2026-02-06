import 'package:moving_tool_flutter/features/assets/domain/entities/asset.dart';

/// Repository interface for Asset operations
abstract class AssetRepository {
  /// Get all assets for a project
  Future<List<Asset>> getAssets(String projectId);

  /// Get a single asset by ID
  Future<Asset?> getAsset(String id);

  /// Save or update an asset
  Future<void> saveAsset(Asset asset);

  /// Delete an asset
  Future<void> deleteAsset(String id);

  /// Get assets by room
  Future<List<Asset>> getAssetsByRoom(String projectId, String roomId);

  /// Get assets with expiring warranties (within days)
  Future<List<Asset>> getExpiringWarranties(
    String projectId, {
    int withinDays = 30,
  });

  /// Search assets by name or category
  Future<List<Asset>> searchAssets(String projectId, String query);
}
