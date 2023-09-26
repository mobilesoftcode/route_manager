import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:route_manager/route_manager.dart';

class DetailsScreen extends StatelessWidget implements TypedRoute {
  final SimpleStruct struct;
  const DetailsScreen({
    super.key,
    required this.struct,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail")),
      body: Center(
        child: Text(struct.title),
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

  @override
  Map<String, dynamic> toMap() {
    return {"struct": struct.toJson()};
  }
}

class SimpleStruct {
  String title;
  SimpleStruct({
    required this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
    };
  }

  factory SimpleStruct.fromMap(Map<String, dynamic> map) {
    return SimpleStruct(
      title: map['title'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory SimpleStruct.fromJson(String source) =>
      SimpleStruct.fromMap(json.decode(source));
}
