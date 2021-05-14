import 'dart:core';

import 'package:podo_words/data_storage.dart';
import 'package:podo_words/word.dart';

class Words{

  static final Words _instance = Words.init();

  factory Words() {
    return _instance;
  }

  static const TITLE = 'title';
  static const TITLE_IMAGE = 'titleImage';
  static const FRONT = 'front';
  static const BACK = 'back';
  static const IMAGE = 'image';
  static const PRONUNCIATION = 'pronunciation';

  Words.init() {
    print('Words 초기화');
    setWords();
  }

  List<Map<String, List<String>>> words = [];
    /*
    {
      'title' : 'title0',
      'titleIcon' : 'titleImage0',
      'front' : 'front0 front1 front2',
      'back' : 'back0 back1 back2',
      'image' : 'image0 image1 image2',
      'pronunciation' : 'pro0 pro1 pro2'
    },
    {
      'title' : 'title0',
      'titleIcon' : 'titleImage0',
      'front' : 'front0 front1 front2',
      'back' : 'back0 back1 back2',
      'image' : 'image0 image1 image2',
      'pronunciation' : 'pro0 pro1 pro2'
    },
  ];

     */

  // todo: 테스트용임. 삭제할 것
  void setWords() {
    for(int i=0; i<20; i++) {
      List<String> title = ['$TITLE$i'];
      List<String> titleImage = ['https://picsum.photos/300/300?image=${i+50}'];
      Map<String, List<String>> titleInfo = {TITLE : title, TITLE_IMAGE : titleImage};
      words.add(titleInfo);

      List<String> testFront = [];
      List<String> testBack = [];
      List<String> testPronunciation = [];
      List<String> testImage = [];

      for(int j=0; j<10; j++) {
        testFront.add('$FRONT$i$j');
        testBack.add('$BACK$i$j');
        testPronunciation.add('$PRONUNCIATION$i$j');
        testImage.add('https://picsum.photos/300/300?image=${j+50}');
      }
      words[i][FRONT] = testFront;
      words[i][BACK] = testBack;
      words[i][PRONUNCIATION] = testPronunciation;
      words[i][IMAGE] = testImage;
    }
  }


  List<String> getTitles() {
    List<String> titles = [];
    for(int i=0; i< words.length; i++) {
      titles.add(words[i][TITLE][0]);
    }
    return titles;
  }


  List<String> getTitleImages() {
    List<String> titleImages = [];
    for(int i=0; i< words.length; i++) {
      titleImages.add(words[i][TITLE_IMAGE][0]);
    }
    return titleImages;
  }


  List<Word> getWords(int index) {
    Map<String, List<String>> wordsMap = words[index];
    List<Word> wordList = [];
    for(int i=0; i<wordsMap[FRONT].length; i++) {
      Word word = Word(wordsMap[FRONT][i], wordsMap[BACK][i], wordsMap[IMAGE][i]);
      if(DataStorage().inActiveWords.contains(word.front)) {
        word.isActive = false;
      } else {
        word.isActive = true;
      }
      wordList.add(word);
    }
    return wordList;
  }
}