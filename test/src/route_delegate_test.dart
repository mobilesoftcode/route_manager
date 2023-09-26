import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:route_manager/route_manager.dart';
import 'package:route_manager/src/information_parser.dart';
import 'package:route_manager/src/models/page_info.dart';
import 'package:route_manager/src/route_delegate.dart';

class MockTypedWidget extends StatelessWidget implements TypedRoute {
  const MockTypedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("Test");
  }

  @override
  Map<String, dynamic> toMap() {
    return {};
  }
}

void main() {
  test("Test assertion error for more routesInfo with the same name", () {
    expect(
        () => RouteDelegate(
              routeManager: RouteManager(
                routesInfo: [
                  RouteInfo(
                    name: "/",
                    routeWidget: (_) => Container(),
                  ),
                  RouteInfo(
                    name: "/",
                    routeWidget: (_) => Container(),
                  )
                ],
              ),
            ),
        throwsAssertionError);
  });

  testWidgets("Test navigator context existing", (widgetTester) async {
    final routerDelegate = RouteDelegate(
      routeManager: RouteManager(
        routesInfo: [
          RouteInfo(name: "/", routeWidget: (_) => Container()),
        ],
      ),
    );

    expect(routerDelegate.navigatorContext, null);

    await widgetTester.pumpWidget(MaterialApp.router(
      routerDelegate: routerDelegate,
      routeInformationParser: const InformationParser(),
    ));

    expect(routerDelegate.navigatorContext?.mounted, true);
  });

  group("Test pushNamed", () {
    late RouteDelegate routerDelegate;

    setUp(() {
      routerDelegate = RouteDelegate(
        routeManager: RouteManager(
          routesInfo: [
            RouteInfo(name: "/", routeWidget: (_) => Container()),
            RouteInfo(name: "/test1", routeWidget: (_) => Container()),
            RouteInfo(name: "/test2", routeWidget: (_) => Container()),
          ],
        ),
      );
    });
    test("Test verify pages length after pushing two pages", () {
      routerDelegate.pushNamed("/", postFrame: false);
      routerDelegate.pushNamed("/test1", postFrame: false);
      expect(routerDelegate.pages.length, 2);
    });

    test("Test pathUrl after pushing pages", () {
      routerDelegate.pushNamed("/", postFrame: false);
      routerDelegate.pushNamed("/test1", postFrame: false);
      expect(routerDelegate.pathUrl, "/test1");
      routerDelegate.pushNamed("/test2", postFrame: false);
      expect(routerDelegate.pathUrl, "/test1/test2");
    });

    test("Test path name for last page in stack", () {
      routerDelegate.pushNamed("/", postFrame: false);
      routerDelegate.pushNamed("/test1", postFrame: false);
      routerDelegate.pushNamed("/test2", postFrame: false);
      expect(routerDelegate.pages.last.path, "/test1/test2");
      expect(routerDelegate.pages.last.page.name, "/test2");
    });

    test("Test arguments in route pages", () {
      var args = {"query": "test"};
      routerDelegate.pushNamed("/", arguments: args, postFrame: false);
      expect(routerDelegate.pages.last.page.arguments, args);
    });

    test("Test masked arguments in route pages", () {
      var args = {"query": "test"};
      routerDelegate.pushNamed("/",
          arguments: args, maskArguments: true, postFrame: false);
      expect(routerDelegate.pages.last.page.arguments.runtimeType, String);

      expect(
          json.decode(utf8.decode(base64
              .decode(routerDelegate.pages.last.page.arguments as String))),
          args);
    });
  });

  group("Test push", () {
    late RouteDelegate routerDelegate;

    setUp(() {
      routerDelegate = RouteDelegate(
        routeManager: RouteManager(
          routesInfo: [
            RouteInfo(name: "/", routeWidget: (_) => Container()),
            TypedRouteInfo(
                name: "/test",
                routeWidget: (_) => const MockTypedWidget(),
                type: MockTypedWidget),
          ],
        ),
      );
    });
    test("Test verify pages length after pushing a page", () {
      routerDelegate.push(const MockTypedWidget());
      expect(routerDelegate.pages.length, 1);
    });
  });

  group("Test pop", () {
    late RouteDelegate routerDelegate;

    setUp(() {
      routerDelegate = RouteDelegate(
        routeManager: RouteManager(
          routesInfo: [
            RouteInfo(name: "/", routeWidget: (_) => Container()),
            TypedRouteInfo(
                name: "/test",
                routeWidget: (_) => const MockTypedWidget(),
                type: MockTypedWidget),
          ],
        ),
      );
    });
    test(
        "Test verify pages length not empty after popping a page with only one in the stack",
        () {
      routerDelegate.pages.add(PageInfo(
          page: const MaterialPage(child: MockTypedWidget()), path: "/test"));
      expect(routerDelegate.pages.length, 1);
      routerDelegate.pop();
      expect(routerDelegate.pages.length, 1);
    });

    test("Test verify pages length nafter popping a page", () {
      routerDelegate.pages.add(PageInfo(
          page: const MaterialPage(child: MockTypedWidget()), path: "/test"));
      routerDelegate.pages.add(PageInfo(
          page: const MaterialPage(child: MockTypedWidget()), path: "/test"));
      expect(routerDelegate.pages.length, 2);
      routerDelegate.pop();
      expect(routerDelegate.pages.length, 1);
    });

    test("Test pop without pages in the stack", () {
      routerDelegate.pop();
      expect(routerDelegate.pages.length, 0);
    });

    test("Test pop with return value", () async {
      routerDelegate.pages.add(PageInfo(
          page: const MaterialPage(child: MockTypedWidget()), path: "/test"));

      bool popped = false;
      routerDelegate
          .push(const MockTypedWidget())
          .then((value) => popped = true);
      expect(popped, false);
      await routerDelegate.pop(value: true);
      expect(popped, true);
    });

    test("Test pop without ignoring willPopScope", () {
      var pageInfo = PageInfo(
        page: const MaterialPage(child: MockTypedWidget()),
        path: "/test",
      );

      pageInfo.willpop = () async => false;
      routerDelegate.pages.add(pageInfo);
      routerDelegate.pop(ignoreWillPopScope: false);
      expect(routerDelegate.pages.length, 1);
    });
  });

  group("Test popAll", () {
    late RouteDelegate routerDelegate;

    setUp(() {
      routerDelegate = RouteDelegate(
        routeManager: RouteManager(
          routesInfo: [
            RouteInfo(name: "/", routeWidget: (_) => Container()),
            TypedRouteInfo(
                name: "/test",
                routeWidget: (_) => const MockTypedWidget(),
                type: MockTypedWidget),
          ],
        ),
      );
    });
    test("Test popping all the pages", () {
      routerDelegate.pages.add(PageInfo(
          page: const MaterialPage(child: MockTypedWidget()), path: "/test"));
      routerDelegate.popAll();
      expect(routerDelegate.pages.length, 1);
      expect(routerDelegate.pages.last.path, "/");
    });
  });

  group("Test pushReplacementNamed", () {
    late RouteDelegate routerDelegate;

    setUp(() {
      routerDelegate = RouteDelegate(
        routeManager: RouteManager(
          routesInfo: [
            RouteInfo(name: "/", routeWidget: (_) => Container()),
            TypedRouteInfo(
                name: "/test",
                routeWidget: (_) => const MockTypedWidget(),
                type: MockTypedWidget),
          ],
        ),
      );
    });
    test("Test pushing a replacement with name", () {
      routerDelegate.pages.add(PageInfo(
          page: const MaterialPage(child: MockTypedWidget()), path: "/home"));
      expect(routerDelegate.pages.length, 1);
      expect(routerDelegate.pages.last.path, "/home");

      routerDelegate.pushReplacementNamed("/test");
      expect(routerDelegate.pages.length, 1);
      expect(routerDelegate.pages.last.path, "/test");
    });
  });

  group("Test pushReplacement", () {
    late RouteDelegate routerDelegate;

    setUp(() {
      routerDelegate = RouteDelegate(
        routeManager: RouteManager(
          routesInfo: [
            RouteInfo(name: "/", routeWidget: (_) => Container()),
            TypedRouteInfo(
                name: "/test",
                routeWidget: (_) => const MockTypedWidget(),
                type: MockTypedWidget),
          ],
        ),
      );
    });
    test("Test pushing a replacement with widget", () {
      routerDelegate.pages.add(PageInfo(
          page: const MaterialPage(child: MockTypedWidget()), path: "/home"));
      expect(routerDelegate.pages.length, 1);
      expect(routerDelegate.pages.last.path, "/home");

      routerDelegate.pushReplacement(const MockTypedWidget());
      expect(routerDelegate.pages.length, 1);
      expect(routerDelegate.pages.last.path, "/test");
    });
  });
}
