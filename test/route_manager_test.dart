import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:route_manager/route_manager.dart';
import 'package:route_manager/src/route_delegate.dart';

void main() {
  test('Test RouteManager with two equal paths throwing an assertion error',
      () {
    expect(
        () => RouteManager(routesInfo: [
              RouteInfo(name: "/test", routeWidget: (_) => Container()),
              RouteInfo(name: "/test", routeWidget: (_) => Container())
            ]),
        throwsAssertionError);
  });

  testWidgets(
      "Test 'of' method to get the inner RouteManager instance in nested navigation",
      (widgetTester) async {
    RouteDelegate? recognizedRouteDelegate;
    final routerManager = RouteManager(routesInfo: [
      RouteInfo(
          name: "/",
          routeWidget: (_) => RouterManager(
                  routeManager: RouteManager(routesInfo: [
                RouteInfo(
                  name: "/",
                  routeWidget: (_) => Scaffold(
                    body: Builder(
                      builder: (context) => InkWell(
                        onTap: () =>
                            recognizedRouteDelegate = RouteManager.of(context),
                        child: const Text("Tap"),
                      ),
                    ),
                  ),
                ),
                RouteInfo(name: "/test", routeWidget: (_) => Container())
              ])))
    ]);
    await widgetTester.pumpWidget(MaterialApp.router(
      routerDelegate: routerManager.routerDelegate,
      routeInformationParser: routerManager.informationParser,
    ));

    await widgetTester.tap(find.text("Tap"));
    expect(recognizedRouteDelegate?.routeManager.routesInfo.length, 2);
  });

  testWidgets(
      "Test 'of' method to get the root RouteManager instance in nested navigation",
      (widgetTester) async {
    RouteDelegate? recognizedRouteDelegate;
    final routerManager = RouteManager(routesInfo: [
      RouteInfo(
          name: "/",
          routeWidget: (_) => RouterManager(
                  routeManager: RouteManager(routesInfo: [
                RouteInfo(
                  name: "/",
                  routeWidget: (_) => Scaffold(
                    body: Builder(
                      builder: (context) => InkWell(
                        onTap: () => recognizedRouteDelegate =
                            RouteManager.of(context, rootNavigator: true),
                        child: const Text("Tap"),
                      ),
                    ),
                  ),
                ),
                RouteInfo(name: "/test", routeWidget: (_) => Container())
              ])))
    ]);
    await widgetTester.pumpWidget(MaterialApp.router(
      routerDelegate: routerManager.routerDelegate,
      routeInformationParser: routerManager.informationParser,
    ));

    await widgetTester.tap(find.text("Tap"));
    expect(recognizedRouteDelegate?.routeManager.routesInfo.length, 1);
  });

  testWidgets("Test navigator context existing", (widgetTester) async {
    final routerManager = RouteManager(
      routesInfo: [
        RouteInfo(name: "/", routeWidget: (_) => Container()),
      ],
    );

    expect(routerManager.navigatorContext, null);

    await widgetTester.pumpWidget(MaterialApp.router(
      routerDelegate: routerManager.routerDelegate,
      routeInformationParser: routerManager.informationParser,
    ));

    expect(routerManager.navigatorContext?.mounted, true);
  });
}
