import 'package:flutter/material.dart';
import 'package:route_manager/src/helpers/route_helper.dart';
import '../../route_manager.dart';

/// Creates a Router Manager.
///
/// It should be used in the widget tree as root for a new route path.
class RouterManager extends StatefulWidget {
  /// The route manager to be used from this widget in the widget tree.
  /// It must be provided to specify the route infos for this specific route.
  ///
  /// For further information about [RouteManager] check the class documentation.
  final RouteManager routeManager;

  /// Creates a Router Manager.
  ///
  /// It should be used in the widget tree as root for a new route path.
  /// The [RouteManager] must not be null and it's used to initialize
  /// a route manager with the specified route infos.
  ///
  /// For further information about [RouteManager] check the class documentation.
  const RouterManager({Key? key, required this.routeManager}) : super(key: key);

  @override
  State<RouterManager> createState() => _RouterManagerState();
}

class _RouterManagerState extends State<RouterManager> {
  late var _routeManager = widget.routeManager;
  @override
  void initState() {
    _routeManager.routerDelegate.pushNamed(
      _routeManager.initialRouteInfo?.initialRouteName ??
          RouteHelper.rootName,
      postFrame: true,
    );
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RouterManager oldWidget) {
    if (oldWidget.routeManager.initialRouteInfo?.initialRouteName !=
        widget.routeManager.initialRouteInfo?.initialRouteName) {
      _routeManager = widget.routeManager;
      _routeManager.routerDelegate.pushNamed(
        _routeManager.initialRouteInfo?.initialRouteName ??
            RouteHelper.rootName,
        postFrame: true,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Router(
      routerDelegate: _routeManager.routerDelegate,
      routeInformationParser: _routeManager.informationParser,
    );
  }
}
