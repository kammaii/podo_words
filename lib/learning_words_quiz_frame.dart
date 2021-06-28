import 'package:flutter/material.dart';
import 'package:podo_words/learning_words_quiz1.dart';
import 'package:podo_words/learning_words_quiz2.dart';
import 'package:podo_words/word.dart';

class LearningWordsQuizFrame extends StatefulWidget {
  List<Word> words;
  int wordsNoForQuiz;
  LearningWordsQuizFrame(this.wordsNoForQuiz, this.words);

  @override
  LearningWordsQuizFrameState createState() => LearningWordsQuizFrameState();
}

class LearningWordsQuizFrameState extends State<LearningWordsQuizFrame> {
  late List<Word> words;
  late List<Widget> quizList;
  late int quizNo;


  @override
  void initState() {
    super.initState();
    words = widget.words;
    quizList = [LearningWordsQuiz1(widget.wordsNoForQuiz, words), LearningWordsQuiz2(words)];
    quizNo = 0;
  }

  @override
  Widget build(BuildContext context) {
    return quizList[quizNo];
  }
}
