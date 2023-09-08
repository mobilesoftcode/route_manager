import 'package:flutter/material.dart';
import 'package:route_manager/route_manager.dart';
import 'detail_screen.dart';
import 'home_screen.dart';
import 'number_screen.dart';

final routeManager = RouteManager(
  routesInfo: [
    RouteInfo(name: "/", routeWidget: (args) => const HomeScreen()),
    RouteInfo(name: "/details", routeWidget: (args) => const DetailScreen()),
    RouteInfo(
        name: "/number-page",
        routeWidget: (args) => NumberScreen(number: args?['number'])),
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
