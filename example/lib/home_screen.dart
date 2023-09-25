import 'package:flutter/material.dart';
import 'package:route_manager/route_manager.dart';
import 'package:route_manager_example/detail_screen.dart';
import 'package:route_manager_example/test_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Welcome to an Example of the flutter competence routeManager",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
              onPressed: () {
                RouteManager.of(context).pushClass(TestScreen());
              },
              child: const Text("Test 1")),
          ElevatedButton(
              onPressed: () {
                RouteManager.of(context).pushClass(
                  TestScreen2(
                    struct: SimpleStruct(
                      title: "HOLA",
                    ),
                  ),
                  maskArguments: true,
                );
              },
              child: const Text("Test 2")),
          ElevatedButton(
              onPressed: () {
                RouteManager.of(context).pushClass(TestScreen3(
                  title: "HI",
                ));
              },
              child: const Text("Test 3")),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.arrow_forward),
        onPressed: () {
          // RouteManager.of(context).push(name: "/details");
          RouteManager.of(context).pushClass(TestScreen());
        },
      ),
    );
  }
}
