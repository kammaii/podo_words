import 'package:podo_words/data_storage.dart';

class CheckActiveWords {

  List<String> inActiveWords;
  List<String> frontList;

  CheckActiveWords(this.frontList);

  // 단어 front 리스트를 입력하면 inActive 단어의 인덱스 리스트를 반환
  Future<List<bool>> getBoolList(String key) async {
    inActiveWords = await DataStorage().getStringList(key);
    List<bool> boolList = [];
    for(int i=0; i<frontList.length; i++) {
      if(inActiveWords.contains(frontList[i])) {
        boolList.add(false);
      } else {
        boolList.add(true);
      }
    }
    return boolList;
  }

  void addInActiveWord(String key, String word) {
    if(!inActiveWords.contains(word)) {
      inActiveWords.add(word);
      DataStorage().setStringList(key, inActiveWords);
    } else {
      print('이미 비활성화된 단어입니다.');
    }
  }

  void removeInActiveWord(String key, String word) {
    if(inActiveWords.contains(word)) {
      inActiveWords.remove(word);
      DataStorage().setStringList(key, inActiveWords);
    } else {
      print('이미 제거된 단어입니다.');
    }
  }
}