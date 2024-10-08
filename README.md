This package provides an advanced but easy-to-use implementation of "Navigator 2.0" to manage navigation and routing on every platform. It supports url changes on web, deeplinking on mobile and nested routes.

## Features

This package contains:

* **RouteManager**
<br>

The `RouteManager` is responsible of creating and storing the `RouteDelegate`, the `InformationParser` and the `CustomTransitionDelegate` to manage routing such as pushing and popping pages.

* **RouteInfo**
<br>

It is a class used to set the route name, the route child widget to display when the path is pointing to this route, and eventually a function to map query from arguments can be provided.

* **InitialRouteInfo**
<br>

It is a class that contains info about the initial route. It is used to set the initial route name (that defaults to "/" if not specified) and eventually a method to specify a path to use as redirect if a condition is not met.

* **RouteManagerWillPopScope**
<br>

It is a widget to override the popRoute event handler and to handle the pop action such as when tapping the physical back button on Android devices. It's similar to `WillPopScope` widget used with Navigator. Note that to block swipe gesture to go back on iOS you must use the `allowSwipeToPopOnIOS` property in `RouteManager` constructor.

* **RouterManager**
<br>

It's a widget to use in the widget tree to create a nested route, and it is initialised with a `RouteManager` parameter.

## Getting started

To get started, simply [install](https://pub.dev/packages/route_manager/install) the package adding the dependency

## Usage

Check the usage paragraph according to your needs.

### RouteInfo

This class contains info about a route. It is used to set the route name, the route child widget to display when the path is pointing to this route, and eventually a function to map query from arguments can be provided. Furthermore, if `requiredAuthentication` is set to _true_ (default to _false_), the `authenticationWrapper` widget specified in the `RouteManager` constructor will be used as wrapper for the `routeWidget`.

``` dart
var routeInfo = RouteInfo(
    name: "/home",
    requiresAuthentication: false,
    routeWidget: (args) => HomeScreen(),
);
```

To manage routes pushing directly widgets instead of using names, you can use the `TypedRouteInfo` class. It's similar to `RouteInfo`, but required explicitally setting the type of the `Widget` that will be pushed in the navigation stack.

``` dart
var routeInfo = TypedRouteInfo(
    name: "/home",
    requiresAuthentication: false,
    type: HomeScreen,
    routeWidget: (args) => HomeScreen(),
);
```

Eventually you can define path parameters using the `:` symbol. Then you can retrieve the path parameter from `args`. For example:

``` dart
var routeInfo = RouteInfo(
    name: "/detail/:id",
    requiresAuthentication: false,
    routeWidget: (args) => DetailScreen(
      id: args?["id"]
    ),
);
```

### InitialRouteInfo

This class contains info about the initial route. It is used to set the route name and eventually a method to specify a path to use as redirect if a condition is not met.

``` dart
var initialRouteInfo = InitialRouteInfo(
  initialRouteName: "/",
  redirectToPath: (context) {
    // Verify a condition to redirect the user to another page instead of the root
    if (user.isAdmin) {
      return "/admin";
    }
    return null;
  }
);
```

### RouteManager

`RouteManager` manage routing for a custom route. The app can have multiple route managers, but at least one to be used as the root router in `MaterialApp`.
 The `RouteManager` is responsible of creating and storing the `RouteDelegate`, the `InformationParser` and the `CustomTransitionDelegate` to manage routing such as pushing and popping pages.

It must be used to initialize the routing system. To use it in the root `MaterialApp` routing, instantiate the MaterialApp with the `MaterialApp.router` constructor and then pass the created `RouteDelegate` and `InformationParser`, as shown in the following example.

``` dart
final routeManager = RouteManager(
    routesInfo: // Must be provided to specify all the possibile Route pages
    [
        RouteInfo(name: "/", routeWidget: (args) => SplashScreen()), 
        RouteInfo(name: "/home", routeWidget: (args) => HomeScreen()), 
        TypedRouteInfo(name: "/test", routeWidget: (args) => TestScreen(), type: TestScreen), 
    ],
    initialRouteInfo: InitialRouteInfo(
      initialRouteName: "/home",
      redirectToPath: (context) {
        if (user.isAdmin) {
          return "/admin";
        }
        return null;
      }
    ), // Optional, to specify an custom initial route if different from "/" and eventually a path to redirect the user if he should not see the initial route (i.e. for specific roles after authenticating)
    defaultRouteWidget: Text("404"), // Optional, to specify a custom widget to show if no route widget is find for a specified name
    basePath: "/app", // Optionally, used on web to match a custom base href in the index.html file, if different from "/"
    evaluateEnabledRoute: (path) => true, // Optional, to add some logic for a specific path to eventually block access to that page. It can be used, for example to avoid entering some page for non-admin users.
    allowSwipeToPopOnIOS: true, // Optional, if it's _false_, the default swipe gesture to pop page on iOS is blocked
    enableTransitionAnimation;: true, // Boolean value to specify if route transitions will be executed without animations
    authenticationWrapper: (child) => Container(child: child), // Optional, you can specify a widget to use as authentication wrapper for the routes that are defined as `requiresAuthentication` in the `routesInfo` list.
    onGenerateNavigatorContext: (context) {},  /// Optional, this method can be used to access the navigator context
);

@override
Widget build(BuildContext context) {
   return MaterialApp.router(
     routeInformationParser: routeManager.informationParser,
     routerDelegate: routeManager.routerDelegate,
   );
 }
```

### RouteManagerWillPopScope

 To override the popRoute handler of `RouteDelegate`, and handle the pop action event for a scecific page (such as when tapping the physical back button on Android devices), you can use the `RouteManagerWillPopScope` widget, in the same way you could use the `WillPopScope` widget when working with `Navigator`.

``` dart
return RouteManagerWillPopScope(
  child: child,
  // The method to call _before_ the pop action is effectively taken.
  // If the callback returns a Future that resolves to false, the enclosing route will not be popped.
  onWillPop: _onWillPop,
);
```

### RouterManager

 To use another `RouteManager` in app, the `RouterManager` widget can be similarly used as shown in the following code. This is helpful to handle nested routes. Consider that only the `RouteManager` provided in the `MaterialApp` has the ability to change the url on web platform.

``` dart
final routeManager = RouteManager(routesInfo: [
   RouteInfo(name: "/home", routeWidget: (args) => Container()),
]);

@override
Widget build(BuildContext context) {
  return RouterManager(
    routeManager: routeManager,
  );
}
```

### RouteDelegate

The `RouteDelegate` instance to push/pop pages can be accessed by calling:

``` dart
final routerDelegate = RouterManager.of(context);
```

In this way you can find the nearest `RouterManager` ancestor in the widget tree. If you have nested `RouteDelegate`, for example when using the `RouterManager` widget, you can access the root `RouteManager` instance as follows.

``` dart
final rootRouterDelegate = RouterManager.of(context, rootNavigator: true);
```

It is also possible to access the router delegate as follows (even if not recommended):

``` dart
final routeManager = RouteManager(
  [...]
);
var routerDelegate = routeManager.routerDelegate;
```

Note that you need the `context` to use the route delegate. If you want to use it outside a widget with `context`, you should take care on your own to store an application's global context, or to share the `RouteManager` instance globally in the project to access it everywhere. This behaviour is discouraged and so there is no out-of-the-box implementation for it.

**Router Delegate methods**

* Push a new page in the stack with name. Optionally, a [Map] argument can be passed to be processed by the `routeWidget` builder as specified in the `routesInfo` list provided to the `RouteManager`. You can eventually await for a result popped by the pushed route.

``` dart
var result = await RouteManager.of(context).pushNamed<bool>("/home", arguments: {"title": "Hello World"});
```

* Push a new page in the stack as a `Widget`. You can eventually await for a result popped by the pushed route.

``` dart
var result = await RouteManager.of(context).push<bool>(TestScreen());
```

* Pop a page from the stack. You can eventually return a value to the completer that pushed the page (see `push` or `pushNamed` APIs)

``` dart
var poppedPage = await RouteManager.of(context).pop(value: true);
```

* Pop the last page in the stack and push a new one with name

``` dart
RouteManager.of(context).pushReplacementNamed("/home", arguments: {'test': true});
```

* Pop the last page in the stack and push a new one as a widget

``` dart
RouteManager.of(context).pushReplacement(TestScreen());
```

* Pop all the pages in the stack and push the root page

``` dart
RouteManager.of(context).popAll();
```

* Pop to the last page with specified name in the stack

``` dart
RouteManager.of(context).popTo("/home");
```

* Show dialog

``` dart
RouteManager.of(context).showDialog(builder: (context) => Dialog(child: Text("Hello world")));
```

* Show modal (either full screen or not, and eventually draggable)

``` dart
RouteManager.of(context).showModal(builder: (context) => Scaffold(body: Text("Hello world")));
```

## Additional information

This package is mantained by the Competence Center Flutter of Mobilesoft Srl.
