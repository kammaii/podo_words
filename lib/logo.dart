import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:podo_words/common/ads_controller.dart';
import 'package:podo_words/learning/learning_controller.dart';
import 'common/data_storage.dart';
import 'main_frame.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:podo_words/user/user.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);
  static const String apiKey = "LRxYKUXrCOWeznKDBOlaqWuLaNJYEZCF";

  Future<void> initData() async {
    // RevenueCat 초기화
    kReleaseMode ? await Purchases.setLogLevel(LogLevel.info) : await Purchases.setLogLevel(LogLevel.debug);
    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration('goog_wEZbMxigJXRWTMnldeyiKamuHPL');
    } else {
      configuration = PurchasesConfiguration('appl_QkaeYBpxiJcmfjJICEOXDCoBqlf');
    }
    await FirebaseAuth.instance.signInAnonymously();
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await Purchases.configure(configuration..appUserID = userId);
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);

    // Premium 정보 가져 오기
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    final isPremiumUser = customerInfo.entitlements.active.isNotEmpty;

    if (!isPremiumUser) {
      Get.put(AdsController());
    }

    await DataStorage().initLocalData(isPremiumUser);
    Get.put(LearningController());

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      Get.off(() => MainFrame());
    });
  }

  @override
  Widget build(BuildContext context) {
    initData();

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
                  Text('Loading...')
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
