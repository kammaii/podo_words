import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/common/play_audio.dart';
import 'package:podo_words/common/word.dart';
import 'package:podo_words/learning/learning_complete.dart';
import 'package:podo_words/learning/learning_quiz1.dart';
import 'package:podo_words/learning/word_card.dart';

class LearningController extends GetxController {
  late List<Word> words;
  List<Word> quizBuffer = [];
  RxInt wordIndex = 0.obs;
  RxBool isQuizOn = true.obs;
  bool isRightSwipe = false;
  List<Widget> content = [];
  bool isLastWord = false;

  void initController(List<Word> wordList) {
    words = wordList;
    quizBuffer = [];
    content = [];
    content.add(WordCard());
    isLastWord = false;
    PlayAudio().playWord(getThisWord().audio);
  }

  List<Word> getQuizWords() {
    List<Word> words = [];
    for (Word word in quizBuffer) {
      if (word.shouldQUiz!) {
        words.add(word);
      }
    }
    return words;
  }

  void setQuizComplete() {
    for (Word word in quizBuffer) {
      word.shouldQUiz = false;
    }
  }

  void swipeWordCard({required bool isNext}) {
    print('여기');
    
    if (isNext) {
      Word word = getThisWord();
      if (!quizBuffer.contains(word)) {
        print('${word.front} is add to quizButter');
        word.shouldQUiz = true;
        quizBuffer.add(word);
      }
      wordIndex++;
      isRightSwipe = true;
    } else {
      wordIndex--;
      isRightSwipe = false;
    }

    isLastWord = wordIndex >= words.length;
    
    int shouldQuizWords = 0;
    for (Word word in quizBuffer) {
      if (word.shouldQUiz!) {
        shouldQuizWords++;
      }
    }
    final shouldRunQuiz = shouldQuizWords != 0 && shouldQuizWords % 4 == 0;

    if (isQuizOn.value) {
      if (shouldRunQuiz || isLastWord) {
        content.add(LearningQuiz1());
        update();
      } else {
        PlayAudio().playWord(getThisWord().audio);
      }
    } else {
      if (isLastWord) {
        Get.to(LearningComplete());
        update();
      } else {
        PlayAudio().playWord(getThisWord().audio);
      }
    }
  }

  void setQuizToggle() {
    isQuizOn.toggle();
    if (!isQuizOn.value && content.length >= 2) {
      content.removeLast();
      if (isLastWord) {
        Get.to(LearningComplete());
      }
      update();
    }
  }

  Word getThisWord() {
    if(isLastWord) {
      return Word('', '', '', '', 'transparent.png');
    } else {
      return words[wordIndex.value];
    }
  }
}
