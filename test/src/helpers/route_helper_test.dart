import 'package:flutter_test/flutter_test.dart';
import 'package:route_manager/src/helpers/route_helper.dart';

void main() {
  test('Retrieve last segment from a path', () {
    expect(RouteHelper.getLastPathSegment(null), "");
    expect(RouteHelper.getLastPathSegment("/"), "/");
    expect(() => RouteHelper.getLastPathSegment("test"), throwsAssertionError);
    expect(RouteHelper.getLastPathSegment("/test"), "/test");
    expect(RouteHelper.getLastPathSegment("/test/"), "/test");
    expect(() => RouteHelper.getLastPathSegment("test/"), throwsAssertionError);
    expect(RouteHelper.getLastPathSegment("/test1/test2"), "/test2");
    expect(() => RouteHelper.getLastPathSegment("test1/test2"),
        throwsAssertionError);
    expect(RouteHelper.getLastPathSegment("/test1/test2/"), "/test2");
    expect(() => RouteHelper.getLastPathSegment("test1/test2/"),
        throwsAssertionError);
    expect(RouteHelper.getLastPathSegment("/test1/test2/test3"), "/test3");
    expect(() => RouteHelper.getLastPathSegment("test1/test2/test3"),
        throwsAssertionError);
    expect(RouteHelper.getLastPathSegment("/test1/test2/test3/"), "/test3");
    expect(() => RouteHelper.getLastPathSegment("test1/test2/test3/"),
        throwsAssertionError);
    expect(() => RouteHelper.getLastPathSegment("test1test2/test3"),
        throwsAssertionError);
    expect(RouteHelper.getLastPathSegment("/test1test2/test3"), "/test3");
    expect(
        RouteHelper.getLastPathSegment("/test1/test2/test3/test4"), "/test4");
  });

  test('Retrieve initial segment from a path', () {
    expect(RouteHelper.getFirstPathSegment(null), "");
    expect(RouteHelper.getFirstPathSegment("/"), "/");
    expect(() => RouteHelper.getFirstPathSegment("test"), throwsAssertionError);
    expect(RouteHelper.getFirstPathSegment("/test"), "/test");
    expect(RouteHelper.getFirstPathSegment("/test/"), "/test");
    expect(
        () => RouteHelper.getFirstPathSegment("test/"), throwsAssertionError);
    expect(RouteHelper.getFirstPathSegment("/test1/test2"), "/test1");
    expect(() => RouteHelper.getFirstPathSegment("test1/test2"),
        throwsAssertionError);
    expect(RouteHelper.getFirstPathSegment("/test1/test2/"), "/test1");
    expect(() => RouteHelper.getFirstPathSegment("test1/test2/"),
        throwsAssertionError);
    expect(RouteHelper.getFirstPathSegment("/test1/test2/test3"), "/test1");
    expect(() => RouteHelper.getFirstPathSegment("test1/test2/test3"),
        throwsAssertionError);
    expect(RouteHelper.getFirstPathSegment("/test1/test2/test3/"), "/test1");
    expect(() => RouteHelper.getFirstPathSegment("test1/test2/test3/"),
        throwsAssertionError);
    expect(() => RouteHelper.getFirstPathSegment("test1test2/test3"),
        throwsAssertionError);
    expect(RouteHelper.getFirstPathSegment("/test1test2/test3"), "/test1test2");
    expect(
        RouteHelper.getFirstPathSegment("/test1/test2/test3/test4"), "/test1");
  });

  test("Remove last path segment", () {
    expect(RouteHelper.removeLastPathSegment(null), "");
    expect(RouteHelper.removeLastPathSegment("/"), "/");
    expect(
        () => RouteHelper.removeLastPathSegment("test"), throwsAssertionError);
    expect(RouteHelper.removeLastPathSegment("/test"), "/");
    expect(RouteHelper.removeLastPathSegment("/test/"), "/");
    expect(
        () => RouteHelper.removeLastPathSegment("test/"), throwsAssertionError);
    expect(RouteHelper.removeLastPathSegment("/test1/test2"), "/test1");
    expect(() => RouteHelper.removeLastPathSegment("test1/test2"),
        throwsAssertionError);
    expect(RouteHelper.removeLastPathSegment("/test1/test2/"), "/test1");
    expect(() => RouteHelper.removeLastPathSegment("test1/test2/"),
        throwsAssertionError);
    expect(RouteHelper.removeLastPathSegment("/test1/test2/test3"),
        "/test1/test2");
    expect(() => RouteHelper.removeLastPathSegment("test1/test2/test3"),
        throwsAssertionError);
    expect(RouteHelper.removeLastPathSegment("/test1/test2/test3/"),
        "/test1/test2");
  });

  test('Retrieve a named segment in a path', () {
    expect(() => RouteHelper.getPathSegmentWithName(name: "", path: ""),
        throwsAssertionError);
    expect(() => RouteHelper.getPathSegmentWithName(name: "test", path: ""),
        throwsAssertionError);
    expect(() => RouteHelper.getPathSegmentWithName(name: "/test", path: ""),
        throwsAssertionError);
    expect(
        () => RouteHelper.getPathSegmentWithName(name: "test", path: "/test"),
        throwsAssertionError);
    expect(RouteHelper.getPathSegmentWithName(name: "/test", path: "/test"),
        "/test");
    expect(
        () => RouteHelper.getPathSegmentWithName(name: "/test", path: "test"),
        throwsAssertionError);
    expect(
        RouteHelper.getPathSegmentWithName(name: "/test", path: "/test1/test2"),
        "");
    expect(
        () => RouteHelper.getPathSegmentWithName(
            name: "test", path: "/test1/test2"),
        throwsAssertionError);
    expect(
        RouteHelper.getPathSegmentWithName(
            name: "/test1", path: "/test1/test2/"),
        "/test1");
    expect(
        RouteHelper.getPathSegmentWithName(
            name: "/test2", path: "/test1/test2"),
        "/test1/test2");
    expect(
        RouteHelper.getPathSegmentWithName(
            name: "/test2", path: "/test1/test2/test3"),
        "/test1/test2");
    expect(
        () => RouteHelper.getPathSegmentWithName(
            name: "test2", path: "/test1/test2/"),
        throwsAssertionError);
    expect(
        () => RouteHelper.getPathSegmentWithName(
            name: "test1/", path: "/test1/test2"),
        throwsAssertionError);
  });
}
