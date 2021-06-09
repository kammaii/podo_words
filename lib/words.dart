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
  static const PRONUNCIATION = 'pronunciation';

  Words.init() {
    print('Words 초기화');
    //setWords();
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
// 0
    {
      'title' : ['음식'],
      'titleIcon' : ['0.png'],
      'front' : ['밥','국','반찬','고기','김치','만두','김','두부','생선','해산물','면','빵','떡볶이','김밥','비빔밥','냉면','햄버거','피자','한식','양식','중식','일식'],
      'back' : ['rice/meal','soup','side dish','meat','Kimchi','dumplings','Laver','tofu','fish','seafood','noodles','bread','Tteok-bokki','Gimbap','Bibimbap','Cold Buchwheat Noodles','hamburger','pizza','Korean food','Western food','Chinese food','Japanese food'],
      'pronunciation' : ['-','-','-','-','-','-','-','-','-','-','-','-','[떡보끼]','[김빱]','[비빔빱]','-','-','-','-','-','-','-']
    },
// 1
    {
      'title' : ['디저트'],
      'titleIcon' : ['1.png'],
      'front' : ['과일','음료','초콜릿','케이크','팥빙수','얼음','아이스크림','떡','사탕','과자'],
      'back' : ['fruit','beverage','chocolate','cake','Patbingsu','ice','ice cream','Theok','candy','snacks'],
      'pronunciation' : ['-','[음뇨]','-','-','[팓삥수]','[어름]','-','-','-','-']
    },
// 2
    {
      'title' : ['과일'],
      'titleIcon' : ['2.png'],
      'front' : ['사과','딸기','포도','수박','바나나','배','귤','오렌지','블루베리','복숭아'],
      'back' : ['apple','strawberry','grape','watermelon','banana','pear','tangerine','orange','blueberry','peach'],
      'pronunciation' : ['-','-','-','-','-','-','-','-','-','[복쑹아]']
    },
// 3
    {
      'title' : ['야채'],
      'titleIcon' : ['3.png'],
      'front' : ['당근','감자','고구마','양파','오이','버섯','호박','무','고추','마늘','토마토','옥수수','콩','파','상추','콩나물','양배추','시금치'],
      'back' : ['carrot','potato','sweet potato','onion','cucumber','mushroom','pumpkin','radish','chili','garlic','tomato','corn','bean','green onion','lettuce','bean sprouts','cabbage','spinach'],
      'pronunciation' : ['-','-','-','-','-','-','-','-','-','-','-','[옥쑤수]','-','-','-','-','-','-']
    },
// 4
    {
      'title' : ['조미료'],
      'titleIcon' : ['4.png'],
      'front' : ['설탕','소금','간장','식초','후추','식용유','고추장','고춧가루','된장','향신료','꿀'],
      'back' : ['sugar','salt','soy sauce','vinegar','pepper','cooking oil','red pepper paste','red pepper powder','soybean paste','spice','honey'],
      'pronunciation' : ['-','-','-','-','-','[시굥뉴]','-','-','-','[향신뇨]','-']
    },
// 5
    {
      'title' : ['요리'],
      'titleIcon' : ['5.png'],
      'front' : ['굽다','끓이다','볶다','튀기다','찌다','자르다','넣다','빼다','섞다','뿌리다','맛을 보다'],
      'back' : ['roast','boil','stir-fry','fry','steam','cut','put in','take out','mix','spray','taste'],
      'pronunciation' : ['[굽따]','[끄리다]','[복따]','-','-','-','[너타]','-','[석따]','-','[마슬보다]']
    },
// 6
    {
      'title' : ['맛'],
      'titleIcon' : ['6.png'],
      'front' : ['맛있다','맛없다','달다','쓰다','맵다','짜다','싱겁다','시다','신선하다','상하다','익다','썩다'],
      'back' : ['delicious','not delicious','sweet','bitter','spicy','salty','bland','sour','fresh','go bad','ripen','decay'],
      'pronunciation' : ['[마시따]','[마덥따]','-','-','[맵따]','-','-','-','-','-','[익따]','[썩따]']
    },
// 7
    {
      'title' : ['마실 것'],
      'titleIcon' : ['7.png'],
      'front' : ['물','커피','우유','주스','콜라','차','술','맥주','소주','막걸리','와인'],
      'back' : ['water','coffee','milk','juice','Coke','tea','alcohol','beer','Soju','Makgeolli','wine'],
      'pronunciation' : ['-','-','-','[주쓰]','-','-','-','[맥쭈]','-','[막껄리]','-']
    },
// 8
    {
      'title' : ['집안 공간'],
      'titleIcon' : ['8.png'],
      'front' : ['방','옷방','거실','주방','화장실','창고','계단','지하실','옥상','벽','천장'],
      'back' : ['room','dressing room','living room','kitchen','bathroom','warehouse','stairs','basement','roof','wall','ceiling'],
      'pronunciation' : ['-','[옫빵]','-','-','-','-','-','-','[옥쌍]','-','-']
    },
// 9
    {
      'title' : ['집안 물건'],
      'titleIcon' : ['9.png'],
      'front' : ['책상','의자','침대','이불','베개','옷장','옷걸이','소파','식탁','신발장','창문','문','불','쓰레기통','달력','나무','꽃'],
      'back' : ['desk','chair','bed','blanket','pillow','closet','hanger','sofa','table','shoe rack','window','door','light','trash can','calendar','tree','flower'],
      'pronunciation' : ['[책쌍]','-','-','-','-','[옫짱]','[옫꺼리]','-','-','[신발짱]','-','-','-','-','-','-','[꼳]']
    },
// 10
    {
      'title' : ['전자제품'],
      'titleIcon' : ['10.png'],
      'front' : ['휴대폰','컴퓨터','노트북','텔레비전','냉장고','세탁기','청소기','선풍기','에어컨','전자레인지','다리미','전기','충전'],
      'back' : ['cell phone','computer','laptop','television','refrigerator','washing machine','vacuum cleaner','electric fan','air conditioner','microwave','iron','electricity','charging'],
      'pronunciation' : ['-','-','-','-','-','-','-','-','-','-','-','-','-']
    },
// 11
    {
      'title' : ['소지품'],
      'titleIcon' : ['11.png'],
      'front' : ['지갑','열쇠','가방','짐','신분증','여권','화장품','향수','우산','책','선물','표'],
      'back' : ['wallet','key','bag','luggage','ID card','passport','cosmetics','perfume','umbrella','book','present','ticket'],
      'pronunciation' : ['-','[열쐬]','-','-','[신분쯩]','[여꿘]','-','-','-','-','-','-']
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
    }
  }


  List<String> getTitles() {
    List<String> titles = [];
    for(int i=0; i< words.length; i++) {
      titles.add(words[i][TITLE]![0]);
    }
    return titles;
  }


  List<String> getTitleImages() {
    List<String> titleImages = [];
    for(int i=0; i< words.length; i++) {
      titleImages.add(words[i][TITLE_IMAGE]![0]);
    }
    return titleImages;
  }


  List<Word> getWords(int index) {
    Map<String, List<String>> wordsMap = words[index];
    List<Word> wordList = [];
    for(int i=0; i<wordsMap[FRONT]!.length; i++) {
      Word word = Word(wordsMap[FRONT]![i], wordsMap[BACK]![i], wordsMap[PRONUNCIATION]![i]);
      if(DataStorage().inActiveWords.contains(word.front)) {
        word.isActive = false;
      } else {
        word.isActive = true;
      }
      wordList.add(word);
    }
    return wordList;
  }

  int getTotalWordsLength() {
    int totalLength = 0;
    for(int i=0; i<words.length; i++) {
      totalLength += words[i][FRONT]!.length;
    }
    return totalLength;
  }
}