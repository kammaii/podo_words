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
      builder: (context, widget) => ResponsiveWrapper.builder(
        BouncingScrollWrapper.builder(context, widget!),
        maxWidth: 1200,
        minWidth: 450,
        defaultScale: true,
        breakpoints: [
          ResponsiveBreakpoint.autoScale(780),
        ],
        background: Container(color: Color(0xFFF5F5F5))
      ),
    );
  }
}