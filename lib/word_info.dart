import 'package:podo_words/words.dart';

class WordInfo {

  String front;
  String back;
  String image;
  String pronunciation;
  //String audio;

  WordInfo (Words words, int index) {
    this.front = words.front[index];
    this.back = words.back[index];
    this.image = words.image[index];
    this.pronunciation = words.pronunciation[index];
  }
}