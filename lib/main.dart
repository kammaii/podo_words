import 'package:flutter/material.dart';
import 'package:podo_words/logo.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'podo_words',
      theme: ThemeData(
      ),
      home: new Logo(),
    );
  }
}


