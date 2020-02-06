import 'dart:js';

T js<T>(String methodGet, [List args]) {
  var access = getMethodAccess(methodGet);
  final ret = access.key.callMethod(access.value, args);
  if (T is JsObject) {
    return access.key as T;
  }
  return ret;
}

JsObject fromBrowser(object) => JsObject.fromBrowserObject(object);

JsObject getAccess(String access) {
  var split = access.split('.');
  var preMethod = context;
  split.forEach((part) => preMethod = preMethod[part]);
  return preMethod;
}

MapEntry<JsObject, String> getMethodAccess(String access) {
  var split = access.split('.');
  var preMethod = context;
  var method = split.removeLast();
  split.forEach((part) => preMethod = preMethod[part]);
  return MapEntry(preMethod, method);
}

extension JSExtensions on String {
  /// Parses the method (e.g. `console.log`) with the given name and optional arguments.
  /// [args] can either be a singular object, or a list containing one or more
  /// arguments.
  T call<T>([dynamic args = const[]]) => js<T>(this, !(args is List) ? [args] : args);
}

extension JsObjectExtensions on JsObject {
  /// Calls the method with the given name and optional arguments.
  /// [args] can either be a singular object, or a list containing one or more
  /// arguments.
  dynamic call(String method, [dynamic args = const []]) => callMethod(method, !(args is List) ? [args] : args);
}

