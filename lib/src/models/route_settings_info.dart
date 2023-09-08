import 'package:flutter/material.dart';

/// This class contains route settings for a specific page and the corresponding path.
///
/// Usually it should be used with [PageInfo] class.
class RouteSettingsInfo {
  /// The route settings with name and arguments to create a specific page.
  final RouteSettings routeSettings;

  /// The route path (url) this route settings corresponds to.
  /// It can be different from routeSettings's name.
  final String path;
  RouteSettingsInfo({
    required this.routeSettings,
    required this.path,
  });
}
