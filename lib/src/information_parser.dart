import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:route_manager/src/models/route_settings_info.dart';

import 'helpers/route_helper.dart';
import 'utils/extensions.dart';

/// This is a delegate used by the [RouterManager] to parse route information.
/// It extends [RouteInformationParser].
class InformationParser
    extends RouteInformationParser<List<RouteSettingsInfo>> {
  /// Optionally, this method can be provided to evaluate if a route info is enabled or not.
  /// For example, it can be useful in case of auth guards: some route could be disabled
  /// unless the user is logged in.
  final bool Function(BuildContext? context, String path)? evaluateEnabledRoute;

  /// Optionally, an `initialRoute` can be provided to be used as initial page
  /// pushed in the stack. If provided, it _must_ be declared also in the `routesInfo` list.
  /// If _null_, than the default root path will be used, that is one named `/`.
  /// It's user responsability to manage this case, probably adding a [AbstractRouteInfo] item
  /// in `routesInfo` list to take care of the default root page.
  final String? initialRoute;

  /// This is a delegate used by the [RouterManager] to parse route information.
  ///
  /// `routesInfo` must be provided and _must_ be the same list provided to the [RouterManager],
  /// otherwise the app routing could have some unexpected result.
  const InformationParser({
    this.evaluateEnabledRoute,
    this.initialRoute,
  }) : super();

  @override
  Future<List<RouteSettingsInfo>> parseRouteInformation(
      RouteInformation routeInformation) {
    // If the uri has no path segment, intantiate the root widget
    if (routeInformation.uri.pathSegments.isEmpty) {
      return SynchronousFuture([
        RouteSettingsInfo(
            routeSettings: RouteSettings(
              name: initialRoute ?? RouteHelper.rootName,
              arguments: routeInformation.uri.queryParameters,
            ),
            path: initialRoute ?? RouteHelper.rootName)
      ]);
    }

    // Retrieve route settings for all the path segments of the uri
    List<RouteSettingsInfo> routeSettings =
        retrieveRouteSettingsFromUri(routeInformation.uri);
    return SynchronousFuture(routeSettings);
  }

  /// This method retrieve route informations for every path segment in the provided uri,
  /// returning a [List] of route informations.
  @visibleForTesting
  List<RouteSettingsInfo> retrieveRouteSettingsFromUri(Uri uri) {
    List<RouteSettingsInfo> routeSettings = [];
    var routeEnabled = true;
    if (evaluateEnabledRoute != null) {
      routeEnabled = evaluateEnabledRoute!(null, uri.path.removeLastSlash());
    }
    if (!routeEnabled) {
      return [
        RouteSettingsInfo(
            routeSettings: RouteSettings(
              name: initialRoute ?? RouteHelper.rootName,
              arguments: null,
            ),
            path: initialRoute ?? RouteHelper.rootName)
      ];
    }
    for (var pathSegment in uri.pathSegments) {
      routeSettings.add(RouteSettingsInfo(
          routeSettings: RouteSettings(
            name: '/$pathSegment',
            arguments: pathSegment == uri.pathSegments.last
                ? uri.queryParameters
                : null,
          ),
          path: uri.path));
    }
    return routeSettings;
  }

  @override
  RouteInformation restoreRouteInformation(
      List<RouteSettingsInfo> configuration) {
    if (configuration.isNotEmpty) {
      String location = configuration.last.path;

      final String arguments = restoreArguments(configuration.last);

      return RouteInformation(uri: Uri.parse('$location$arguments'));
    }
    return RouteInformation();
  }

  /// This method is used to restore arguments in a query string to append to the
  /// path, if route settings for the last path segment contains arguments.
  @visibleForTesting
  String restoreArguments(RouteSettingsInfo routeSettings) {
    var arguments = routeSettings.routeSettings.arguments;
    if (arguments == null) {
      return "";
    }

    if (arguments is Map) {
      return arguments.convertToQueryString();
    } else if (arguments is String) {
      return RouteHelper.base64QueryParam + arguments;
    }

    return "";
  }
}
