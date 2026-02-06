// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RoomsNotifier)
final roomsProvider = RoomsNotifierProvider._();

final class RoomsNotifierProvider
    extends $AsyncNotifierProvider<RoomsNotifier, List<Room>> {
  RoomsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomsNotifierHash();

  @$internal
  @override
  RoomsNotifier create() => RoomsNotifier();
}

String _$roomsNotifierHash() => r'defce2091e2c2437e77ececedcc97136baec285c';

abstract class _$RoomsNotifier extends $AsyncNotifier<List<Room>> {
  FutureOr<List<Room>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Room>>, List<Room>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Room>>, List<Room>>,
              AsyncValue<List<Room>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(roomById)
final roomByIdProvider = RoomByIdFamily._();

final class RoomByIdProvider
    extends $FunctionalProvider<AsyncValue<Room?>, Room?, FutureOr<Room?>>
    with $FutureModifier<Room?>, $FutureProvider<Room?> {
  RoomByIdProvider._({
    required RoomByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'roomByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$roomByIdHash();

  @override
  String toString() {
    return r'roomByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Room?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Room?> create(Ref ref) {
    final argument = this.argument as String;
    return roomById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$roomByIdHash() => r'72a0afdab7b8b074628e312d8639570cb87889a1';

final class RoomByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Room?>, String> {
  RoomByIdFamily._()
    : super(
        retry: null,
        name: r'roomByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RoomByIdProvider call(String roomId) =>
      RoomByIdProvider._(argument: roomId, from: this);

  @override
  String toString() => r'roomByIdProvider';
}

/// Total rooms count

@ProviderFor(roomsCount)
final roomsCountProvider = RoomsCountProvider._();

/// Total rooms count

final class RoomsCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Total rooms count
  RoomsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomsCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return roomsCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$roomsCountHash() => r'dfabc182eff176a9382a32bf9f99c02658f5cc00';

/// Total virtual items across all rooms

@ProviderFor(totalVirtualItems)
final totalVirtualItemsProvider = TotalVirtualItemsProvider._();

/// Total virtual items across all rooms

final class TotalVirtualItemsProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// Total virtual items across all rooms
  TotalVirtualItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalVirtualItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalVirtualItemsHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return totalVirtualItems(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$totalVirtualItemsHash() => r'70bdc47bbfbad07d38c6aacb98fa12ab21dc065d';
