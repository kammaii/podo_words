


import 'package:podo_words/SamplePictures.dart';

class Words {

  int titleLength = 20; // todo: title.length 로 변경하기
  List<String> title = []; //todo: title 과 titleImage 넣기
  List<String> titleImage = [];

  int index;
  List<String> image;
  List<String> front;
  List<String> back;
  List<String> pronunciation;
  List<String> audio;

  Words(this.index) {
    //setTitle(); //todo: 삭제하기

    if(index != null) {
      switch(index) {
        case 0 :
          front = ['f0_0', 'f0_1', 'f0_2'];
          back = ['b0_0', 'b0_1', "b0_2"];
          pronunciation = ['p0_0', 'p0_1', 'p0_2'];
          image = SamplePictures(3).getSamplePictures();
          break;

        case 1 :
          front = ['f1_0', 'f1_1', 'f1_2'];
          back = ['b1_0', 'b1_1', "b1_2"];
          pronunciation = ['p1_0', 'p1_1', 'p1_2'];
          image = SamplePictures(3).getSamplePictures();
          break;
      }
    }
  }

  void setTitle() {
    for(int i=0; i < titleLength; i++) {
      title.add('title$i');
    }
    titleImage = SamplePictures(titleLength).getSamplePictures();
  }

  List<String> getTitle() {
    return title;
  }

  List<String> getTitleImage() {
    return titleImage;
  }

  List<String> getFront() {
    return front;
  }

  List<String> getBack() {
    return back;
  }

  List<String> getImage() {
    return image;
  }

  List<String> getPronunciation() {
    return pronunciation;
  }
}