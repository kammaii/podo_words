import 'package:flutter/material.dart';
import 'package:podo_words/main_learning.dart';
import 'package:podo_words/main_learning_Sliver.dart';
import 'package:podo_words/main_learning_xx.dart';
import 'package:podo_words/main_review.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'podo_words',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: new MainLearning(),
    );
  }
}


