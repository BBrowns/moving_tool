import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moving_tool_flutter/features/admin_vault/domain/entities/metric_log.dart';

/// Repository interface for MetricLog persistence.
abstract class MetricRepository {
  Future<List<MetricLog>> getMetrics(String projectId, {MetricType? type});
  Future<void> saveMetric(MetricLog metric);
  Future<void> deleteMetric(String metricId);
}

/// SharedPreferences implementation of MetricRepository.
class MetricRepositoryImpl implements MetricRepository {
  MetricRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'metrics';

  @override
  Future<List<MetricLog>> getMetrics(
    String projectId, {
    MetricType? type,
  }) async {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return [];

    final list = jsonDecode(jsonStr) as List<dynamic>;
    var metrics = list
        .map((e) => MetricLog.fromJson(e as Map<String, dynamic>))
        .where((m) => m.projectId == projectId);

    if (type != null) {
      metrics = metrics.where((m) => m.type == type);
    }

    return metrics.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  @override
  Future<void> saveMetric(MetricLog metric) async {
    final metrics = await _getAllMetrics();
    final index = metrics.indexWhere((m) => m.id == metric.id);

    if (index >= 0) {
      metrics[index] = metric;
    } else {
      metrics.add(metric);
    }

    await _saveAll(metrics);
  }

  @override
  Future<void> deleteMetric(String metricId) async {
    final metrics = await _getAllMetrics();
    metrics.removeWhere((m) => m.id == metricId);
    await _saveAll(metrics);
  }

  Future<List<MetricLog>> _getAllMetrics() async {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return [];

    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => MetricLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<MetricLog> metrics) async {
    final jsonStr = jsonEncode(metrics.map((m) => m.toJson()).toList());
    await _prefs.setString(_key, jsonStr);
  }
}
