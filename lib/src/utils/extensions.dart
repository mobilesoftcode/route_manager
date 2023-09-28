import 'package:collection/collection.dart';

extension RouteStringExtension on String {
  /// Remove the `/` from the end of the string, if present
  ///
  /// ``` dart
  /// const str = "/test/";
  /// final newStr = str.removeLastSlash(); // "/test"
  /// ```
  ///
  /// If `ignoreIfUnique` is _true_, a path such as "/" will not be modified,
  /// otherwise it would become an empty string.
  ///
  /// ``` dart
  /// const str = "/";
  /// var newStr = str.removeLastSlash(); // "/"
  /// newStr = str.removeLastSlash(ignoreIfUnique: false); // ""
  /// ```
  String removeLastSlash({bool ignoreIfUnique = true}) {
    String location = this;
    if ((!ignoreIfUnique || this != "/") && endsWith("/")) {
      location = location.replaceRange((location.lastIndexOf("/")), null, "");
    }
    return location;
  }

  /// Remove the `/` from the start of the string, if present
  ///
  /// ``` dart
  /// const str = "/test";
  /// final newStr = str.removeInitialSlash(); // "test"
  /// ```
  String removeInitialSlash() {
    String location = this;
    if (startsWith("/")) {
      location = location.substring(1);
    }
    return location;
  }

  /// Add the `/` to the start of the string, if needed
  ///
  /// ``` dart
  /// const str = "test";
  /// final newStr = str.fixPathWithSlash(); // "/test"
  /// ```
  String fixPathWithSlash() {
    String location = this;
    if (!startsWith("/")) {
      location = "/$location";
    }
    return location;
  }
}

extension QueryMapExtension on Map {
  /// Use this method to convert a [Map] to a query string.
  ///
  /// ``` dart
  /// const map = {
  ///   "query1": "test1",
  ///   "query2": "test2"
  /// };
  /// final str = map.convertToQueryString(); // "?query1=test1&query2=test2"
  /// ```
  String convertToQueryString() {
    String? query;
    forEach((key, value) {
      if (query == null) {
        query = "?";
      } else {
        query = "${query ?? ""}&";
      }
      query = "${query ?? ""}$key=$value";
    });
    return query ?? "";
  }

  /// Search in this map if `key` is present. If not, return _null_.
  /// Than, check if the value for that key corresponds to the T type, and then returns
  /// null or the value itself accordingly.
  T? getValueForKey<T>(String key) {
    if (!containsKey(key)) {
      return null;
    }

    if (this[key] is! T) {
      return null;
    }

    return this[key];
  }
}

extension ListExtension<T> on List<T> {
  /// Evaluate if the list contains two or more items with a same property.
  /// Return _true_ if a match is found, _false_ otherwise.
  bool containsTwoItemsWithSame(
    bool Function(T item1, T item2) toElement,
  ) {
    bool contain = false;
    forEach((element) {
      var item =
          singleWhereOrNull((innerElement) => toElement(element, innerElement));
      if (item == null) {
        contain = true;
      }
    });
    return contain;
  }
}
