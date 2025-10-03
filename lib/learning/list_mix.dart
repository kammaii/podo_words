import 'dart:math';

class ListMix {

  List<dynamic> getMixedList(List<dynamic> list) {
    for(int i=0; i<list.length; i++) {
      int rand = Random().nextInt(list.length);
      dynamic temp = list[i];
      list[i] = list[rand];
      list[rand] = temp;
    }
    return list;
  }
}