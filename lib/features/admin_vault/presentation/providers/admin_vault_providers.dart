import 'package:moving_tool_flutter/features/admin_vault/data/repositories/contract_repository.dart';
import 'package:moving_tool_flutter/features/admin_vault/data/repositories/metric_repository.dart';
import 'package:moving_tool_flutter/features/admin_vault/domain/entities/metric_log.dart';
import 'package:moving_tool_flutter/features/admin_vault/domain/entities/service_contract.dart';
import 'package:moving_tool_flutter/features/projects/presentation/providers/project_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'admin_vault_providers.g.dart';

const _uuid = Uuid();

// ============================================================================
// Repository Providers
// ============================================================================

@riverpod
ContractRepository contractRepository(Ref ref) {
  throw UnimplementedError('Override in ProviderScope');
}

@riverpod
MetricRepository metricRepository(Ref ref) {
  throw UnimplementedError('Override in ProviderScope');
}

// ============================================================================
// Contracts Notifier
// ============================================================================

@riverpod
class ContractsNotifier extends _$ContractsNotifier {
  @override
  Future<List<ServiceContract>> build() async {
    final project = ref.watch(projectProvider);
    if (project == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final repo = ContractRepositoryImpl(prefs);
    return repo.getContracts(project.id);
  }

  Future<void> addContract({
    required ContractType type,
    required String provider,
    required DateTime startDate,
    DateTime? endDate,
    int noticePeriodDays = 30,
    double? monthlyCost,
    String? contractNumber,
    String notes = '',
  }) async {
    final project = ref.read(projectProvider);
    if (project == null) return;

    final contract = ServiceContract(
      id: _uuid.v4(),
      projectId: project.id,
      type: type,
      provider: provider,
      startDate: startDate,
      endDate: endDate,
      noticePeriodDays: noticePeriodDays,
      monthlyCost: monthlyCost,
      contractNumber: contractNumber,
      notes: notes,
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    final repo = ContractRepositoryImpl(prefs);
    await repo.saveContract(contract);
    ref.invalidateSelf();
  }

  Future<void> updateContract(ServiceContract contract) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = ContractRepositoryImpl(prefs);
    await repo.saveContract(contract);
    ref.invalidateSelf();
  }

  Future<void> deleteContract(String contractId) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = ContractRepositoryImpl(prefs);
    await repo.deleteContract(contractId);
    ref.invalidateSelf();
  }
}

// ============================================================================
// Metrics Notifier
// ============================================================================

@riverpod
class MetricsNotifier extends _$MetricsNotifier {
  @override
  Future<List<MetricLog>> build() async {
    final project = ref.watch(projectProvider);
    if (project == null) return [];

    final prefs = await SharedPreferences.getInstance();
    final repo = MetricRepositoryImpl(prefs);
    return repo.getMetrics(project.id);
  }

  Future<void> addMetric({
    required MetricType type,
    required double value,
    DateTime? timestamp,
    String? customLabel,
    String? customUnit,
    String notes = '',
  }) async {
    final project = ref.read(projectProvider);
    if (project == null) return;

    final metric = MetricLog(
      id: _uuid.v4(),
      projectId: project.id,
      type: type,
      value: value,
      timestamp: timestamp ?? DateTime.now(),
      customLabel: customLabel,
      customUnit: customUnit,
      notes: notes,
    );

    final prefs = await SharedPreferences.getInstance();
    final repo = MetricRepositoryImpl(prefs);
    await repo.saveMetric(metric);
    ref.invalidateSelf();
  }

  Future<void> deleteMetric(String metricId) async {
    final prefs = await SharedPreferences.getInstance();
    final repo = MetricRepositoryImpl(prefs);
    await repo.deleteMetric(metricId);
    ref.invalidateSelf();
  }
}

// ============================================================================
// Filtered/Computed Providers
// ============================================================================

/// Contracts with approaching deadlines (within 30 days)
@riverpod
List<ServiceContract> urgentContracts(Ref ref) {
  final contractsAsync = ref.watch(contractsProvider);
  return contractsAsync.value
          ?.where((ServiceContract c) => c.isDeadlineApproaching)
          .toList() ??
      [];
}

/// Active contracts count
@riverpod
int activeContractsCount(Ref ref) {
  final contractsAsync = ref.watch(contractsProvider);
  return contractsAsync.value
          ?.where((ServiceContract c) => c.isActive)
          .length ??
      0;
}

/// Total monthly costs
@riverpod
double totalMonthlyCosts(Ref ref) {
  final contractsAsync = ref.watch(contractsProvider);
  final contracts = contractsAsync.value;
  if (contracts == null) return 0.0;
  return contracts
      .where((ServiceContract c) => c.isActive && c.monthlyCost != null)
      .fold(0.0, (double sum, ServiceContract c) => sum + c.monthlyCost!);
}
