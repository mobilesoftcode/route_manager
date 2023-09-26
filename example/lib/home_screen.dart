import 'package:flutter/material.dart';
import 'package:route_manager/route_manager.dart';
import 'package:route_manager_example/details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
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
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  RouteManager.of(context).pushNamed(
                    "/detail",
                  );
                },
                child: const Text("Named push")),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  RouteManager.of(context).push(
                    DetailsScreen(
                      struct: SimpleStruct(
                        title: "Hello World",
                      ),
                    ),
                    maskArguments: true,
                  );
                },
                child: const Text("Widget push")),
          ],
        ),
      ),
    );
  }
}
