// This class serves for general utilities

int toInt(String string) => string.toInt();

extension StringUtils on String {
  int toInt() => int.parse(this);
}