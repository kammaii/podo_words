import 'dart:core';

class Words {

  String title;
  String titleImage;
  List<String> front;
  List<String> back;
  List<String> image;
  List<String> pronunciation;

  static const TITLE = 'title';
  static const TITLE_IMAGE = 'titleImage';
  static const FRONT = 'front';
  static const BACK = 'back';
  static const IMAGE = 'image';
  static const PRONUNCIATION = 'pronunciation';

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
  Words() {
    setWords();
  }

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

  List<String> titles = [];
  List<String> titleImages = [];

  List<String> getTitles() {
    for(int i=0; i< words.length; i++) {
      titles.add(words[i][TITLE][0]);
    }
    return titles;
  }

  List<String> getTitleImages() {
    for(int i=0; i< words.length; i++) {
      titleImages.add(words[i][TITLE_IMAGE][0]);
    }
    return titleImages;
  }



  Words getWords(int index) {
    this.front = words[index][FRONT];
    this.back = words[index][BACK];
    this.image = words[index][IMAGE];
    this.pronunciation = words[index][PRONUNCIATION];
    this.title = words[index][TITLE][0];
    this.titleImage = words[index][TITLE_IMAGE][0];
    return this;
  }
}