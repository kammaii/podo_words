
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Words {

  List<String> title = [];
  List<String> titleImage = [];

  Words() {
    setTitle();
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