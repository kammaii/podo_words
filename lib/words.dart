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
/*
//
{
  'title' : [''],
  'titleIcon' : ['.png'],
  'front' : [''],
  'back' : [''],
  'pronunciation' : ['-','[]']
}
 */


  List<Map<String, List<String>>> words = [
// 1
    {
      'title' : ['음식'],
      'titleIcon' : ['1.png'],
      'front' : ['밥','국','반찬','고기','김치','만두','김','두부','생선','해산물','면','빵','떡볶이','김밥','비빔밥','냉면','햄버거','피자','한식','양식','중식','일식'],
      'back' : ['rice/meal','soup','side dish','meat','Kimchi','dumplings','Laver','tofu','fish','seafood','noodles','bread','Tteok-bokki','Gimbap','Bibimbap','Cold Buchwheat Noodles','hamburger','pizza','Korean food','Western food','Chinese food','Japanese food'],
      'pronunciation' : ['-','-','-','-','-','-','-','-','-','-','-','-','[떡보끼]','[김빱]','[비빔빱]','-','-','-','-','-','-','-']
    },
// 2
    {
      'title' : ['디저트'],
      'titleIcon' : ['2.png'],
      'front' : ['과일','음료','초콜릿','케이크','팥빙수','얼음','아이스크림','떡','사탕','과자'],
      'back' : ['fruit','beverage','chocolate','cake','Patbingsu','ice','ice cream','Theok','candy','snacks'],
      'pronunciation' : ['-','[음뇨]','-','-','[팓삥수]','[어름]','-','-','-','-']
    },
// 3
    {
      'title' : ['과일'],
      'titleIcon' : ['3.png'],
      'front' : ['사과','딸기','포도','수박','바나나','배','귤','오렌지','블루베리','복숭아'],
      'back' : ['apple','strawberry','grape','watermelon','banana','pear','tangerine','orange','blueberry','peach'],
      'pronunciation' : ['-','-','-','-','-','-','-','-','-','[복쑹아]']
    },
// 4
    {
      'title' : ['야채'],
      'titleIcon' : ['4.png'],
      'front' : ['당근','감자','고구마','양파','오이','버섯','호박','무','고추','마늘','토마토','옥수수','콩','파','상추','콩나물','양배추','시금치'],
      'back' : ['carrot','potato','sweet potato','onion','cucumber','mushroom','pumpkin','radish','chili','garlic','tomato','corn','bean','green onion','lettuce','bean sprouts','cabbage','spinach'],
      'pronunciation' : ['-','-','-','-','-','-','-','-','-','-','-','[옥쑤수]','-','-','-','-','-','-']
    }

  ];


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