import 'package:flutter/material.dart';

/// Type of service contract.
enum ContractType {
  internet,
  energy,
  gas,
  water,
  rent,
  insurance,
  subscription,
  other,
}

extension ContractTypeExtension on ContractType {
  String get label {
    switch (this) {
      case ContractType.internet:
        return 'Internet';
      case ContractType.energy:
        return 'Energie';
      case ContractType.gas:
        return 'Gas';
      case ContractType.water:
        return 'Water';
      case ContractType.rent:
        return 'Huur';
      case ContractType.insurance:
        return 'Verzekering';
      case ContractType.subscription:
        return 'Abonnement';
      case ContractType.other:
        return 'Overig';
    }
  }

  IconData get icon {
    switch (this) {
      case ContractType.internet:
        return Icons.wifi;
      case ContractType.energy:
        return Icons.bolt;
      case ContractType.gas:
        return Icons.local_fire_department;
      case ContractType.water:
        return Icons.water_drop;
      case ContractType.rent:
        return Icons.home;
      case ContractType.insurance:
        return Icons.security;
      case ContractType.subscription:
        return Icons.subscriptions;
      case ContractType.other:
        return Icons.description;
    }
  }
}

/// A service contract with provider, dates, and notice period.
class ServiceContract {
  const ServiceContract({
    required this.id,
    required this.projectId,
    required this.type,
    required this.provider,
    required this.startDate,
    required this.createdAt,
    this.endDate,
    this.noticePeriodDays = 30,
    this.monthlyCost,
    this.contractNumber,
    this.notes = '',
    this.documentUrl,
  });

  final String id;
  final String projectId;
  final ContractType type;
  final String provider;
  final DateTime startDate;
  final DateTime? endDate;
  final int noticePeriodDays;
  final double? monthlyCost;
  final String? contractNumber;
  final String notes;
  final String? documentUrl;
  final DateTime createdAt;

  /// Date by which you must cancel to avoid auto-renewal.
  DateTime? get cancelByDate {
    if (endDate == null) return null;
    return endDate!.subtract(Duration(days: noticePeriodDays));
  }

  /// Days until cancellation deadline.
  int? get daysUntilCancelDeadline {
    if (cancelByDate == null) return null;
    return cancelByDate!.difference(DateTime.now()).inDays;
  }

  /// Whether the contract is currently active.
  bool get isActive {
    final now = DateTime.now();
    if (endDate == null) return now.isAfter(startDate);
    return now.isAfter(startDate) && now.isBefore(endDate!);
  }

  /// Whether cancellation deadline is approaching (within 30 days).
  bool get isDeadlineApproaching {
    final days = daysUntilCancelDeadline;
    return days != null && days <= 30 && days > 0;
  }

  ServiceContract copyWith({
    ContractType? type,
    String? provider,
    DateTime? startDate,
    DateTime? endDate,
    int? noticePeriodDays,
    double? monthlyCost,
    String? contractNumber,
    String? notes,
    String? documentUrl,
  }) {
    return ServiceContract(
      id: id,
      projectId: projectId,
      type: type ?? this.type,
      provider: provider ?? this.provider,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      noticePeriodDays: noticePeriodDays ?? this.noticePeriodDays,
      monthlyCost: monthlyCost ?? this.monthlyCost,
      contractNumber: contractNumber ?? this.contractNumber,
      notes: notes ?? this.notes,
      documentUrl: documentUrl ?? this.documentUrl,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'type': type.index,
    'provider': provider,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'noticePeriodDays': noticePeriodDays,
    'monthlyCost': monthlyCost,
    'contractNumber': contractNumber,
    'notes': notes,
    'documentUrl': documentUrl,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ServiceContract.fromJson(Map<String, dynamic> json) {
    return ServiceContract(
      id: json['id'] as String,
      projectId: json['projectId'] as String,
      type: ContractType.values[json['type'] as int],
      provider: json['provider'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      noticePeriodDays: json['noticePeriodDays'] as int? ?? 30,
      monthlyCost: (json['monthlyCost'] as num?)?.toDouble(),
      contractNumber: json['contractNumber'] as String?,
      notes: json['notes'] as String? ?? '',
      documentUrl: json['documentUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
