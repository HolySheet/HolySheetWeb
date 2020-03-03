// This class serves for general utilities

import 'dart:async';

int toInt(String string) => string?.toInt() ?? 0;

int get millsTime => DateTime.now().millisecondsSinceEpoch;

Future<T> complete<T>(Function(Completer<T>) task) {
  final completer = Completer<T>();
  task(completer);
  return completer.future;
}

extension StringUtils on String {
  int toInt() => int.tryParse(this) ?? 0;

  String trimText(String text) {
    var out = this;
    while (out.startsWith(text)) {
      out = out.substring(text.length, out.length);
    }

    while (out.endsWith(text)) {
      out = out.substring(0, out.length - text.length);
    }

    return out;
  }

  String trimRightText(String text) {
    var out = this;
    while (out.endsWith(text)) {
      out = out.substring(0, out.length - text.length);
    }

    return out;
  }
}

extension IterationUtils<T> on Iterable<T> {
  List<T> clone() => [...this];
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

  List<T> setEverything(Iterable<T> items) => this..clear()..addAll(items);

  void reverse() {
    var temp = reversed.clone();
    clear();
    addAll(temp);
  }

  T start() => length > 0 ? elementAt(0) : null;
}
