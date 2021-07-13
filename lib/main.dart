import 'package:flutter/material.dart';
import 'package:podo_words/logo.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:podo_words/purchase.dart';


void main() {
  InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    Purchase();

    return MaterialApp(
      title: 'podo_words',
      theme: ThemeData(
      ),
      home: new Logo(),
    );
  }
}

class IAPConnection {
  static InAppPurchase? _instance;
  static set instance(InAppPurchase value) {
    _instance = value;
  }

  static InAppPurchase get instance {
    try {
      print('시작');
      _instance ??= InAppPurchase.instance;
    } on Exception catch (error) {
      print('에러 : $error');
    }
    return _instance!;
  }
}

