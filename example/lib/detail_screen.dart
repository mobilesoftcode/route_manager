import 'package:flutter/material.dart';
import 'package:route_manager/route_manager.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Details")),
      body: Column(
        children: [
          Container(
            height: 20,
          ),
          const Center(
              child: Text(
            "We navigated to this page using the RouteManager, now let's navigate passing a value",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          )),
          Container(
            height: 50,
          ),
          NumericKeypad(onPressed: (int value) {
            RouteManager.of(context)
                .pushNamed('/number-page', arguments: {'number': value});
          }),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: TextButton(
          onPressed: () {
            RouteManager.of(context).popAll();
          },
          child: const Text('Back to home screen'),
        ),
      ),
    );
  }
}

class NumericKeypad extends StatelessWidget {
  final Function(int) onPressed;

  const NumericKeypad({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton(1),
            _buildNumberButton(2),
            _buildNumberButton(3),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton(4),
            _buildNumberButton(5),
            _buildNumberButton(6),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton(7),
            _buildNumberButton(8),
            _buildNumberButton(9),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(),
            _buildNumberButton(0),
            const SizedBox(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(int number) {
    return ElevatedButton(
      onPressed: () => onPressed(number),
      child: Text('$number'),
    );
  }
}
