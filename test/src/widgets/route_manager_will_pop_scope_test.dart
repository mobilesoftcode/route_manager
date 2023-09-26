import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:route_manager/route_manager.dart';

void main() {
  testWidgets("Test child shown in RouteManagerWillPopScope",
      (widgetTester) async {
    final routeManager = RouteManager(routesInfo: [
      RouteInfo(
        name: "/",
        routeWidget: (_) => RouteManagerWillPopScope(
          onWillPop: () async {
            return true;
          },
          child: const Text("Test"),
        ),
      )
    ]);
    await widgetTester.pumpWidget(
      MaterialApp.router(
        routerDelegate: routeManager.routerDelegate,
        routeInformationParser: routeManager.informationParser,
      ),
    );

    expect(find.text("Test"), findsOneWidget);
  });

  testWidgets("Test block navigation pop with Navigator", (widgetTester) async {
    final routeManager = RouteManager(routesInfo: [
      RouteInfo(
        name: "/",
        routeWidget: (_) => RouteManagerWillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Builder(builder: (context) {
            return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Test"));
          }),
        ),
      )
    ]);
    await widgetTester.pumpWidget(
      MaterialApp.router(
        routerDelegate: routeManager.routerDelegate,
        routeInformationParser: routeManager.informationParser,
      ),
    );

    await widgetTester.tap(find.text("Test"));
    await widgetTester.pump();

    expect(find.text("Test"), findsOneWidget);
  });

  testWidgets("Test do not block navigation pop with Navigator",
      (widgetTester) async {
    final routeManager = RouteManager(routesInfo: [
      RouteInfo(
        name: "/",
        routeWidget: (_) => Builder(builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RouteManagerWillPopScope(
                          onWillPop: () async {
                            return true;
                          },
                          child: Builder(builder: (context) {
                            return ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Test"));
                          }),
                        )));
          });
          return Container();
        }),
      )
    ]);
    await widgetTester.pumpWidget(
      MaterialApp.router(
        routerDelegate: routeManager.routerDelegate,
        routeInformationParser: routeManager.informationParser,
      ),
    );
    await widgetTester.pumpAndSettle();
    await widgetTester.tap(find.text("Test"));
    await widgetTester.pumpAndSettle();

    expect(find.text("Test"), findsNothing);
  });

  testWidgets("Test block navigation pop with RouterManager",
      (widgetTester) async {
    final routeManager = RouteManager(routesInfo: [
      RouteInfo(
        name: "/",
        routeWidget: (_) => RouteManagerWillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Builder(builder: (context) {
            return ElevatedButton(
                onPressed: () {
                  RouteManager.of(context).pop();
                },
                child: const Text("Test"));
          }),
        ),
      )
    ]);
    await widgetTester.pumpWidget(
      MaterialApp.router(
        routerDelegate: routeManager.routerDelegate,
        routeInformationParser: routeManager.informationParser,
      ),
    );

    await widgetTester.tap(find.text("Test"));
    await widgetTester.pumpAndSettle();

    expect(find.text("Test"), findsOneWidget);
  });

  testWidgets("Test do not block navigation pop with RouterManager",
      (widgetTester) async {
    final routeManager = RouteManager(routesInfo: [
      RouteInfo(
        name: "/",
        routeWidget: (_) => Builder(builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            RouteManager.of(context).pushNamed("/test");
          });
          return Container();
        }),
      ),
      RouteInfo(
        name: "/test",
        routeWidget: (_) => RouteManagerWillPopScope(onWillPop: () async {
          return true;
        }, child: Builder(builder: (context) {
          return ElevatedButton(
              onPressed: () {
                RouteManager.of(context).pop();
              },
              child: const Text("Test"));
        })),
      )
    ]);
    await widgetTester.pumpWidget(
      MaterialApp.router(
        routerDelegate: routeManager.routerDelegate,
        routeInformationParser: routeManager.informationParser,
      ),
    );
    await widgetTester.pumpAndSettle();
    await widgetTester.tap(find.text("Test"));
    await widgetTester.pumpAndSettle();

    expect(find.text("Test"), findsNothing);
  });

  testWidgets("Test WillPopScope ", (widgetTester) async {});
}
