import 'dart:convert';
import 'package:podo_words/common/word.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataStorage {

  static final DataStorage _instance = DataStorage.init();

  factory DataStorage() {
    return _instance;
  }

  // key
  // 비활성 단어 저장 : 'inActiveWords'
  // 영어 번역 스위치 : 'isEngOn'

  SharedPreferences? sp;
  List<String> inActiveWords = [];
  List<Word> myWords = [];
  int lastClickedItem = 0;
  bool isPremiumUser = false;


  static const String KEY_IN_ACTIVE_WORDS = 'inActiveWords';
  static const String KEY_MY_WORDS = 'myWords';
  static const String KEY_LAST_CLICKED_ITEM = 'lastClickedItem';


  DataStorage.init() {
    print('DataStorage 초기화');
  }

  Future<void> initLocalData(bool isPremium) async {
    sp ??= await SharedPreferences.getInstance();
    isPremiumUser = isPremium;
    inActiveWords = getStringList(KEY_IN_ACTIVE_WORDS);
    lastClickedItem = getInt(KEY_LAST_CLICKED_ITEM);
    List<String> myWordsJson = getStringList(KEY_MY_WORDS);

    myWords = [];
    for(int i=0; i<myWordsJson.length; i++) {
      Word myWord = Word.fromJson(json.decode(myWordsJson[i]));
      myWords.add(myWord);
    }
    setIsActiveMyWords();
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
    List<Word> selectedWord = [];
    for(Word myWord in myWords) {
      if(myWord.isChecked) {
        selectedWord.add(myWord);
      }
    }
    for(Word word in selectedWord) {
      myWords.remove(word);
    }
    setMyWords();
  }

  int addMyWords(List<Word> wordList) {
    int countNewWords = 0;
    for(Word word in wordList) {
      String front = word.front;
      bool isNew = true;
      for(Word myWord in myWords) {
        if(front == myWord.front) {
          isNew = false;
        }
      }
      if(isNew) {
        myWords.add(word);
        countNewWords++;
      }
    }
    setMyWords();
    return countNewWords;
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

  void setLastClickedItem(int i) {
    DataStorage().setInt(KEY_LAST_CLICKED_ITEM, i);
  }

  setStringList(String key, List<String> list) async {
    sp!.setStringList(key, list);
  }

  List<String> getStringList(String key) {
    List<String> stringList = sp!.getStringList(key) ?? [];
    return stringList;
  }


  setInt(String key, int int) async {
    sp!.setInt(key, int);
  }

  int getInt(String key) {
    int i = sp!.getInt(key) ?? 0;
    return i;
  }

  setBool(String key, bool b) async {
    sp!.setBool(key, b);
  }

  bool getBool(String key) {
    bool b = sp!.getBool(key) ?? false;
    return b;
  }

}
