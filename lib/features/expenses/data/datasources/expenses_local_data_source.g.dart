// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_local_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(expensesLocalDataSource)
final expensesLocalDataSourceProvider = ExpensesLocalDataSourceProvider._();

final class ExpensesLocalDataSourceProvider
    extends
        $FunctionalProvider<
          ExpensesLocalDataSource,
          ExpensesLocalDataSource,
          ExpensesLocalDataSource
        >
    with $Provider<ExpensesLocalDataSource> {
  ExpensesLocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expensesLocalDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expensesLocalDataSourceHash();

  @$internal
  @override
  $ProviderElement<ExpensesLocalDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExpensesLocalDataSource create(Ref ref) {
    return expensesLocalDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpensesLocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpensesLocalDataSource>(value),
    );
  }
}

String _$expensesLocalDataSourceHash() =>
    r'107b923586815da652a19e8bb71bed00c42707ac';
