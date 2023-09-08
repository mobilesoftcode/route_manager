import 'package:flutter/material.dart';

/// This class contains info about a route.
/// It is used to set the route name, the route child widget to display
/// when the path is pointing to this route, and eventually
/// a function to map query from arguments can be provided.
class RouteInfo {
  /// The name of the route, obv. a path segment.
  /// It is mandatory and it must start with a `/`,
  /// otherwise an assertion error will be thrown.
  final String name;

  /// The widget, usually a page, to display when the `RouteDelegate`
  /// is pointing to this route. It is mandatory.
  ///
  /// The optional `Map` argument in the function is used to retrieve
  /// arguments passed through a `pushPage` method of the `RouteDelegate` class.
  final Widget Function(Map? arguments) routeWidget;

  /// Specify if this route widget should be protected by the `authenticationWrapper`
  /// widget specified in the [RouteManager] initializer. Defaults to _false_.
  final bool requiresAuthentication;

  /// This class contains info about a route.
  /// It is used to set the route name, the route child widget to display
  /// when the path is pointing to this route, and eventually
  /// a function to map query from arguments can be provided.
  ///
  /// `name` and `routeWidget` cannot be _null_.
  RouteInfo({
    required this.name,
    required this.routeWidget,
    this.requiresAuthentication = false,
  }) : assert(name.startsWith("/"), "The route name must start with a `/`");
}
