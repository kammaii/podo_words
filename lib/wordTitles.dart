
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WordTitles {

  List<String> title = []; //todo: title 과 titleImage 넣기
  List<String> titleImage = [];

  WordTitles() {
    setTitle(); //todo: 삭제하기
  }

  void setTitle() {
    for(int i=0; i<20; i++) {
      title.add('title$i');
      titleImage.add('https://picsum.photos/300/300?image=$i');
    }
  }

  List<String> getTitle() {
    return title;
  }

  List<String> getTitleImage() {
    return titleImage;
  }
}