import 'package:flutter/material.dart';

/// This class contains info about the initial route.
/// It is used to set the initial route name (that defaults to "/" if not specified)
/// and eventually a method to specify a path to use as redirect if a condition is not met.
class InitialRouteInfo {
  /// The initial route name (defaults to "/") that will be pushed in navigation stack
  final String initialRouteName;

  /// A method to eventually specify a path to redirect if a condition is not met.
  /// For example, if the initial route is protected by authentication,
  /// and it can be accessed only for some user-roles, you can use this method
  /// to specify a path to redirect the user if this contition is not satisfied.
  /// If the returned [String] is _null_, than, the navigation will not be redirected.
  final String? Function(BuildContext context)? redirectToPath;

  /// This class contains info about the initial route.
  /// It is used to set the initial route name (that defaults to "/" if not specified)
  /// and eventually a method to specify a path to use as redirect if a condition is not met.
  InitialRouteInfo({
    this.initialRouteName = "/",
    this.redirectToPath,
  }) : assert(initialRouteName.startsWith("/"),
            "The route name must start with a `/`");
}
