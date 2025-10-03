import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:podo_words/learning/models/word_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {

  static final LocalStorageService _instance = LocalStorageService.init();

  factory LocalStorageService() {
    return _instance;
  }

  SharedPreferences? sp;
  int lastClickedItem = 0;

  static const String KEY_LAST_CLICKED_ITEM = 'lastClickedItem';
  static const String KEY_MY_WORDS_MIGRATED = 'myWordsMigrated';


  LocalStorageService.init() {
    print('DataStorage 초기화');
  }

  Future<void> initLocalData() async {
    sp ??= await SharedPreferences.getInstance();
    lastClickedItem = getInt(KEY_LAST_CLICKED_ITEM);
  }

  Future<bool> importDataForMigration(String jsonString) async {
    if (sp == null) await initLocalData(); // SharedPreferences 인스턴스 보장

    try {
      final backupJson = json.decode(jsonString);
      final List<String> myWordsJson = List<String>.from(backupJson['myWords'] ?? []);
      final List<String> inactiveWords = List<String>.from(backupJson['inactiveWords'] ?? []);

      // SharedPreferences에 이전 데이터 복원
      await sp!.setStringList('myWords', myWordsJson);
      await sp!.setStringList('inActiveWords', inactiveWords);

      return true;
    } catch (e) {
      debugPrint("Import Error: $e");
      return false;
    }
  }

  void setMyWordsMigrated() {
    setBool(KEY_MY_WORDS_MIGRATED, true);
  }


  void setLastClickedItem(int i) {
    LocalStorageService().setInt(KEY_LAST_CLICKED_ITEM, i);
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
