import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podo_words/learning/controllers/audio_controller.dart';
import 'package:podo_words/learning/controllers/image_controller.dart';
import 'package:podo_words/learning/models/word_model.dart';
import 'package:podo_words/learning/pages/learning_complete_page.dart';
import 'package:podo_words/learning/widgets/learning_quiz1.dart';
import 'package:podo_words/learning/widgets/word_card.dart';

enum LearningMode { learnNew, review }

class LearningController extends GetxController {
  late List<Word> words;
  List<Word> quizBuffer = [];
  RxInt wordIndex = 0.obs;
  RxBool isQuizOn = true.obs;
  bool isRightSwipe = false;
  List<Widget> content = [];
  bool isLastWord = false;
  final ImageController imageService = ImageController();
  final AudioController audioController = AudioController();
  LearningMode learningMode = LearningMode.learnNew;


  Future<void> initController(List<Word> wordList) async {
    words = wordList;
    quizBuffer = [];
    content = [];
    content.add(WordCard());
    isLastWord = false;
    learningMode = LearningMode.learnNew;
    await Future.wait([
      audioController.cacheAllAudioFiles(words),
      imageService.cacheImageFiles(words),
    ]);
    audioController.playWordAudio(currentWord);
  }



  List<Word> getQuizWords() {
    List<Word> words = [];
    for (Word word in quizBuffer) {
      if (word.shouldQuiz!) {
        words.add(word);
      }
    }
    return words;
  }

  void setQuizComplete() {
    for (Word word in quizBuffer) {
      word.shouldQuiz = false;
    }
  }

  void swipeWordCard({required bool isNext}) {
    if (isNext) {
      if (wordIndex.value < words.length) {
        Word word = currentWord;
        if (!quizBuffer.contains(word)) {
          print('${word.front} is add to quizButter');
          word.shouldQuiz = true;
          quizBuffer.add(word);
        }
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
      if (word.shouldQuiz!) {
        shouldQuizWords++;
      }
    }
    final shouldRunQuiz = shouldQuizWords != 0 && shouldQuizWords % 4 == 0;

    if (isLastWord) {
      if (isQuizOn.value && shouldQuizWords > 0) {
        content.add(LearningQuiz1());
        update();
      } else {
        Get.to(() => const LearningCompletePage());
        update();
      }
    } else { // 아직 마지막 단어가 아닐 때
      if (isQuizOn.value && shouldRunQuiz) {
        content.add(LearningQuiz1());
        update();
      } else {
        audioController.playWordAudio(currentWord);
      }
    }
  }

  void setQuizToggle() {
    isQuizOn.toggle();
    if (!isQuizOn.value && content.length >= 2) {
      content.removeLast();
      if (isLastWord) {
        Get.to(LearningCompletePage());
      }
      update();
    }
  }

  Word get currentWord {
    print('월드인덱스: ${wordIndex.value}');
    return words[wordIndex.value];
  }
}
