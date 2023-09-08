import '../utils/extensions.dart';

/// This is an helper class. It contains some useful methods to execute actions
/// on paths and path segments.
class RouteHelper {
  /// The default root name, usually a `/`
  static const String rootName = "/";

  /// Recover first path segment of route from a String.
  ///
  /// ``` dart
  /// const str = "/test1/test2";
  /// final pathSegment = RouteHelper.getFirstPathSegment(str); // "/test1"
  /// ```
  static String getFirstPathSegment(String? path) {
    assert(path?.startsWith("/") ?? true, 'Path is not valid');

    // Remove initial `/`, if present
    var newStr = path?.removeInitialSlash();

    // Check if there is a `/` to eventually cut the string
    if (newStr?.contains("/") ?? false) {
      // Cut the string from the `/` to the end
      newStr = path?.substring(0, (newStr?.indexOf("/") ?? 0) + 1) ?? "";
      // Add the initial `/` to fix the path segment, then return the value
      return newStr.fixPathWithSlash();
    }
    return path ?? "";
  }

  /// Recover last path segment of route from a String
  ///
  /// ``` dart
  /// const str = "/test1/test2";
  /// final pathSegment = RouteHelper.getLastPathSegment(str); // "/test2"
  /// ```
  static String getLastPathSegment(String? path) {
    assert(path?.startsWith("/") ?? true, 'Path is not valid');

    // Add initial `/`, if needed, then remove last `/`, if present
    var newStr = path?.fixPathWithSlash().removeLastSlash();

    // Check if there is a `/` to eventually cut the string
    if (newStr?.contains("/") ?? false) {
      return newStr?.substring(newStr.lastIndexOf("/")) ?? "";
    }
    return newStr ?? "";
  }

  /// Remove the last path segment from the provided path
  ///
  /// ``` dart
  /// const str = "/test1/test2/test3";
  /// final pathSegment = RouteHelper.removeLastPathSegment(str); // "/test1/test2"
  /// ```
  static String removeLastPathSegment(String? path) {
    assert(path?.startsWith("/") ?? true, 'Path is not valid');
    return path
            ?.substring(0, path.indexOf(getLastPathSegment(path)))
            .fixPathWithSlash() ??
        "";
  }

  /// Find a path segment into the path with the provided name.
  /// The method verifies that the path is not the last one
  ///
  /// ``` dart
  /// const path = "/test1/test2/test3";
  /// const name = "/test2";
  /// final pathSegment = RouteHelper.getPathSegmentWithName(name: name, path: path); // "/test1/test2"
  /// ```
  static String getPathSegmentWithName(
      {required String name, required String path}) {
    assert(name.startsWith("/"), 'Name is not valid');
    assert(path.startsWith("/"), 'Path is not valid');

    // Verify if the path segment is contained into the path
    if (path.contains("/${name.replaceAll("/", "")}/")) {
      var newPath =
          path.substring(0, path.lastIndexOf("${name.replaceAll("/", "")}/"));

      return (newPath + name.removeInitialSlash()).fixPathWithSlash();
    }

    // Verify if the path segment is the last one in the path
    if (path.endsWith(name)) {
      return path;
    }

    return "";
  }
}
