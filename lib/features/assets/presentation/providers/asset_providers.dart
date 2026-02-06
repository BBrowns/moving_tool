import 'package:moving_tool_flutter/features/assets/data/repositories/asset_repository_impl.dart';
import 'package:moving_tool_flutter/features/assets/domain/entities/asset.dart';
import 'package:moving_tool_flutter/features/assets/domain/repositories/asset_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'asset_providers.g.dart';

const _uuid = Uuid();

// ============================================================================
// Repository Provider
// ============================================================================

@Riverpod(keepAlive: true)
AssetRepository assetRepository(Ref ref) {
  return AssetRepositoryImpl();
}

// ============================================================================
// Assets Notifier
// ============================================================================

@Riverpod(keepAlive: true)
class AssetsNotifier extends _$AssetsNotifier {
  late final AssetRepository repository;
  String? _currentProjectId;

  @override
  List<Asset> build() {
    repository = ref.watch(assetRepositoryProvider);
    return [];
  }

  /// Load assets for a specific project
  Future<void> loadForProject(String projectId) async {
    _currentProjectId = projectId;
    state = await repository.getAssets(projectId);
  }

  /// Add a new asset
  Future<Asset> add({
    required String projectId,
    required String name,
    required DateTime purchaseDate,
    AssetCategory? category,
    double? purchasePrice,
    String? roomId,
    DateTime? warrantyExpiry,
    String? brand,
    String? model,
    String? serialNumber,
    String? notes,
    String? linkedShoppingItemId,
  }) async {
    final asset = Asset(
      id: _uuid.v4(),
      projectId: projectId,
      name: name,
      category: category,
      purchaseDate: purchaseDate,
      purchasePrice: purchasePrice,
      currentValue: purchasePrice, // Initially same as purchase price
      roomId: roomId,
      warrantyExpiry: warrantyExpiry,
      brand: brand,
      model: model,
      serialNumber: serialNumber,
      notes: notes,
      linkedShoppingItemId: linkedShoppingItemId,
      createdAt: DateTime.now(),
    );

    await repository.saveAsset(asset);
    state = [...state, asset];
    return asset;
  }

  /// Update an existing asset
  Future<void> update(Asset asset) async {
    await repository.saveAsset(asset);
    state = state.map((a) => a.id == asset.id ? asset : a).toList();
  }

  /// Delete an asset
  Future<void> delete(String id) async {
    await repository.deleteAsset(id);
    state = state.where((a) => a.id != id).toList();
  }

  /// Get assets with expiring warranties
  Future<List<Asset>> getExpiringWarranties({int withinDays = 30}) async {
    if (_currentProjectId == null) return [];
    return repository.getExpiringWarranties(
      _currentProjectId!,
      withinDays: withinDays,
    );
  }
}

// ============================================================================
// Filtered Assets Providers
// ============================================================================

/// Provider for assets filtered by room
@riverpod
List<Asset> assetsByRoom(Ref ref, String roomId) {
  final assets = ref.watch(assetsProvider);
  return assets.where((a) => a.roomId == roomId).toList();
}

/// Provider for assets filtered by category (pass category.name as String)
@riverpod
List<Asset> assetsByCategory(Ref ref, String categoryName) {
  final assets = ref.watch(assetsProvider);
  return assets.where((a) => a.category?.name == categoryName).toList();
}

/// Provider for total asset value
@riverpod
double totalAssetValue(Ref ref) {
  final assets = ref.watch(assetsProvider);
  return assets.fold(0.0, (sum, a) => sum + (a.currentValue ?? 0));
}

/// Provider for assets with expiring warranties (within 30 days)
@riverpod
List<Asset> expiringWarranties(Ref ref) {
  final assets = ref.watch(assetsProvider);
  final cutoff = DateTime.now().add(const Duration(days: 30));
  final now = DateTime.now();

  return assets.where((a) {
    if (a.warrantyExpiry == null) return false;
    return a.warrantyExpiry!.isBefore(cutoff) && a.warrantyExpiry!.isAfter(now);
  }).toList()..sort((a, b) => a.warrantyExpiry!.compareTo(b.warrantyExpiry!));
}
