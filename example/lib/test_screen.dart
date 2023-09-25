import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:route_manager/route_manager.dart';

class TestScreen extends StatelessWidget implements TypedRoute {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text("CIAO");
  }

  @override
  Map<String, dynamic> toMap() {
    return {};
  }
}

class TestScreen2 extends StatelessWidget implements TypedRoute {
  final SimpleStruct struct;
  const TestScreen2({
    super.key,
    required this.struct,
  });

  @override
  Widget build(BuildContext context) {
    return Text(struct.title);
  }

  @override
  Map<String, dynamic> toMap() {
    return {"struct": struct.toJson()};
  }
}

class TestScreen3 extends StatefulWidget implements TypedRoute {
  final String title;
  const TestScreen3({
    super.key,
    required this.title,
  });

  @override
  State<TestScreen3> createState() => _TestScreen3State();

  @override
  Map<String, dynamic> toMap() {
    return {"title": title};
  }
}

class _TestScreen3State extends State<TestScreen3> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.title);
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
