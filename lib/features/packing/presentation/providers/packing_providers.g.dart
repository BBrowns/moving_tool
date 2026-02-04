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

String _$packingRepositoryHash() => r'c9cfa6e9d83b2501490c947ef58067572b4e8b45';

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

String _$roomNotifierHash() => r'5212372ac19f8c811ca9e6c077732263d8ee027b';

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

String _$boxNotifierHash() => r'262f51be3c0f2513d0a7bf53cfef7b45750a0429';

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

String _$boxItemNotifierHash() => r'8720f941269eb9850218b486f0cfc963788ad1e7';

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

String _$roomBoxesHash() => r'738b200b84273eb5d688c23002f119c8a86d4f45';

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

String _$itemsInBoxHash() => r'1fd8074a2b595d86174a3be7591a151fc3ef442e';

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

String _$packingStatsHash() => r'06c325f8145656f4e4ba25244d36c194f429a746';
