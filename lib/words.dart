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

  List<Map<String, String>> words = [];
    /*
    {
      'title' : 'title0',
      'titleImage' : 'titleImage0',
      'front' : 'front0 front1 front2',
      'back' : 'back0 back1 back2',
      'image' : 'image0 image1 image2',
      'pronunciation' : 'pro0 pro1 pro2'
    },
    {
      'title' : 'title0',
      'titleImage' : 'titleImage0',
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
      Map<String, String> title = {TITLE : '$TITLE$i', TITLE_IMAGE : 'https://picsum.photos/300/300?image=${i+50}'};
      words.add(title);

      String testFront = "";
      String testBack = "";
      String testPronunciation = "";
      String testImage = "";

      for(int j=0; j<5; j++) {
        testFront += '$FRONT$i$j ';
        testBack += '$BACK$i$j ';
        testPronunciation += '$PRONUNCIATION$i$j ';
        testImage += 'https://picsum.photos/300/300?image=${j+50} ';
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
      titles.add(words[i][TITLE]);
    }
    return titles;
  }

  List<String> getTitleImages() {
    for(int i=0; i< words.length; i++) {
      titleImages.add(words[i][TITLE_IMAGE]);
    }
    return titleImages;
  }



  Words getWords(int index) {
    this.front = words[index][FRONT].split(" ");
    this.back = words[index][BACK].split(" ");
    this.image = words[index][IMAGE].split(" ");
    this.pronunciation = words[index][PRONUNCIATION].split(" ");
    this.title = words[index][TITLE];
    this.titleImage = words[index][TITLE_IMAGE];
    this.front.removeAt(front.length-1);
    this.back.removeAt(back.length-1);
    this.image.removeAt(image.length-1);
    this.pronunciation.removeAt(pronunciation.length-1);
    return this;
  }
}