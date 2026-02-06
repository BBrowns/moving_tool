abstract class BaseRepository<T> {
  Future<List<T>> getAll(String projectId);
  Future<T?> getById(String id);
  Future<void> add(T item);
  Future<void> update(T item);
  Future<void> delete(String id);
}
