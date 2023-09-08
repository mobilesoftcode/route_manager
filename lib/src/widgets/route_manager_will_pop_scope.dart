import 'package:flutter/material.dart';
import '../../route_manager.dart';

/// Creates a widget to handle pop action from the `child` widget.
///
/// It's used, for example, to override the default action tapping the physical
/// back button on Android devices, and applies the same behaviour of the
/// [WillPopScope] widget to use it with [RouteManager].
class RouteManagerWillPopScope extends StatefulWidget {
  /// The method to call _before_ the pop action is effectively taken.
  /// If the callback returns a Future that resolves to false, the enclosing route will not be popped.
  final Future<bool> Function() onWillPop;

  /// The child of [RouteManagerWillPopScope] that triggers the pop action.
  final Widget child;

  /// Creates a widget to handle pop action from the `child` widget.
  ///
  /// It's used, for example, to override the default action tapping the physical
  /// back button on Android devices, and applies the same behaviour of the
  /// [WillPopScope] widget to use it with [RouteManager].
  const RouteManagerWillPopScope({
    Key? key,
    required this.onWillPop,
    required this.child,
  }) : super(key: key);

  @override
  State<RouteManagerWillPopScope> createState() =>
      _RouteManagerWillPopScopeState();
}

class _RouteManagerWillPopScopeState extends State<RouteManagerWillPopScope> {
  late final _routeDelegate = RouteManager.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Handles RouteDelegate's pop action.
    _routeDelegate.removeWillPopScopeFromLastPage();
    _routeDelegate.addWillPopScopeToLastPage(widget.onWillPop);
  }

  @override
  void didUpdateWidget(RouteManagerWillPopScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onWillPop != oldWidget.onWillPop) {
      _routeDelegate.removeWillPopScopeFromLastPage();
      _routeDelegate.addWillPopScopeToLastPage(widget.onWillPop);
    }
  }

  @override
  void dispose() {
    _routeDelegate.removeWillPopScopeFromLastPage();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Handle Navigator's pop action.
      onWillPop: () async {
        var shouldPop = await widget.onWillPop();
        if (shouldPop) {
          // If Navigator should pop, remove willpop events from page in RouteDelegate
          _routeDelegate.removeWillPopScopeFromLastPage();
        }
        return shouldPop;
      },
      child: widget.child,
    );
  }
}
