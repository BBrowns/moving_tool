/// Type of metric being logged.
enum MetricType {
  internetSpeed,
  energyUsage,
  waterUsage,
  gasUsage,
  temperature,
  humidity,
  custom,
}

extension MetricTypeExtension on MetricType {
  String get label {
    switch (this) {
      case MetricType.internetSpeed:
        return 'Internet Snelheid';
      case MetricType.energyUsage:
        return 'Stroomverbruik';
      case MetricType.waterUsage:
        return 'Waterverbruik';
      case MetricType.gasUsage:
        return 'Gasverbruik';
      case MetricType.temperature:
        return 'Temperatuur';
      case MetricType.humidity:
        return 'Luchtvochtigheid';
      case MetricType.custom:
        return 'Aangepast';
    }
  }

  String get unit {
    switch (this) {
      case MetricType.internetSpeed:
        return 'Mbps';
      case MetricType.energyUsage:
        return 'kWh';
      case MetricType.waterUsage:
        return 'm³';
      case MetricType.gasUsage:
        return 'm³';
      case MetricType.temperature:
        return '°C';
      case MetricType.humidity:
        return '%';
      case MetricType.custom:
        return '';
    }
  }
}

/// A single metric log entry for tracking periodic values.
class MetricLog {
  const MetricLog({
    required this.id,
    required this.projectId,
    required this.type,
    required this.value,
    required this.timestamp,
    this.customLabel,
    this.customUnit,
    this.notes = '',
  });

  final String id;
  final String projectId;
  final MetricType type;
  final double value;
  final DateTime timestamp;

  /// Custom label when type is MetricType.custom
  final String? customLabel;
  final String? customUnit;
  final String notes;

  String get displayLabel =>
      type == MetricType.custom ? (customLabel ?? 'Aangepast') : type.label;

  String get displayUnit =>
      type == MetricType.custom ? (customUnit ?? '') : type.unit;

  MetricLog copyWith({
    MetricType? type,
    double? value,
    DateTime? timestamp,
    String? customLabel,
    String? customUnit,
    String? notes,
  }) {
    return MetricLog(
      id: id,
      projectId: projectId,
      type: type ?? this.type,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
      customLabel: customLabel ?? this.customLabel,
      customUnit: customUnit ?? this.customUnit,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'type': type.index,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
    'customLabel': customLabel,
    'customUnit': customUnit,
    'notes': notes,
  };

  factory MetricLog.fromJson(Map<String, dynamic> json) {
    return MetricLog(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      type: MetricType.values[json['type'] as int],
      value: (json['value'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      customLabel: json['customLabel'] as String?,
      customUnit: json['customUnit'] as String?,
      notes: json['notes'] as String? ?? '',
    );
  }
}
