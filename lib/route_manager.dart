library route_manager;

import 'package:flutter/material.dart';
import 'package:route_manager/src/information_parser.dart';
import 'package:route_manager/src/models/initial_route_info.dart';
import 'package:route_manager/src/models/route_info.dart';
import 'package:route_manager/src/route_delegate.dart';
import 'package:route_manager/src/custom_transition_delegate.dart';
import 'src/utils/extensions.dart';

export 'src/models/route_info.dart';
export 'src/widgets/router_manager.dart';
export 'src/widgets/route_manager_will_pop_scope.dart';
export 'src/models/initial_route_info.dart';
export 'src/utils/extensions.dart' show QueryMapExtension;

/// Creates a [RouteManager] to manage routing for a custom route.
/// The app can have multiple route managers, but at least one to be used
/// as the root router in [MaterialApp].
///
/// The [RouteManager] is responsible of creating and storing the [RouteDelegate],
/// the [InformationParser] and the [CustomTransitionDelegate] to manage routing
/// such as pushing and popping pages.
///
/// The [RouteDelegate] instance to push/pop pages can be accessed by calling
/// ``` dart
/// final routeDelegate = RouterManager.of(context);
/// ```
///
/// For other information about [RouteManager] usage, check the class documentation.
class RouteManager {
  /// The `routesInfo` list _must_ be provided to specify all the possibile Route pages
  /// managed by this [RouteManager].
  /// The list must not contain more [AbstractRouteInfo] items with the same _name_.
  /// Furthermore, it must contain a route with the name specified in `initialRouteInfo`
  /// (or "/" as default initial route name).
  ///
  /// For more information about [AbstractRouteInfo], check the class documentation.
  final List<AbstractRouteInfo> routesInfo;

  /// Optionally, this method can be provided to evaluate if a route info is enabled or not.
  /// For example, it can be useful in case of auth guards: some route could be disabled
  /// unless the user is logged in.
  ///
  /// Note that this method is evaluated also at the very beginning of the application,
  /// so if you have not yet data to take appropriate action (i.e. if the user has not logged in yet)
  /// you should always return _true_ to avoid unintended redirections.
  final bool Function(BuildContext? context, String path)? evaluateEnabledRoute;

  /// Optionally, an `initialRouteInfo` can be provided to define an initial route path to
  /// push in the stack and to define rules to redirect if needed.
  /// Routes _must_ be declared also in the `routesInfo` list.
  /// If _null_, than the default root path will be used, that is one named `/`, and no
  /// rules to redirect from the root path are set.
  /// It's user responsability to manage this case, probably adding a [AbstractRouteInfo] item
  /// in `routesInfo` list to take care of the default root page.
  final InitialRouteInfo? initialRouteInfo;

  /// Optionally, a `defaultRouteWidget` can be provided as a widget to be used
  /// when there is no matching route name in `routesInfo` list.
  /// If _null_, than a default 404 page will be shown.
  /// This `defaultRouteWidget` can either be a custom 404 page,
  /// or the default root widget for a nester routing system (i.e. a tabbed page)
  final Widget? defaultRouteWidget;

  /// Optionally, a `basePath` can be provided if in the _index.html_ file the
  /// base path is different from `/`.
  final String? basePath;

  /// If _false_, route transitions will be executed without animations.
  final bool enableTransitionAnimation;

  /// If _false_, the default swipe gesture to pop page on iOS is blocked. Defaults to _true_.
  final bool allowSwipeToPopOnIOS;

  /// Use this method to access the navigator context and eventually initialize
  /// globals or variables.
  final void Function(BuildContext)? onGenerateNavigatorContext;

  /// Use this builder to specify an alert to show on Android devices
  /// when the user taps on the "back" button and there are no pages to pop.
  /// It should represent an alert to ask the user to confirm to close the app.
  /// If not provided, a default alert is shown.
  /// Call the methods `onConfirmClose` and `onCancelClose` accordingly.
  final Widget Function(Function onConfirmClose, Function onCancelClose)?
      closeAppAlertBuilder;

  /// If you manage authentication as a guard mask in your app, you can specify a widget to use
  /// as authentication wrapper and pass it to the [RouteManager].
  ///
  /// All the routes in `routesInfo` that have `requiresAuthentication` set to _true_ will be
  /// wrapped with this widget. Note that the `child` argument passed here is the
  /// widget specified in the relative [AbstractRouteInfo] class.
  ///
  /// The `evaluateEnabledRoute` will be called before showing the `child` widget,
  /// to eventually redirect the user after authentication if he should not access the path.
  final Widget Function(Widget child)? authenticationWrapper;

  /// Creates a [RouteManager] to manage routing for a custom route.
  /// The app can have multiple route managers, but at least one to be used
  /// as the root router in [MaterialApp].
  ///
  /// The [RouteManager] is responsible of creating and storing the [RouteDelegate],
  /// the [InformationParser] and the [CustomTransitionDelegate] to manage routing
  /// such as pushing and popping pages.
  ///
  /// The `routesInfo` list _must_ be provided to specify all the possibile Route pages
  /// managed by this [RouteManager].
  ///
  /// Optionally, an `initialRouteInfo` can be provided to specify the initial page
  /// pushed in the stack and eventually set a redirect rule.
  ///
  /// Optionally, a `defaultRouteWidget` can be provided to be used as default page when
  /// not found in `routesList`
  ///
  /// Optionally, a `basePath` can be provided if in the _index.html_ file the
  /// base path is different from `/`.
  ///
  /// Optionally, `evaluateEnabledRoute` method can be provided to evaluate if a route info is enabled or not.
  ///
  /// If `allowSwipeToPopOnIOS` is _false_, the default swipe gesture to pop page on iOS is blocked. Defaults to _true_.
  ///
  /// Optionally, the `onGenerateNavigatorContext` method can be used to access the navigator context.
  ///
  /// Optionally, an `authenticationWrapper` can be set to be used as authentication guard.
  ///
  /// If `enableTransitionAnimation` is _false_, the transitions animations between routes will be disabled. Defaults to _true_.
  /// # Usage
  ///
  /// The [RouteManager] must be used to initialize the routing system.
  /// To use it in the root [MaterialApp] routing, instantiate the MaterialApp
  /// with the [MaterialApp.router] constructor and then pass the created
  /// [RouteDelegate] and [InformationParser], as shown in the followin example.
  /// ``` dart
  /// final routeManager = RouteManager(routesInfo: [
  ///   RouteInfo(name: "/", routeWidget: (args) => Container()),
  /// ]);
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return MaterialApp.router(
  ///     routeInformationParser: routeManager.informationParser,
  ///     routerDelegate: routeManager.routerDelegate,
  ///   );
  /// }
  /// ```
  ///
  /// To use another [RouteManager] in app, the [RouterManager] widget can be
  /// similarly used as shown in the following code.
  /// ``` dart
  /// final routeManager = RouteManager(routesInfo: [
  ///   RouteInfo(name: "/home", routeWidget: (args) => Container()),
  /// ]);
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return RouterManager(
  ///     routeManager: routeManager,
  ///   );
  /// }
  /// ```
  ///
  /// ## RouteDelegate
  ///
  /// The [RouteDelegate] instance to push/pop pages can be accessed by calling
  /// ``` dart
  /// final routeDelegate = RouterManager.of(context);
  /// ```
  /// Note that you need the `context` to use the route delegate. If you want to
  /// use it outside a widget with `context`, you should take care on your own to store an
  /// application's global context, or to share the [RouteManager] instance globally
  /// in the project to access it everywhere. This behaviour is discouraged and
  /// so there is no out-of-the-box implementation for it.
  ///
  /// For other information about [RouteManager] usage, check the class documentation.
  RouteManager(
      {required this.routesInfo,
      this.evaluateEnabledRoute,
      this.initialRouteInfo,
      this.defaultRouteWidget,
      this.basePath,
      this.enableTransitionAnimation = true,
      this.allowSwipeToPopOnIOS = true,
      this.onGenerateNavigatorContext,
      this.closeAppAlertBuilder,
      this.authenticationWrapper})
      : assert(!routesInfo
            .containsTwoItemsWithSame((e1, e2) => e1.name == e2.name)),
        assert(initialRouteInfo == null ||
            routesInfo.any((element) =>
                element.name == initialRouteInfo.initialRouteName));

  late final _routerDelegate = RouteDelegate(
    routeManager: this,
  );

  /// This is the [RouteDelegate] responsible of managing the stack of pages.
  /// It's used to push and pop pages in the stack.
  ///
  /// To access it wherever needed in the widget tree, it's suggested to use
  /// ``` dart
  /// final routeDelegate = RouteManager.of(context);
  /// ```
  ///
  /// and then using its method as
  /// ``` dart
  /// routeDelegate.pushPage(name: "/home");
  /// ```
  ///
  /// of even
  /// ``` dart
  /// RouterManager.of(context).pushPage(name: "/home");
  /// ```
  ///
  /// instead of accessing it directly, nevertheless it's possibile as follows:
  /// ``` dart
  /// final routeManager = RouteManager(
  ///   [...]
  /// )
  /// routeManager.routerDelegate.pushPage(name: "/home");
  /// ```
  ///
  /// Pay attention to the [BuildContext] you use to call the `RouteDelegate`!
  /// See Flutter docs for further details.
  RouteDelegate get routerDelegate => _routerDelegate;

  late final _informationParser = InformationParser(
    evaluateEnabledRoute: evaluateEnabledRoute,
    initialRoute: initialRouteInfo?.initialRouteName,
  );

  /// This is the [InformationParser] responsible of parse route settings from paths.
  /// It should be used only when declaring the [RouterManager] or the [MaterialApp.router]
  /// and it must always be paired with the [RouteDelegate].
  InformationParser get informationParser => _informationParser;

  late final _transitionDelegate = CustomTransitionDelegate(
      showTransitionAnimation: enableTransitionAnimation);

  CustomTransitionDelegate get transitionDelegate => _transitionDelegate;

  /// Returns the context of the Navigator widget in router delegate
  BuildContext? get navigatorContext =>
      _routerDelegate.navigatorKey?.currentContext;

  /// Retrieves the immediate [RouteManager] ancestor from the given context.
  ///
  /// This method provides access to the delegates in the [RouteDelegate].
  /// For example, this can be used to access the [pushPage] or [popPage] methods.
  ///
  /// If you have nested [RouteDelegate], for example when using the [RouterManager] widget,
  /// you can access the root [RouteManager] instance by passing `rootNavigator = true`.
  static RouteDelegate of(BuildContext context, {bool rootNavigator = false}) {
    var ctx = context;
    if (rootNavigator) {
      var navigator = Navigator.of(context, rootNavigator: true);
      ctx = navigator.context;
    }
    final delegate = Router.of(ctx).routerDelegate;
    assert(delegate is RouteDelegate, 'Delegate type must match');
    return delegate as RouteDelegate;
  }
}
