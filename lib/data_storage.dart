import 'package:shared_preferences/shared_preferences.dart';

class DataStorage {

  // key
  // 비활성 단어 저장 : 'inActiveWords'
  // 영어 번역 스위치 : 'isEngOn'

  SharedPreferences sp;


  setStringList(String key, List<String> list) async {
    sp = await SharedPreferences.getInstance();
    sp.setStringList(key, list);
  }

  Future<List<String>> getStringList(String key) async {
    sp = await SharedPreferences.getInstance();
    List<String> stringList = sp.getStringList(key) ?? [];
    return stringList;
  }


  setBool(String key, bool b) async {
    sp = await SharedPreferences.getInstance();
    sp.setBool(key, b);
  }

  Future<bool> getBool(String key) async {
    sp = await SharedPreferences.getInstance();
    bool b = sp.getBool(key) ?? true;
    return b;
  }
}