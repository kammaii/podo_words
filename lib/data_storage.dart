import 'package:shared_preferences/shared_preferences.dart';

class DataStorage {

  // key
  // 비활성 단어 저장 : 'inActiveWords'

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
}