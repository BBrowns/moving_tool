import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moving_tool_flutter/features/assets/domain/entities/asset.dart';
import 'package:moving_tool_flutter/features/assets/domain/repositories/asset_repository.dart';

/// Local implementation of AssetRepository using SharedPreferences
class AssetRepositoryImpl implements AssetRepository {
  static const String _storageKey = 'assets';

  Future<List<Asset>> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    if (data == null) return [];

    final list = jsonDecode(data) as List;
    return list
        .map((json) => Asset.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<Asset> assets) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(assets.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }

  @override
  Future<List<Asset>> getAssets(String projectId) async {
    final all = await _loadAll();
    return all.where((a) => a.projectId == projectId).toList();
  }

  @override
  Future<Asset?> getAsset(String id) async {
    final all = await _loadAll();
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveAsset(Asset asset) async {
    final all = await _loadAll();
    final index = all.indexWhere((a) => a.id == asset.id);

    if (index >= 0) {
      all[index] = asset;
    } else {
      all.add(asset);
    }

    await _saveAll(all);
  }

  @override
  Future<void> deleteAsset(String id) async {
    final all = await _loadAll();
    all.removeWhere((a) => a.id == id);
    await _saveAll(all);
  }

  @override
  Future<List<Asset>> getAssetsByRoom(String projectId, String roomId) async {
    final projectAssets = await getAssets(projectId);
    return projectAssets.where((a) => a.roomId == roomId).toList();
  }

  @override
  Future<List<Asset>> getExpiringWarranties(
    String projectId, {
    int withinDays = 30,
  }) async {
    final projectAssets = await getAssets(projectId);
    final cutoff = DateTime.now().add(Duration(days: withinDays));

    return projectAssets.where((a) {
      if (a.warrantyExpiry == null) return false;
      return a.warrantyExpiry!.isBefore(cutoff) &&
          a.warrantyExpiry!.isAfter(DateTime.now());
    }).toList()..sort((a, b) => a.warrantyExpiry!.compareTo(b.warrantyExpiry!));
  }

  @override
  Future<List<Asset>> searchAssets(String projectId, String query) async {
    final projectAssets = await getAssets(projectId);
    final lowerQuery = query.toLowerCase();

    return projectAssets.where((a) {
      return a.name.toLowerCase().contains(lowerQuery) ||
          (a.category?.label.toLowerCase().contains(lowerQuery) ?? false) ||
          (a.brand?.toLowerCase().contains(lowerQuery) ?? false) ||
          (a.model?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }
}
