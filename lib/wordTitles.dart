
// todo: words.dart 와 통합하기

import 'package:podo_words/SamplePictures.dart';

class WordTitles {

  List<String> title = []; //todo: title 과 titleImage 넣기
  List<String> titleImage = [];

  WordTitles() {
    setTitle(); //todo: 삭제하기
  }

  void setTitle() {
    for(int i=0; i<20; i++) {
      title.add('title$i');
      titleImage = SamplePictures(20).getSamplePictures();
    }
  }

  List<String> getTitle() {
    return title;
  }

  List<String> getTitleImage() {
    return titleImage;
  }
}