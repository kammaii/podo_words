import 'dart:convert';
import 'package:podo_words/word.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataStorage {

  static final DataStorage _instance = DataStorage.init();

  factory DataStorage() {
    return _instance;
  }

  // key
  // 비활성 단어 저장 : 'inActiveWords'
  // 영어 번역 스위치 : 'isEngOn'

  SharedPreferences sp;
  List<String> inActiveWords;
  List<Word> myWords;

  static const String KEY_IN_ACTIVE_WORDS = 'inActiveWords';
  static const String KEY_MY_WORDS = 'myWords';

  DataStorage.init() {
    print('DataStorage 초기화');
  }

  Future<SharedPreferences> initData() {
    Future<SharedPreferences> f = SharedPreferences.getInstance();
    f.then((value) {
      sp = value;
      inActiveWords = getStringList(KEY_IN_ACTIVE_WORDS);
      List<String> myWordsJson = getStringList(KEY_MY_WORDS);
      print(myWordsJson);

      myWords = [];
      for(int i=0; i<myWordsJson.length; i++) {
        Word myWord = Word.fromJson(json.decode(myWordsJson[i]));
        myWords.add(myWord);
      }
      setIsActiveMyWords();
    });

    return f;
  }

  Future<bool> wait() {
    return Future.delayed(const Duration(seconds: 0), () { //todo: 3초로 수정하기
      return true;
    });
  }

  Future<List<Object>> init() {
    return Future.wait([wait(), initData()]);
  }

  void setIsActiveMyWords() {
    for(Word myWord in myWords) {
      if(inActiveWords.contains(myWord.front)) {
        myWord.isActive = false;
      } else {
        myWord.isActive = true;
      }
    }
  }

  void removeMyWords() {
    List<int> selectedId = [];
    for(Word myWord in myWords) {
      if(myWord.isChecked) {
        selectedId.add(myWord.wordId);
      }
    }
    for(int id in selectedId) {
      myWords.removeAt(id);
    }
    setMyWords();
  }

  void addMyWords(List<Word> wordList) {
    List<Word> newWords = [];
    for(Word word in wordList) {
      String front = word.front;
      bool isNew = true;
      for(Word myWord in myWords) {
        if(front == myWord.front) {
          isNew = false;
        }
      }
      if(isNew) {
        newWords.add(word);
      }
    }
    for(Word newWord in newWords ) {
      myWords.add(newWord);
    }
    setMyWords();
  }

  void setMyWords() {
    List<String> myWordsJson = [];
    for(Word word in myWords) {
      myWordsJson.add(json.encode(word.toJson()));
    }
    DataStorage().setStringList(KEY_MY_WORDS, myWordsJson);
  }

  void addInActiveWord(String word) {
    if(!inActiveWords.contains(word)) {
      inActiveWords.add(word);
      setIsActiveMyWords();
      DataStorage().setStringList(KEY_IN_ACTIVE_WORDS, inActiveWords);
    } else {
      print('이미 비활성화된 단어입니다.');
    }
  }

  void removeInActiveWord(String word) {
    if(inActiveWords.contains(word)) {
      inActiveWords.remove(word);
      setIsActiveMyWords();
      DataStorage().setStringList(KEY_IN_ACTIVE_WORDS, inActiveWords);
    } else {
      print('이미 활성화된 단어입니다.');
    }
  }

  setStringList(String key, List<String> list) async {
    sp.setStringList(key, list);
  }

  List<String> getStringList(String key) {
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
