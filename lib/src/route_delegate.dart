import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:route_manager/route_manager.dart';
import 'package:route_manager/src/models/route_settings_info.dart';

import 'helpers/route_helper.dart';

import 'models/page_info.dart';
import 'utils/extensions.dart';

/// Extends the RouterDelegate to manage in-app routing.
///
/// [RouteDelegate] takes care of managing the pages of the application,
/// pushing and popping pages when requested.
///
/// Each page is a [Tuple2] with [RouteSettings] as first item to specify route details
/// such as name and arguments, and a [String] as second item to specify the full path
/// for the provided page, depending on the stack. This is particularly useful on web.
class RouteDelegate extends RouterDelegate<List<RouteSettingsInfo>>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<List<RouteSettingsInfo>> {
  late final RouteManager _routeManager;

  /// [RouteDelegate] takes care of managing the pages of the application,
  /// pushing and popping pages when requested.
  ///
  /// It needs `routeManager`.
  ///
  /// Each page is a [Tuple2] with [RouteSettings] as first item to specify route details
  /// such as name and arguments, and a [String] as second item to specify the full path
  /// for the provided page, depending on the stack. This is particularly useful on web.
  RouteDelegate({
    required RouteManager routeManager,
  }) {
    _routeManager = routeManager;
  }

  RouteManager get routeManager => _routeManager;

  /// The list of pages currently in the navigation stack.
  ///
  /// Each page is a [Tuple2] with [RouteSettings] as first item to specify route details
  /// such as name and arguments, and a [String] as second item to specify the full path
  /// for the provided page, depending on the stack. This is particularly useful on web.
  final pages = <PageInfo>[];

  @override
  final navigatorKey = GlobalKey<NavigatorState>();

  /// Returns the context of the Navigator widget in router delegate
  BuildContext? get navigatorContext => navigatorKey?.currentContext;

  /// This is the current path given all the pages in the stack. It corresponds
  /// to the url on web, while it is used as helper for deeplink on mobile platform.
  late var pathUrl =
      routeManager.initialRouteInfo?.initialRouteName ?? RouteHelper.rootName;

  /// Push a new page in the stack with a default transition animation.
  /// It's mandatory to pass a `name`, that sould match one of the names provided in
  /// the routes info list in [RouteManager]. The name is the key value to decide
  /// which widget should be shown.
  ///
  /// Optionally, `arguments` can be passed as parameter for the widget that is to be shown.
  /// Arguments must be a [Map] and they can be managed by the [RouteInfo] builder parameter.
  ///
  /// If `appendPath` is _true_, the `name` of the page will be appended to the other
  /// pages' names of the stack in the path url, otherwise the `name` will be used
  /// as the new path url. Defaults to _true_.
  ///
  /// If `postFrame` is _true_, the page is pushed in the stack the frame after
  /// this method is called. Useful if called directly in the _build_ method. Defaults
  /// to _false_.
  ///
  /// You can await for a returning value, eventually specifying the expected type.
  /// ``` dart
  /// // Home page
  /// onTap: () async {
  ///   var result = await push<bool>("/settings");
  ///   // Execution stops waiting for the result, then...
  ///   print(result);
  /// }
  ///
  /// // Settings page
  /// onTap: () {
  ///   pop(true);
  /// }
  /// ```
  Future<T?> push<T>(
      {required String name,
      Map<String, Object?>? arguments,
      bool appendPath = true,
      bool postFrame = false}) async {
    assert(
        name.startsWith("/"), "Name must start with `/` to match a RouteInfo");

    // Verify last page in stack on mobile devices
    if (!kIsWeb && pages.isNotEmpty) {
      var lastPage = pages.last;
      if (lastPage.page.name == name) {
        // return;
      }
    }

    var path = Uri.base.path
        .replaceAll(routeManager.basePath ?? "", "")
        .removeLastSlash(ignoreIfUnique: false);

    if (!appendPath) {
      path = name;
      pathUrl = name;
    } else {
      path += name;
      pathUrl = pathUrl.removeLastSlash(ignoreIfUnique: false);
      pathUrl += name;
    }

    if (!kIsWeb) {
      path = pathUrl;
    }

    var page =
        _createPage(RouteSettings(name: name, arguments: arguments), path);
    final pageInfo = PageInfo<T>(page: page, path: path);
    pages.add(pageInfo);

    if (postFrame) {
      WidgetsBinding.instance.addPostFrameCallback((ts) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
    return pageInfo.completer.future;
  }

  @Deprecated("Use 'push' instead. ")
  void pushPage(
          {required String name,
          Map<String, Object?>? arguments,
          bool appendPath = true,
          bool withScheduler = true}) =>
      push(
          name: name,
          arguments: arguments,
          appendPath: appendPath,
          postFrame: withScheduler);

  /// Removes the last page from stack and shows the previous one.
  ///
  /// If there is only one page in stack, this method does nothing to avoid errors.
  /// Returns the popped page.
  PageInfo? pop({Object? value, bool ignoreWillPopScope = true}) {
    if (!ignoreWillPopScope) {}
    PageInfo? page;
    if (pages.length != 1) {
      page = pages.removeLast();
      pathUrl = RouteHelper.removeLastPathSegment(pathUrl);
    }

    if (value != null) {
      page?.completer.complete(value);
    }
    notifyListeners();
    return page;
  }

  /// Pop all the pages in the stack, than pushes the root page.
  void popAll({bool postFrame = false}) {
    while (pages.isNotEmpty) {
      pages.removeLast();
    }

    final rootPath =
        routeManager.initialRouteInfo?.initialRouteName ?? RouteHelper.rootName;

    var page =
        _createPage(RouteSettings(name: rootPath, arguments: null), rootPath);
    pages.add(PageInfo(page: page, path: rootPath));

    if (postFrame) {
      WidgetsBinding.instance.addPostFrameCallback((ts) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  @Deprecated("Use 'popAll' instead. ")
  void popToRoot({bool withScheduler = true}) =>
      popAll(postFrame: withScheduler);

  /// Pop the last page in the stack and then pushes another page.
  /// This method is totally equivalent of calling [pop] and [push] respectively.
  ///
  /// For further information, check docs for those methods.
  void popAndPush(
      {required String name,
      Map<String, Object?>? arguments,
      bool postFrame = false}) {
    assert(
        name.startsWith("/"), "Name must start with `/` to match a RouteInfo");

    if (pages.isNotEmpty) {
      pages.removeLast();
    }
    pathUrl = RouteHelper.removeLastPathSegment(pathUrl);
    push(name: name, arguments: arguments, postFrame: postFrame);
  }

  @Deprecated("Use 'popAndPush' instead. ")
  void popAndPushPage(
          {required String name,
          Map<String, Object?>? arguments,
          bool withScheduler = true}) =>
      popAndPush(name: name, arguments: arguments, postFrame: withScheduler);

  /// Find the last page in stack with the provided `name` and pop all the pages
  /// after it in the stack.
  ///
  /// By default, if the page is not found in the stack, a new page is pushed
  /// with the provided `name` and `arguments` and, if specified, the `fullPath` is added.
  /// This behaviour can be avoided (so no action is taken if no page is found) by
  /// setting `pushIfNotPresent` parameter to _false_.
  void popTo(
      {required String name,
      bool pushIfNotPresent = true,
      bool postFrame = false,
      String? fullPath,
      Map<String, Object?>? arguments}) {
    assert(
        name.startsWith("/"), "Name must start with `/` to match a RouteInfo");

    var path = kIsWeb
        ? Uri.base.path.replaceAll(routeManager.basePath ?? "", "")
        : pathUrl;

    path = RouteHelper.getPathSegmentWithName(name: name, path: path);

    var page = pages.lastWhereOrNull((element) => element.path.endsWith(name));

    if (page != null) {
      while (pages.last.path != page.path) {
        pop();
      }
      return;
    }

    if (!pushIfNotPresent) {
      return;
    }

    if (fullPath != null) {
      path = fullPath;
    }

    if (path.isEmpty) {
      path = name;
    }

    pathUrl = path;

    push(
        name: name,
        arguments: arguments,
        appendPath: true,
        postFrame: postFrame);
  }

  @Deprecated("Use 'popTo' instead. ")
  void popToPage(
          {required String name,
          bool pushIfNotPresent = true,
          bool withScheduler = true,
          String? fullPath,
          Map<String, Object?>? arguments}) =>
      popTo(
          name: name,
          pushIfNotPresent: pushIfNotPresent,
          postFrame: withScheduler,
          fullPath: fullPath,
          arguments: arguments);

  /// This completer is used to handle returning values
  /// from [Page] in [pushAndWait] and [popWith] methods.
  Completer<Object?>? _resultCompleter;

  /// This is an equivalent method for [push] to await a return by the pushed page.
  /// The expected value type can be specified. This method should be used in combination with
  /// [popWith], otherwise idle behaviour can be experienced.
  ///
  /// ``` dart
  /// // Home page
  /// onTap: () async {
  ///   var result = await pushAndWait<bool>("/settings");
  ///   // Execution stops waiting for the result, then...
  ///   print(result);
  /// }
  ///
  /// // Settings page
  /// onTap: () {
  ///   popWith(true);
  /// }
  /// ```
  Future<T> pushAndWait<T>(
      {required String name, Map<String, Object?>? arguments}) async {
    assert(
        name.startsWith("/"), "Name must start with `/` to match a RouteInfo");

    _resultCompleter = Completer<T>();
    push(name: name, arguments: arguments);
    return (_resultCompleter as Completer<T>).future;
  }

  @Deprecated("Use 'pushAndWait' instead. ")
  Future<T> pushPageAndWait<T>(
          {required String name, Map<String, Object?>? arguments}) async =>
      pushAndWait(name: name, arguments: arguments);

  /// This is a method to pass returning value
  /// while popping the page. It can be considered as an
  /// alternative to returning value with `Navigator.pop(context, value)`.
  /// This method should be used in combination with [pushAndWait].
  ///
  /// ``` dart
  /// // Home page
  /// onTap: () async {
  ///   var result = await pushPageAndWait<bool>("/settings");
  ///   // Execution stops waiting for the result, then...
  ///   print(result);
  /// }
  ///
  /// // Settings page
  /// onTap: () {
  ///   popWith(true);
  /// }
  /// ```
  void popWith(Object? value) {
    if (_resultCompleter != null) {
      pop();
      _resultCompleter?.complete(value);
      notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (routeManager.onGenerateNavigatorContext != null &&
          navigatorContext != null) {
        routeManager.onGenerateNavigatorContext!(navigatorContext!);
      }
    });
    return Navigator(
      key: navigatorKey,
      pages: pages
          .map(
            (e) => e.page,
          )
          .toList(),
      onPopPage: _onPopPage,
      transitionDelegate: routeManager.transitionDelegate,
    );
  }

  MaterialPage _createPage(RouteSettings routeSettings, String path) {
    //TODO implement a customizable 404
    Widget child = routeManager.defaultRouteWidget ?? Container();

    RouteInfo? routeInfo = routeManager.routesInfo
        .singleWhereOrNull((element) => element.name == routeSettings.name);

    if (routeInfo != null) {
      child = routeInfo
          .routeWidget(routeSettings.arguments as Map<String, Object?>?);
    }

    getPage() {
      return Builder(builder: (context) {
        if (routeManager.initialRouteInfo?.initialRouteName ==
                routeInfo?.name &&
            routeManager.initialRouteInfo?.redirectToPath != null) {
          final redirectPath =
              routeManager.initialRouteInfo?.redirectToPath!(context);
          if (redirectPath != null) {
            popAndPush(name: redirectPath, postFrame: true);
            return routeManager.defaultRouteWidget ?? Container();
          }
        }

        if (routeManager.evaluateEnabledRoute == null ||
            routeManager.evaluateEnabledRoute!(context, path)) {
          return child;
        }

        popAll(postFrame: true);
        return routeManager.defaultRouteWidget ?? Container();
      });
    }

    return MaterialPage(
      child: WillPopScope(
          onWillPop:
              routeManager.allowSwipeToPopOnIOS ? null : () async => true,
          child: ((routeInfo?.requiresAuthentication ?? false) &&
                  routeManager.authenticationWrapper != null)
              ? routeManager.authenticationWrapper!(getPage())
              : getPage()),
      key: ValueKey(path +
          routeSettings.toString() +
          DateTime.now().millisecondsSinceEpoch.toString()),
      name: routeSettings.name,
      arguments: routeSettings.arguments,
    );
  }

  bool _onPopPage(Route route, dynamic result) {
    if (!route.didPop(result)) return false;
    popRoute();

    return true;
  }

  @override
  Future<bool> popRoute() async {
    if (pages.last.willpop != null) {
      var shouldPop = await pages.last.willpop!();
      if (shouldPop) {
        pathUrl = RouteHelper.removeLastPathSegment(pathUrl);
        pages.removeLast();
        notifyListeners();
      }
      return Future.value(true);
    }

    if (pages.length > 1) {
      pathUrl = RouteHelper.removeLastPathSegment(pathUrl);
      pages.removeLast();
      notifyListeners();
      return Future.value(true);
    }

    if (await Navigator.of(navigatorKey!.currentContext!).maybePop()) {
      return true;
    }

    var exit = await _confirmAppExit();

    if (exit == true) {
      SystemNavigator.pop();
      return Future.value(exit);
    }

    return true;
  }

  Future<bool?> _confirmAppExit() async {
    if (navigatorKey?.currentContext != null) {
      var confirm = await showDialog<bool>(
          context: navigatorKey!.currentContext!,
          builder: (context) {
            if (routeManager.closeAppAlertBuilder != null) {
              return routeManager.closeAppAlertBuilder!(
                  () => Navigator.pop(context, false),
                  () => Navigator.pop(context, true));
            }
            return AlertDialog(
              title: const Text('Chiudi App'),
              content:
                  const Text("Sei sicuro di voler chiudere l'applicazione?"),
              actions: [
                TextButton(
                  child: const Text('Annulla'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                TextButton(
                  child: const Text('Conferma'),
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            );
          });
      return confirm;
    } else {
      return Future(() => false);
    }
  }

  /// Add the specified willpop handler to the last page in navigation stack.
  /// This handler will be managed by the [RouteDelegate] when the route is popped.
  void addWillPopScopeToLastPage(Future<bool> Function() willpop) {
    pages.last.willpop = willpop;
  }

  /// Remove the willpop handler from the last page in navigation stack, if present.
  void removeWillPopScopeFromLastPage() {
    pages.last.willpop = null;
  }

  @override
  List<RouteSettingsInfo> get currentConfiguration =>
      List.of(pages.map((e) => RouteSettingsInfo(
          routeSettings:
              RouteSettings(name: e.page.name, arguments: e.page.arguments),
          path: e.path)));

  @override
  Future<void> setNewRoutePath(List<RouteSettingsInfo> configuration) {
    _setPath(configuration
        .map((routeSettings) => PageInfo(
            page: _createPage(routeSettings.routeSettings, routeSettings.path),
            path: routeSettings.path))
        .toList());
    return SynchronousFuture(null);
  }

  void _setPath(List<PageInfo> pagesList) {
    pages.clear();

    for (var page in pagesList) {
      pages.add(PageInfo(page: page.page, path: page.path));
    }

    notifyListeners();
  }
}
