import 'package:flutter/material.dart';
import 'package:podo_words/learning/learning_quiz1.dart';
import 'package:podo_words/learning/learning_quiz2.dart';
import 'package:podo_words/common/word.dart';

class LearningQuizFrame extends StatefulWidget {
  List<Word> words;
  int wordsNoForQuiz;
  LearningQuizFrame(this.wordsNoForQuiz, this.words);

  @override
  LearningQuizFrameState createState() => LearningQuizFrameState();
}

class LearningQuizFrameState extends State<LearningQuizFrame> {
  late List<Word> words;
  late List<Widget> quizList;
  late int quizNo;


  @override
  void initState() {
    super.initState();
    words = widget.words;
    quizList = [LearningQuiz1(widget.wordsNoForQuiz, words), LearningQuiz2(words)];
    quizNo = 0;
  }

  @override
  Widget build(BuildContext context) {
    return quizList[quizNo];
  }
}
