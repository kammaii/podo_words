import 'package:flutter/material.dart';
import 'package:podo_words/learning_words_complete.dart';
import 'package:podo_words/learning_words_quiz1.dart';
import 'package:podo_words/learning_words_quiz2.dart';
import 'package:podo_words/learning_words_quiz3.dart';
import 'package:podo_words/main_learning.dart';
import 'package:podo_words/review_flashcards.dart';


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


