import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:route_manager/route_manager.dart';

void main() {
  testWidgets("Test RouterManager showing default root route",
      (widgetTester) async {
    final routeManager = RouteManager(routesInfo: [
      RouteInfo(
          name: "/",
          routeWidget: (_) => RouterManager(
                  routeManager: RouteManager(routesInfo: [
                RouteInfo(name: "/", routeWidget: (_) => const Text("Test"))
              ])))
    ]);
    await widgetTester.pumpWidget(MaterialApp.router(
      routerDelegate: routeManager.routerDelegate,
      routeInformationParser: routeManager.informationParser,
    ));

    expect(find.text("Test"), findsOneWidget);
  });

  testWidgets("Test RouterManager showing custom initial route",
      (widgetTester) async {
    final routeManager = RouteManager(routesInfo: [
      RouteInfo(
          name: "/",
          routeWidget: (_) => RouterManager(
                  routeManager:
                      RouteManager(
                          initialRouteInfo:
                              InitialRouteInfo(initialRouteName: "/test"),
                          routesInfo: [
                    RouteInfo(
                        name: "/test", routeWidget: (_) => const Text("Test"))
                  ])))
    ]);
    await widgetTester.pumpWidget(MaterialApp.router(
      routerDelegate: routeManager.routerDelegate,
      routeInformationParser: routeManager.informationParser,
    ));

    expect(find.text("Test"), findsOneWidget);
  });

  testWidgets("Test RouterManager updating shown route", (widgetTester) async {
    final routeManager = RouteManager(routesInfo: [
      RouteInfo(
          name: "/",
          routeWidget: (_) {
            var initialRouteName = "/test1";
            return StatefulBuilder(builder: (context, setState) {
              return RouterManager(
                  routeManager: RouteManager(
                      initialRouteInfo:
                          InitialRouteInfo(initialRouteName: initialRouteName),
                      routesInfo: [
                    RouteInfo(
                        name: "/test1",
                        routeWidget: (_) => ElevatedButton(
                            onPressed: () {
                              setState(() {
                                initialRouteName = "/test2";
                              });
                            },
                            child: const Text("Test1"))),
                    RouteInfo(
                        name: "/test2",
                        routeWidget: (_) => const Text("Test2")),
                  ]));
            });
          })
    ]);
    await widgetTester.pumpWidget(MaterialApp.router(
      routerDelegate: routeManager.routerDelegate,
      routeInformationParser: routeManager.informationParser,
    ));

    expect(find.text("Test1"), findsOneWidget);
    await widgetTester.tap(find.text("Test1"));
    await widgetTester.pumpAndSettle();

    expect(find.text("Test1"), findsNothing);
    expect(find.text("Test2"), findsOneWidget);
  });
}
