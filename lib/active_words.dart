import 'package:podo_words/data_storage.dart';
import 'package:podo_words/words.dart';

class ActiveWords {

  List<String> inActiveWords;
  //List<String> testInActiveWords = ['front01', 'front02'];
  static const String IN_ACTIVE_WORDS = 'inActiveWords';

  ActiveWords() {
    setActiveWords();
  }

  setActiveWords() async {
    inActiveWords = await DataStorage().getStringList(IN_ACTIVE_WORDS);
    print('isActiveWOrds: $inActiveWords' );
  }

  // 단어 front 리스트를 입력하면 inActive 단어의 인덱스 리스트를 반환
  List<bool> getWordsActiveList(List<String> front) {
    List<bool> boolList = [];
    for(int i=0; i<front.length; i++) {
      if(inActiveWords != null && inActiveWords.contains(front[i])) {
        boolList.add(false);
      } else {
        boolList.add(true);
      }
    }
    return boolList;
  }

  void addInActiveWord(String word) {
    //todo: 앱 DB에 단어 추가하기
    //testInActiveWords.add(word);
    inActiveWords.add(word);
    DataStorage().setStringList(IN_ACTIVE_WORDS, inActiveWords);
  }

  void removeInActiveWord(String word) {
    inActiveWords.remove(word);
    DataStorage().setStringList(IN_ACTIVE_WORDS, inActiveWords);
  }
}