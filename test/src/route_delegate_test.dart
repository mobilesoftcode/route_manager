import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:route_manager/route_manager.dart';
import 'package:route_manager/src/information_parser.dart';
import 'package:route_manager/src/route_delegate.dart';

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

  group("Test pushPage", () {
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

    test(
        "Test try to push same page twice should push only one page (on mobile devices)",
        () {
      routerDelegate.pushNamed("/", postFrame: false);
      routerDelegate.pushNamed("/", postFrame: false);
      expect(routerDelegate.pages.length, 1);
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
  });

  // TODO add missing tests
}
