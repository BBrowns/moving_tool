// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_vault_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(contractRepository)
final contractRepositoryProvider = ContractRepositoryProvider._();

final class ContractRepositoryProvider
    extends
        $FunctionalProvider<
          ContractRepository,
          ContractRepository,
          ContractRepository
        >
    with $Provider<ContractRepository> {
  ContractRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contractRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contractRepositoryHash();

  @$internal
  @override
  $ProviderElement<ContractRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContractRepository create(Ref ref) {
    return contractRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContractRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContractRepository>(value),
    );
  }
}

String _$contractRepositoryHash() =>
    r'f1eaf478cf2e09c076ebb10a658ba074218f454d';

@ProviderFor(metricRepository)
final metricRepositoryProvider = MetricRepositoryProvider._();

final class MetricRepositoryProvider
    extends
        $FunctionalProvider<
          MetricRepository,
          MetricRepository,
          MetricRepository
        >
    with $Provider<MetricRepository> {
  MetricRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metricRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metricRepositoryHash();

  @$internal
  @override
  $ProviderElement<MetricRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MetricRepository create(Ref ref) {
    return metricRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MetricRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MetricRepository>(value),
    );
  }
}

String _$metricRepositoryHash() => r'ce37c8b42bf0dffc3e6de0132c148538b981f22a';

@ProviderFor(ContractsNotifier)
final contractsProvider = ContractsNotifierProvider._();

final class ContractsNotifierProvider
    extends $AsyncNotifierProvider<ContractsNotifier, List<ServiceContract>> {
  ContractsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contractsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contractsNotifierHash();

  @$internal
  @override
  ContractsNotifier create() => ContractsNotifier();
}

String _$contractsNotifierHash() => r'546c827555c692452c3438ea308681f31c7561c9';

abstract class _$ContractsNotifier
    extends $AsyncNotifier<List<ServiceContract>> {
  FutureOr<List<ServiceContract>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ServiceContract>>, List<ServiceContract>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ServiceContract>>,
                List<ServiceContract>
              >,
              AsyncValue<List<ServiceContract>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MetricsNotifier)
final metricsProvider = MetricsNotifierProvider._();

final class MetricsNotifierProvider
    extends $AsyncNotifierProvider<MetricsNotifier, List<MetricLog>> {
  MetricsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'metricsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$metricsNotifierHash();

  @$internal
  @override
  MetricsNotifier create() => MetricsNotifier();
}

String _$metricsNotifierHash() => r'2c2c585b3124a8feea22c0004d72c38eba0c1722';

abstract class _$MetricsNotifier extends $AsyncNotifier<List<MetricLog>> {
  FutureOr<List<MetricLog>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<MetricLog>>, List<MetricLog>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<MetricLog>>, List<MetricLog>>,
              AsyncValue<List<MetricLog>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Contracts with approaching deadlines (within 30 days)

@ProviderFor(urgentContracts)
final urgentContractsProvider = UrgentContractsProvider._();

/// Contracts with approaching deadlines (within 30 days)

final class UrgentContractsProvider
    extends
        $FunctionalProvider<
          List<ServiceContract>,
          List<ServiceContract>,
          List<ServiceContract>
        >
    with $Provider<List<ServiceContract>> {
  /// Contracts with approaching deadlines (within 30 days)
  UrgentContractsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urgentContractsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urgentContractsHash();

  @$internal
  @override
  $ProviderElement<List<ServiceContract>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ServiceContract> create(Ref ref) {
    return urgentContracts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ServiceContract> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ServiceContract>>(value),
    );
  }
}

String _$urgentContractsHash() => r'ab883890396826e5f5f6bfa01f184d6185ab2099';

/// Active contracts count

@ProviderFor(activeContractsCount)
final activeContractsCountProvider = ActiveContractsCountProvider._();

/// Active contracts count

final class ActiveContractsCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Active contracts count
  ActiveContractsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeContractsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeContractsCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return activeContractsCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$activeContractsCountHash() =>
    r'3bcd342ad0d706c5a9f01533b53114f77bf0689f';

/// Total monthly costs

@ProviderFor(totalMonthlyCosts)
final totalMonthlyCostsProvider = TotalMonthlyCostsProvider._();

/// Total monthly costs

final class TotalMonthlyCostsProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Total monthly costs
  TotalMonthlyCostsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalMonthlyCostsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalMonthlyCostsHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return totalMonthlyCosts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$totalMonthlyCostsHash() => r'60176f697a7ee93ce05f99760e4c3f23ba3355ad';
