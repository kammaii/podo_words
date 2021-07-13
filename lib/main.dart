import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/logo.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:podo_words/purchase.dart';


void main() {
  if(defaultTargetPlatform == TargetPlatform.android) {
    InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
      _instance ??= InAppPurchase.instance;
    } on Exception catch (error) {
      Get.snackbar('InAppPurchase instance error', '$error');
    }
    return _instance!;
  }
}

