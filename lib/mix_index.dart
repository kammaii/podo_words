import 'dart:math';

class MixIndex {

  List<int> getMixedIndex(int length) {
    List<int> list = List<int>.generate(length, (index) => index);
    for(int i=0; i<list.length; i++) {
      int rand = Random().nextInt(list.length);
      int temp = list[i];
      list[i] = list[rand];
      list[rand] = temp;
    }
    return list;
  }
}