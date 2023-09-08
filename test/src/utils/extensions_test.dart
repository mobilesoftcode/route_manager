import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:route_manager/src/models/route_info.dart';
import 'package:route_manager/src/utils/extensions.dart';

void main() {
  group("Extensions on string", () {
    test('Remove last slash from a string', () {
      expect("".removeLastSlash(), "");
      expect("/".removeLastSlash(), "/");
      expect("//".removeLastSlash(), "/");
      expect("/test".removeLastSlash(), "/test");
      expect("/test/".removeLastSlash(), "/test");
      expect("/test1/test2".removeLastSlash(), "/test1/test2");
      expect("test1/test2".removeLastSlash(), "test1/test2");
      expect("/test1/test2/".removeLastSlash(), "/test1/test2");
      expect("test1/test2/".removeLastSlash(), "test1/test2");
      expect("/test1/test2/test3".removeLastSlash(), "/test1/test2/test3");
    });

    test('Remove last slash from a string and not ignore if unique', () {
      expect("".removeLastSlash(ignoreIfUnique: false), "");
      expect("/".removeLastSlash(ignoreIfUnique: false), "");
      expect("//".removeLastSlash(ignoreIfUnique: false), "/");
      expect("/test".removeLastSlash(ignoreIfUnique: false), "/test");
      expect("/test/".removeLastSlash(ignoreIfUnique: false), "/test");
      expect("/test1/test2".removeLastSlash(ignoreIfUnique: false),
          "/test1/test2");
    });
    test('Remove initial slash from a string', () {
      expect("".removeInitialSlash(), "");
      expect("/".removeInitialSlash(), "");
      expect("//".removeInitialSlash(), "/");
      expect("/test".removeInitialSlash(), "test");
      expect("/test/".removeInitialSlash(), "test/");
      expect("/test1/test2".removeInitialSlash(), "test1/test2");
      expect("test1/test2".removeInitialSlash(), "test1/test2");
      expect("/test1/test2/".removeInitialSlash(), "test1/test2/");
      expect("test1/test2/".removeInitialSlash(), "test1/test2/");
      expect("/test1/test2/test3".removeInitialSlash(), "test1/test2/test3");
    });

    test('Add initial slash to a string', () {
      expect("".fixPathWithSlash(), "/");
      expect("/".fixPathWithSlash(), "/");
      expect("//".fixPathWithSlash(), "//");
      expect("/test".fixPathWithSlash(), "/test");
      expect("/test/".fixPathWithSlash(), "/test/");
      expect("/test1/test2".fixPathWithSlash(), "/test1/test2");
      expect("test1/test2".fixPathWithSlash(), "/test1/test2");
      expect("/test1/test2/".fixPathWithSlash(), "/test1/test2/");
      expect("test1/test2/".fixPathWithSlash(), "/test1/test2/");
      expect("/test1/test2/test3".fixPathWithSlash(), "/test1/test2/test3");
    });
  });
  test("Convert map to query string", () {
    Map map = {};
    expect(map.convertToQueryString(), "");

    map["query1"] = "test1";
    expect(map.convertToQueryString(), "?query1=test1");

    map["query2"] = 2;
    expect(map.convertToQueryString(), "?query1=test1&query2=2");

    map["query3"] = true;
    expect(map.convertToQueryString(), "?query1=test1&query2=2&query3=true");
  });

  test("Find same items in list", () {
    var list1 = ["Test1", "Test2", "Test3"];
    expect(list1.containsTwoItemsWithSame((item1, item2) => item1 == item2),
        false);

    list1.add("Test1");
    expect(
        list1.containsTwoItemsWithSame((item1, item2) => item1 == item2), true);

    var list2 = [
      RouteInfo(
        name: "/test1",
        routeWidget: (args) => Container(),
      ),
    ];
    expect(
        list2.containsTwoItemsWithSame(
            (item1, item2) => item1.name == item2.name),
        false);

    list2.add(
      RouteInfo(
        name: "/test2",
        routeWidget: (args) => Container(),
      ),
    );
    expect(
        list2.containsTwoItemsWithSame(
            (item1, item2) => item1.name == item2.name),
        false);

    list2.add(
      RouteInfo(
        name: "/test1",
        routeWidget: (args) => Container(),
      ),
    );
    expect(list2.containsTwoItemsWithSame((item1, item2) => item1 == item2),
        false);
    expect(
        list2.containsTwoItemsWithSame(
            (item1, item2) => item1.name == item2.name),
        true);
  });
}
