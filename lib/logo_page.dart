import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:podo_words/database/local_storage_service.dart';
import 'package:podo_words/learning/controllers/ads_controller.dart';
import 'package:podo_words/learning/controllers/learning_controller.dart';
import 'package:podo_words/user/user_controller.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'main_frame.dart';

class LogoPage extends StatefulWidget {
  const LogoPage({Key? key}) : super(key: key);

  @override
  State<LogoPage> createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {
  String info = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // RevenueCat 초기화
    kReleaseMode ? await Purchases.setLogLevel(LogLevel.info) : await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration('goog_wEZbMxigJXRWTMnldeyiKamuHPL');
    } else {
      configuration = PurchasesConfiguration('appl_QkaeYBpxiJcmfjJICEOXDCoBqlf');
    }
    setState(() {
      info = 'Signing in...';
    });
    await FirebaseAuth.instance.signInAnonymously();
    String userId = FirebaseAuth.instance.currentUser!.uid;

    setState(() {
      info = 'Checking subscription...';
    });
    // Premium 정보 가져 오기
    await Purchases.configure(configuration..appUserID = userId);
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    final isPremiumUser = customerInfo.entitlements.active.isNotEmpty;

    if (!isPremiumUser) {
      Get.put(AdsController());
    }
    setState(() {
      info = 'Loading local data...';
    });
    await LocalStorageService().initLocalData();

    setState(() {
      info = 'Syncing your data...';
    });
    final userController = Get.put(UserController());
    await userController.initUser(userId, isPremiumUser);  // 유저 데이터 스트림 구독 시작

    await FirebaseCrashlytics.instance.setUserIdentifier(userId);

    Get.put(LearningController());

    setState(() {
      info = 'Getting things ready...';
    });
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Get.off(() => MainFrame());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        color: Colors.white,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder(
                future: PackageInfo.fromPlatform(),
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.hasData) {
                    return Positioned(top: 20.0, right: 20.0, child: Text('version : ${snapshot.data.version}'));
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
            Center(child: Image.asset('assets/images/logo.png')),
            Positioned(
              bottom: 100.0,
              child: Row(
                children: [
                  SizedBox(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.0,
                    ),
                    height: 20.0,
                    width: 20.0,
                  ),
                  SizedBox(width: 20.0),
                  Text(info)
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
