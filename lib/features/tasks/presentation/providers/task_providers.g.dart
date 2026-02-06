// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tasksRepository)
final tasksRepositoryProvider = TasksRepositoryProvider._();

final class TasksRepositoryProvider
    extends
        $FunctionalProvider<TasksRepository, TasksRepository, TasksRepository>
    with $Provider<TasksRepository> {
  TasksRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksRepositoryHash();

  @$internal
  @override
  $ProviderElement<TasksRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TasksRepository create(Ref ref) {
    return tasksRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TasksRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TasksRepository>(value),
    );
  }
}

String _$tasksRepositoryHash() => r'f7279b928f0eb1f0056cd52267b7159209c56e1d';

@ProviderFor(TaskNotifier)
final taskProvider = TaskNotifierProvider._();

final class TaskNotifierProvider
    extends $NotifierProvider<TaskNotifier, List<Task>> {
  TaskNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskNotifierHash();

  @$internal
  @override
  TaskNotifier create() => TaskNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Task> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Task>>(value),
    );
  }
}

String _$taskNotifierHash() => r'8f7fcbf2b46eecd83a17d49de90e6e4cf568cf37';

abstract class _$TaskNotifier extends $Notifier<List<Task>> {
  List<Task> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Task>, List<Task>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Task>, List<Task>>,
              List<Task>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
