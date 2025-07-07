import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common/data_storage.dart';
import 'main_frame.dart';
import 'package:package_info/package_info.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

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
    await Purchases.configure(configuration);

    // Premium 정보 가져 오기
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    String userId = await Purchases.appUserID;
    final premiumEntitlement = customerInfo.entitlements.active['podo_words_1000'];
    bool isPremiumUser = premiumEntitlement != null;

    print('유저아이디: $userId');

    if (!isPremiumUser) {
      //todo: admob 광고 초기화
    }

    await DataStorage().initLocalData(isPremiumUser);

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
