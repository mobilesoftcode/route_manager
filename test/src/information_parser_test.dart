import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:route_manager/src/helpers/route_helper.dart';
import 'package:route_manager/src/information_parser.dart';
import 'package:route_manager/src/models/route_settings_info.dart';

void main() {
  final Uri uri = Uri.parse(
      "https://www.test.com/test1/test2/test3?query1=test1&query2=test2");

  test("Test parseRouteInformation", () async {
    const InformationParser informationParser = InformationParser();

    var result = await informationParser
        .parseRouteInformation(RouteInformation(uri: uri));

    expect(result.length, uri.pathSegments.length);
  });
  group("Test retrieveRouteSettingsFromUri", () {
    test("Retrieve route settings from a uri", () {
      const InformationParser informationParser = InformationParser();

      final routeSettings = informationParser.retrieveRouteSettingsFromUri(uri);

      expect(routeSettings.length, uri.pathSegments.length);

      for (var routeInformation in routeSettings) {
        expect(routeInformation.path,
            endsWith(routeInformation.routeSettings.name ?? ""));
      }

      if (uri.query.isNotEmpty) {
        expect(routeSettings.last.routeSettings.arguments.runtimeType,
            UnmodifiableMapView<String, String>);
      }

      expect(
          routeSettings.first.routeSettings.name, "/${uri.pathSegments.first}");
    });

    test(
        "Retrieve route settings from a uri with evaluateEnabledRoute set to false (all routes should be popped)",
        () {
      final informationParser =
          InformationParser(evaluateEnabledRoute: (_, path) => false);

      final routeSettings = informationParser.retrieveRouteSettingsFromUri(uri);

      expect(routeSettings.length, 1);

      expect(routeSettings.first.routeSettings.name, "/");
    });
  });

  test(
      "Restore route informations from route settings with empty configuration",
      () {
    const InformationParser informationParser = InformationParser();

    final routeSettings = informationParser.restoreRouteInformation([]);

    expect(routeSettings.uri.path, "/");
  });

  test(
      "Restore route arguments from route settings with no restoreQueryFromArguments property set for route info",
      () {
    const InformationParser informationParser = InformationParser();

    final routeSettings = informationParser.retrieveRouteSettingsFromUri(uri);

    var arguments = informationParser.restoreArguments(routeSettings.first);

    expect(arguments, "");

    arguments = informationParser.restoreArguments(routeSettings.last);

    expect(arguments, "?query1=test1&query2=test2");
  });

  test("Restore route arguments from route settings with String as argument",
      () {
    const InformationParser informationParser = InformationParser();

    var arguments = informationParser.restoreArguments(RouteSettingsInfo(
        routeSettings: const RouteSettings(name: "/test", arguments: "test"),
        path: "/test"));

    expect(arguments, "${RouteHelper.base64QueryParam}test");
  });
}
