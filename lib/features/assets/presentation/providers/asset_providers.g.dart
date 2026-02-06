// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(assetRepository)
final assetRepositoryProvider = AssetRepositoryProvider._();

final class AssetRepositoryProvider
    extends
        $FunctionalProvider<AssetRepository, AssetRepository, AssetRepository>
    with $Provider<AssetRepository> {
  AssetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetRepositoryHash();

  @$internal
  @override
  $ProviderElement<AssetRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AssetRepository create(Ref ref) {
    return assetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AssetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AssetRepository>(value),
    );
  }
}

String _$assetRepositoryHash() => r'c6c7b9ff9ffa782823fb70292b980b5750853f03';

@ProviderFor(AssetsNotifier)
final assetsProvider = AssetsNotifierProvider._();

final class AssetsNotifierProvider
    extends $NotifierProvider<AssetsNotifier, List<Asset>> {
  AssetsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'assetsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$assetsNotifierHash();

  @$internal
  @override
  AssetsNotifier create() => AssetsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Asset> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Asset>>(value),
    );
  }
}

String _$assetsNotifierHash() => r'b8bfe4ff0659f5551f0815d034afa28893f4db4a';

abstract class _$AssetsNotifier extends $Notifier<List<Asset>> {
  List<Asset> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Asset>, List<Asset>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Asset>, List<Asset>>,
              List<Asset>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for assets filtered by room

@ProviderFor(assetsByRoom)
final assetsByRoomProvider = AssetsByRoomFamily._();

/// Provider for assets filtered by room

final class AssetsByRoomProvider
    extends $FunctionalProvider<List<Asset>, List<Asset>, List<Asset>>
    with $Provider<List<Asset>> {
  /// Provider for assets filtered by room
  AssetsByRoomProvider._({
    required AssetsByRoomFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'assetsByRoomProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assetsByRoomHash();

  @override
  String toString() {
    return r'assetsByRoomProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Asset>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Asset> create(Ref ref) {
    final argument = this.argument as String;
    return assetsByRoom(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Asset> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Asset>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AssetsByRoomProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assetsByRoomHash() => r'605121dda4688749f841e34415b7572ee0742c99';

/// Provider for assets filtered by room

final class AssetsByRoomFamily extends $Family
    with $FunctionalFamilyOverride<List<Asset>, String> {
  AssetsByRoomFamily._()
    : super(
        retry: null,
        name: r'assetsByRoomProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for assets filtered by room

  AssetsByRoomProvider call(String roomId) =>
      AssetsByRoomProvider._(argument: roomId, from: this);

  @override
  String toString() => r'assetsByRoomProvider';
}

/// Provider for assets filtered by category (pass category.name as String)

@ProviderFor(assetsByCategory)
final assetsByCategoryProvider = AssetsByCategoryFamily._();

/// Provider for assets filtered by category (pass category.name as String)

final class AssetsByCategoryProvider
    extends $FunctionalProvider<List<Asset>, List<Asset>, List<Asset>>
    with $Provider<List<Asset>> {
  /// Provider for assets filtered by category (pass category.name as String)
  AssetsByCategoryProvider._({
    required AssetsByCategoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'assetsByCategoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$assetsByCategoryHash();

  @override
  String toString() {
    return r'assetsByCategoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<Asset>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Asset> create(Ref ref) {
    final argument = this.argument as String;
    return assetsByCategory(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Asset> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Asset>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AssetsByCategoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$assetsByCategoryHash() => r'6406da91c6f8b5f1b422e3a8aa56ebea334a4ed5';

/// Provider for assets filtered by category (pass category.name as String)

final class AssetsByCategoryFamily extends $Family
    with $FunctionalFamilyOverride<List<Asset>, String> {
  AssetsByCategoryFamily._()
    : super(
        retry: null,
        name: r'assetsByCategoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for assets filtered by category (pass category.name as String)

  AssetsByCategoryProvider call(String categoryName) =>
      AssetsByCategoryProvider._(argument: categoryName, from: this);

  @override
  String toString() => r'assetsByCategoryProvider';
}

/// Provider for total asset value

@ProviderFor(totalAssetValue)
final totalAssetValueProvider = TotalAssetValueProvider._();

/// Provider for total asset value

final class TotalAssetValueProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Provider for total asset value
  TotalAssetValueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalAssetValueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalAssetValueHash();

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    return totalAssetValue(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$totalAssetValueHash() => r'f1b5d12326f26ab6c6542dd57041721055e04316';

/// Provider for assets with expiring warranties (within 30 days)

@ProviderFor(expiringWarranties)
final expiringWarrantiesProvider = ExpiringWarrantiesProvider._();

/// Provider for assets with expiring warranties (within 30 days)

final class ExpiringWarrantiesProvider
    extends $FunctionalProvider<List<Asset>, List<Asset>, List<Asset>>
    with $Provider<List<Asset>> {
  /// Provider for assets with expiring warranties (within 30 days)
  ExpiringWarrantiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expiringWarrantiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expiringWarrantiesHash();

  @$internal
  @override
  $ProviderElement<List<Asset>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Asset> create(Ref ref) {
    return expiringWarranties(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Asset> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Asset>>(value),
    );
  }
}

String _$expiringWarrantiesHash() =>
    r'323ef5fdc3f79a092e163be75a1b415403cd729b';
