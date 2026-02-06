// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'packing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(packingRepository)
final packingRepositoryProvider = PackingRepositoryProvider._();

final class PackingRepositoryProvider
    extends
        $FunctionalProvider<
          PackingRepository,
          PackingRepository,
          PackingRepository
        >
    with $Provider<PackingRepository> {
  PackingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packingRepositoryHash();

  @$internal
  @override
  $ProviderElement<PackingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PackingRepository create(Ref ref) {
    return packingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PackingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PackingRepository>(value),
    );
  }
}

String _$packingRepositoryHash() => r'139fbbc9200710db77bb479c9dc95e35ab8bfc5b';

@ProviderFor(RoomNotifier)
final roomProvider = RoomNotifierProvider._();

final class RoomNotifierProvider
    extends $NotifierProvider<RoomNotifier, List<Room>> {
  RoomNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomNotifierHash();

  @$internal
  @override
  RoomNotifier create() => RoomNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Room> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Room>>(value),
    );
  }
}

String _$roomNotifierHash() => r'4c1114bab98406e748882d5d48d11197c5dc89e6';

abstract class _$RoomNotifier extends $Notifier<List<Room>> {
  List<Room> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Room>, List<Room>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Room>, List<Room>>,
              List<Room>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(BoxNotifier)
final boxProvider = BoxNotifierProvider._();

final class BoxNotifierProvider
    extends $NotifierProvider<BoxNotifier, List<PackingBox>> {
  BoxNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boxProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boxNotifierHash();

  @$internal
  @override
  BoxNotifier create() => BoxNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PackingBox> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PackingBox>>(value),
    );
  }
}

String _$boxNotifierHash() => r'fa2256e60739ed3d9da6e7529c447008f4ca63b1';

abstract class _$BoxNotifier extends $Notifier<List<PackingBox>> {
  List<PackingBox> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<PackingBox>, List<PackingBox>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PackingBox>, List<PackingBox>>,
              List<PackingBox>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(BoxItemNotifier)
final boxItemProvider = BoxItemNotifierProvider._();

final class BoxItemNotifierProvider
    extends $NotifierProvider<BoxItemNotifier, List<BoxItem>> {
  BoxItemNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'boxItemProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$boxItemNotifierHash();

  @$internal
  @override
  BoxItemNotifier create() => BoxItemNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<BoxItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<BoxItem>>(value),
    );
  }
}

String _$boxItemNotifierHash() => r'13f6aaf9f148a6a5be77753285969af1c1d05b2f';

abstract class _$BoxItemNotifier extends $Notifier<List<BoxItem>> {
  List<BoxItem> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<BoxItem>, List<BoxItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<BoxItem>, List<BoxItem>>,
              List<BoxItem>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(roomBoxes)
final roomBoxesProvider = RoomBoxesFamily._();

final class RoomBoxesProvider
    extends
        $FunctionalProvider<
          List<PackingBox>,
          List<PackingBox>,
          List<PackingBox>
        >
    with $Provider<List<PackingBox>> {
  RoomBoxesProvider._({
    required RoomBoxesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'roomBoxesProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$roomBoxesHash();

  @override
  String toString() {
    return r'roomBoxesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<PackingBox>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<PackingBox> create(Ref ref) {
    final argument = this.argument as String;
    return roomBoxes(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PackingBox> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PackingBox>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RoomBoxesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$roomBoxesHash() => r'032679355359d2416c1b648e691c8bac074ce519';

final class RoomBoxesFamily extends $Family
    with $FunctionalFamilyOverride<List<PackingBox>, String> {
  RoomBoxesFamily._()
    : super(
        retry: null,
        name: r'roomBoxesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  RoomBoxesProvider call(String roomId) =>
      RoomBoxesProvider._(argument: roomId, from: this);

  @override
  String toString() => r'roomBoxesProvider';
}

@ProviderFor(itemsInBox)
final itemsInBoxProvider = ItemsInBoxFamily._();

final class ItemsInBoxProvider
    extends $FunctionalProvider<List<BoxItem>, List<BoxItem>, List<BoxItem>>
    with $Provider<List<BoxItem>> {
  ItemsInBoxProvider._({
    required ItemsInBoxFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itemsInBoxProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemsInBoxHash();

  @override
  String toString() {
    return r'itemsInBoxProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<BoxItem>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<BoxItem> create(Ref ref) {
    final argument = this.argument as String;
    return itemsInBox(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<BoxItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<BoxItem>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ItemsInBoxProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemsInBoxHash() => r'4e60bee939c2d72ba9ae1bc45b31db51cfedaa5a';

final class ItemsInBoxFamily extends $Family
    with $FunctionalFamilyOverride<List<BoxItem>, String> {
  ItemsInBoxFamily._()
    : super(
        retry: null,
        name: r'itemsInBoxProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ItemsInBoxProvider call(String boxId) =>
      ItemsInBoxProvider._(argument: boxId, from: this);

  @override
  String toString() => r'itemsInBoxProvider';
}

@ProviderFor(packingStats)
final packingStatsProvider = PackingStatsProvider._();

final class PackingStatsProvider
    extends $FunctionalProvider<PackingStats, PackingStats, PackingStats>
    with $Provider<PackingStats> {
  PackingStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packingStatsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packingStatsHash();

  @$internal
  @override
  $ProviderElement<PackingStats> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PackingStats create(Ref ref) {
    return packingStats(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PackingStats value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PackingStats>(value),
    );
  }
}

String _$packingStatsHash() => r'39e0d82cc1f5675ecd8775464b47575fe3d56b8a';
