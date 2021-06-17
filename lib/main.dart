import 'package:flutter/material.dart';
import 'package:podo_words/main_learning.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:provider/provider.dart';

void main() {
  InAppPurchaseAndroidPlatformAddition.enablePendingPurchases();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    ChangeNotifierProvider<DashPurchases>(
      create: (context) => DashPurchases(
        context.read<DashCounter>(),
      ),
      lazy: false,
    ),

    return MaterialApp(
      title: 'podo_words',
      theme: ThemeData(
      ),
      home: new MainLearning(),
    );
  }
}


