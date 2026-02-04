// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shoppingRepository)
final shoppingRepositoryProvider = ShoppingRepositoryProvider._();

final class ShoppingRepositoryProvider
    extends
        $FunctionalProvider<
          ShoppingRepository,
          ShoppingRepository,
          ShoppingRepository
        >
    with $Provider<ShoppingRepository> {
  ShoppingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shoppingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shoppingRepositoryHash();

  @$internal
  @override
  $ProviderElement<ShoppingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShoppingRepository create(Ref ref) {
    return shoppingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShoppingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShoppingRepository>(value),
    );
  }
}

String _$shoppingRepositoryHash() =>
    r'359c3bc06162ac322ea123b4384f224f48096369';

@ProviderFor(ShoppingNotifier)
final shoppingProvider = ShoppingNotifierProvider._();

final class ShoppingNotifierProvider
    extends $NotifierProvider<ShoppingNotifier, List<ShoppingItem>> {
  ShoppingNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shoppingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shoppingNotifierHash();

  @$internal
  @override
  ShoppingNotifier create() => ShoppingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ShoppingItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ShoppingItem>>(value),
    );
  }
}

String _$shoppingNotifierHash() => r'dc91c38f0d94a3ab1a782781287f2efca61c856a';

abstract class _$ShoppingNotifier extends $Notifier<List<ShoppingItem>> {
  List<ShoppingItem> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<ShoppingItem>, List<ShoppingItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ShoppingItem>, List<ShoppingItem>>,
              List<ShoppingItem>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
