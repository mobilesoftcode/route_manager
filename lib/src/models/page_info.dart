import 'package:flutter/material.dart';

/// This class contains a page widget and the corresponding path.
///
/// Usually it should be used with [RouteSettingsInfo] class.
/// It also has an optional `willpop` method, to specify an event to fire
/// when popping this page.
class PageInfo {
  /// The page widget, such as a MaterialPage
  final Page page;

  /// The route path (url) this page corresponds to.
  /// It can be different from routeSettings's name.
  final String path;

  PageInfo({
    required this.page,
    required this.path,
  });

  /// This method can be set to specify an event to fire
  /// when the user tries to pop this page.
  /// The event is handled by the [RouteDelegate] thanks to
  /// [RouteManagerWillPopScope] widget.
  Future<bool> Function()? willpop;
}
