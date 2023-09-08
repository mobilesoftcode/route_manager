import 'package:flutter/material.dart';
import 'package:route_manager/route_manager.dart';

class NumberScreen extends StatelessWidget {
  final int? number;

  const NumberScreen({super.key, this.number});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Number Page'),
      ),
      body: Center(
        child: Text(
          number.toString(),
          style: const TextStyle(fontSize: 60),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                RouteManager.of(context).pop();
              },
              child: const Text('Back to previous page'),
            ),
            TextButton(
              onPressed: () {
                RouteManager.of(context).popAll();
              },
              child: const Text('Back to home screen'),
            ),
          ],
        ),
      ),
    );
  }
}
