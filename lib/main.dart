import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/logo.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'podo_words',
      theme: ThemeData(
      ),
      home: new Logo(),
    );
  }
}