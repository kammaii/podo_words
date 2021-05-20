import 'package:flutter/material.dart';
import 'package:podo_words/main_learning.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'podo_words',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple
      ),
      home: new MainLearning(),
    );
  }
}


