// This class serves for general utilities

int toInt(String string) => string?.toInt() ?? 0;

int get millsTime => DateTime.now().millisecondsSinceEpoch;

extension StringUtils on String {
  int toInt() => int.tryParse(this) ?? 0;
}

extension ListUtils<T> on List<T> {

  /// If [element] is contained in the list, it will remove it and return false.
  /// If it is not contained, it is added and returns true.
  bool toggle(T element) {
    if (contains(element)) {
      remove(element);
      return false;
    } else {
      add(element);
      return true;
    }
  }

  /// Removes all of the given list from the current list.
  List<T> removeAll(Iterable<T> items) {
    final removed = <T>[];
    for (var element in items) {
      if (remove(element)) {
        removed.add(element);
      }
    }
    return removed;
  }
}