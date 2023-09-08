## 1.1.3
* Initial GitHub release, updated dependencies. Requires Dart 3.

## 1.1.2
* Added example app.

## 1.1.1
* Added deprecation notice for old APIs, added new `push`, `popTo`, `pushAndWait`, `popAll` APIs as replacement.

## 1.1.0
* **BREAKING** - Modified `initialRoute` parameter of `RouteManager` to `initialRouteInfo` to set a rule to redirect to a different root page.
* Added `authenticationWrapper` parameter to `RouteManager` and `requiresAuthentication` parameter to `RouteInfo` to specify an auth-guard widget to wrap routes.
* Fix to `popToRoot` method having unintended behaviour in case of initial route name different from "/"

## 1.0.5
Added `allowSwipeToPopOnIOS` parameter to `RouteManager` to disable the swipe to pop gesture on iOS.

## 1.0.4

Added the possibility to get the root `RouteManager` with the `of` method when using nested Routers.

## 1.0.3

Added a method to access the root navigator context in `RouteManager` constructor.

## 1.0.2

Added possibility to disable transitions animations when changing pages/routes with a parameter in `RouteManager`.

## 1.0.1

Added the `RouteManagerWillPopScope` widget to override the popRoute behaviour (such as when tapping the physical back button on Android).

## 1.0.0

First stable release. Added docs and readme, polished code.

## 0.0.1

Initial release. Contains an advanced implementation of "Navigator 2.0", completely customizable, to manage in-app routing and navigation, on every platform.
This release exposes the following widgets and methods:

* RouteManager
* RouteInfo
* RouterManager