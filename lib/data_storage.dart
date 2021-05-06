import 'package:shared_preferences/shared_preferences.dart';

class DataStorage {

  static final DataStorage _instance = DataStorage().getData(); // 질문! 이거는 언제 실행되나?

  factory DataStorage() {
    return _instance;
  }



  // key
  // 비활성 단어 저장 : 'inActiveWords'
  // 영어 번역 스위치 : 'isEngOn'

  SharedPreferences sp;
  List<String> inActiveWords;
  List<String> myWords;

  static const String KEY_IN_ACTIVE_WORDS = 'inActiveWords';
  static const String KEY_MY_WORDS = 'myWords';


  getData() async {
    sp = await SharedPreferences.getInstance();
    inActiveWords = await getStringList(KEY_IN_ACTIVE_WORDS);
    myWords = await getStringList(KEY_MY_WORDS);
  }

  // 단어 front 리스트를 입력하면 inActive 단어의 인덱스 리스트를 반환
  List<bool> getBoolList(List<String> frontList) {
    return setBoolList(frontList);
  }

  List<bool> getMyBoolList() {
    return setBoolList(myWords);
  }

  List<bool> setBoolList(List<String> list) {
    List<bool> boolList = [];
    for(int i=0; i<list.length; i++) {
      if(inActiveWords.contains(list[i])) {
        boolList.add(false);
      } else {
        boolList.add(true);
      }
    }
    return boolList;
  }


  // todo : 수정하기
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

  setStringList(String key, List<String> list) async {
    sp.setStringList(key, list);
  }

  Future<List<String>> getStringList(String key) async {
    List<String> stringList = sp.getStringList(key) ?? [];
    return stringList;
  }

  setBool(String key, bool b) async {
    sp.setBool(key, b);
  }

  Future<bool> getBool(String key) async {
    bool b = sp.getBool(key) ?? true;
    return b;
  }
}
