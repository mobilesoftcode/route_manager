import 'package:flutter/material.dart';
import 'package:route_manager/route_manager.dart';
import 'package:route_manager_example/details_screen.dart';
import 'detail_screen.dart';
import 'home_screen.dart';
import 'number_screen.dart';

final routeManager = RouteManager(
  routesInfo: [
    RouteInfo(name: "/", routeWidget: (args) => const HomeScreen()),
    RouteInfo(name: "/detail", routeWidget: (args) => const DetailScreen()),
    RouteInfo(
        name: "/number-page",
        routeWidget: (args) {
          var number = int.tryParse(args?.getValueForKey("number") ?? "0") ?? 0;
          return NumberScreen(number: number);
        }),
    TypedRouteInfo(
        name: "/details",
        type: DetailsScreen,
        routeWidget: (args) {
          var struct = SimpleStruct.fromJson(args?["struct"] ?? "");

          return DetailsScreen(
            struct: struct,
          );
        }),
  ],
  initialRouteInfo: InitialRouteInfo(initialRouteName: "/"),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: routeManager.informationParser,
      routerDelegate: routeManager.routerDelegate,
    );
  }
}
