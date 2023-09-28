import 'dart:async';
import 'dart:convert';

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
  /// Arguments must be a [Map] and they can be managed by the [AbstractRouteInfo] builder parameter.
  ///
  /// If `postFrame` is _true_, the page is pushed in the stack the frame after
  /// this method is called. Useful if called directly in the _build_ method. Defaults
  /// to _false_.
  ///
  /// If you want to pass a page as a [Widget] instead of name + arguments, you can use
  /// the [push] method instead.
  ///
  /// If `maskArguments` is _true_, the query parameters in url are masked as a base64 string
  /// to hide values on browsers. Defaults to _false_.
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
  Future<T?> pushNamed<T>(
    String name, {
    Map<String, Object?>? arguments,
    bool maskArguments = false,
    bool postFrame = false,
  }) {
    assert(name.startsWith("/"),
        "Name must start with `/` to match an AbstractRouteInfo");

    pathUrl = pathUrl.removeLastSlash(ignoreIfUnique: false) + name;

    var args = maskArguments
        ? base64.encode(utf8.encode(jsonEncode(arguments)))
        : arguments;

    var page = _createPage(RouteSettings(name: name, arguments: args), pathUrl);
    final pageInfo = PageInfo<T>(page: page, path: pathUrl);
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

  /// Push a new page in the stack with a default transition animation.
  /// Instead of passing a name and a [Map] of arguments, you can pass a [Widget] directly
  /// to be pushed in the navigation stack. Note that the [Widget] must extend [TypedRoute]
  /// and its route must be declared in the routes info list in [RouteManager], otherwise
  /// no page will be pushed.
  ///
  /// If `postFrame` is _true_, the page is pushed in the stack the frame after
  /// this method is called. Useful if called directly in the _build_ method. Defaults
  /// to _false_.
  ///
  /// If `maskArguments` is _true_, the query parameters in url are masked as a base64 string
  /// to hide values on browsers. Defaults to _false_.
  Future<T?> push<T>(
    TypedRoute typedRoute, {
    bool maskArguments = false,
    bool postFrame = false,
  }) async {
    final name = routeManager.routesInfo.singleWhereOrNull((element) {
      return element is TypedRouteInfo &&
          element.type == typedRoute.runtimeType;
    })?.name;
    if (name == null) {
      assert(name != null,
          "An AbstractRouteInfo with name $name should be included in routeInfo");
      return null;
    }

    return pushNamed(
      name,
      arguments: typedRoute.toMap(),
      maskArguments: maskArguments,
      postFrame: postFrame,
    );
  }

  /// Removes the last page from stack and shows the previous one.
  ///
  /// If there is only one page in stack, this method does nothing to avoid errors.
  /// Returns the popped page.
  ///
  /// If a `value` is specified, the completer associated to the popped paged will be
  /// completed and the pushing route will be notified with the provided value.
  Future<PageInfo?> pop({Object? value, bool ignoreWillPopScope = true}) async {
    if (!ignoreWillPopScope) {
      final pageWillPopScope = pages.lastOrNull?.willpop;
      if (pageWillPopScope != null) {
        var shouldPop = await pageWillPopScope();
        if (!shouldPop) {
          return null;
        }
      }
    }

    PageInfo? page;
    if (pages.length > 1) {
      page = pages.removeLast();
      pathUrl = RouteHelper.removeLastPathSegment(pathUrl);
    }

    if (value != null) {
      page?.completer.complete(value);
    }
    notifyListeners();

    // This delay is needed to await listeners to be notified and update UI
    await Future.delayed(const Duration(milliseconds: 100));
    return page;
  }

  /// Pop all the pages in the stack, than pushes the root page.
  void popAll({bool postFrame = false}) {
    while (pages.isNotEmpty) {
      pages.removeLast();
    }

    final rootPath =
        routeManager.initialRouteInfo?.initialRouteName ?? RouteHelper.rootName;
    pathUrl = rootPath;

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

  /// Pop the last page in the stack and then pushes another page.
  /// This method is totally equivalent of calling [pop] and [pushNamed] respectively.
  ///
  /// For further information, check docs for those methods.
  Future<T?> pushReplacementNamed<T>(String name,
      {Map<String, Object?>? arguments,
      bool maskArguments = false,
      bool postFrame = false}) {
    if (pages.isNotEmpty) {
      pages.removeLast();
    }
    pathUrl = RouteHelper.removeLastPathSegment(pathUrl);
    return pushNamed(name,
        arguments: arguments,
        maskArguments: maskArguments,
        postFrame: postFrame);
  }

  /// Pop the last page in the stack and then pushes another page.
  /// This method is totally equivalent of calling [pop] and [push] respectively.
  ///
  /// For further information, check docs for those methods.
  Future<T?> pushReplacement<T>(TypedRoute typedRoute,
      {bool maskArguments = false, bool postFrame = false}) {
    if (pages.isNotEmpty) {
      pages.removeLast();
    }
    pathUrl = RouteHelper.removeLastPathSegment(pathUrl);
    return push(typedRoute, maskArguments: maskArguments, postFrame: postFrame);
  }

  /// Find the last page in stack with the provided `name` and pop all the pages
  /// after it in the stack.
  ///
  /// By default, if the page is not found in the stack, a new page is pushed
  /// with the provided `name` and `arguments` and, if specified, the `fullPath` is added.
  /// This behaviour can be avoided (so no action is taken if no page is found) by
  /// setting `pushIfNotPresent` parameter to _false_.
  ///
  /// If a `value` is specified, the completer associated to the popped paged will be
  /// completed and the pushing route will be notified with the provided value.
  void popTo(
    String name, {
    Object? value,
    bool pushIfNotPresent = true,
    String? fullPath,
    Map<String, Object?>? arguments,
    bool maskArguments = false,
    bool postFrame = false,
  }) {
    assert(name.startsWith("/"),
        "Name must start with `/` to match a AbstractRouteInfo");

    var path = kIsWeb
        ? Uri.base.fragment.replaceAll(routeManager.basePath ?? "", "")
        : pathUrl;

    path = RouteHelper.getPathSegmentWithName(name: name, path: path);
    var page = pages.lastWhereOrNull((element) => element.path.endsWith(name));

    if (page != null) {
      while (pages.last.path != page.path) {
        pop();
      }
      if (value != null) {
        page.completer.complete(value);
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

    pushNamed(name,
        arguments: arguments,
        maskArguments: maskArguments,
        postFrame: postFrame);
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
    Widget child = routeManager.defaultRouteWidget ?? Container();

    AbstractRouteInfo? routeInfo = routeManager.routesInfo
        .singleWhereOrNull((element) => element.name == routeSettings.name);

    var arguments = routeSettings.arguments;
    if (arguments is Map &&
        arguments
            .convertToQueryString()
            .startsWith(RouteHelper.base64QueryParam)) {
      arguments = arguments
          .convertToQueryString()
          .replaceFirst(RouteHelper.base64QueryParam, "");
    }
    Map<String, Object?>? args;

    if (arguments is Map<String, Object?>?) {
      args = arguments;
    } else if (arguments is String) {
      String decoded = utf8.decode(base64.decode(arguments));
      try {
        args = jsonDecode(decoded);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }

    if (routeInfo != null) {
      try {
        child = routeInfo.routeWidget(args);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }

    getPage() {
      return Builder(builder: (context) {
        if (routeManager.initialRouteInfo?.initialRouteName ==
                routeInfo?.name &&
            routeManager.initialRouteInfo?.redirectToPath != null) {
          final redirectPath =
              routeManager.initialRouteInfo?.redirectToPath!(context);
          if (redirectPath != null) {
            pushReplacementNamed(redirectPath, postFrame: true);
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
