/// Basis-Interface für alle Repository-Klassen
/// Definiert grundlegende CRUD-Operationen
abstract class BaseRepository<T> {
  Future<int> insert(T item);
  Future<List<T>> getAll();
  Future<T?> getById(int id);
  Future<int> update(T item);
  Future<int> delete(int id);
}