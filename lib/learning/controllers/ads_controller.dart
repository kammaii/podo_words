import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// ANDROID_앱ID : ca-app-pub-4839718329129134~5372334846
// IOS_앱ID : ca-app-pub-4839718329129134~4282614457

class AdsController extends GetxController {
  final ANDROID_REWARD = 'android_reward';
  final ANDROID_BANNER = 'android_banner';
  final ANDROID_INTERSTITIAL = 'android_interstitial';
  final IOS_REWARD = 'ios_reward';
  final IOS_BANNER = 'ios_banner';
  final IOS_INTERSTITIAL = 'ios_interstitial';

  static final AdsController _instance = AdsController.init();

  factory AdsController() {
    return _instance;
  }

  AdsController.init() {
    _initAds();
    loadRewardAds();
    loadInterstitialAd();
    print('Ads 초기화');
  }

  late final Map<String, String> UNIT_ID;
  RewardedInterstitialAd? rewardedInterstitialAd;
  InterstitialAd? interstitialAd;
  BannerAd? bannerAd;
  bool isBannerAdLoaded = false;
  bool isAdFullWatched = false;

  _initAds() {
    MobileAds.instance.initialize();
    UNIT_ID = kReleaseMode
        ? {
            ANDROID_REWARD: 'ca-app-pub-4839718329129134/3832177999',
            ANDROID_BANNER: 'ca-app-pub-4839718329129134/6607225588',
            ANDROID_INTERSTITIAL: 'ca-app-pub-4839718329129134/7451069123',
            IOS_REWARD: 'ca-app-pub-4839718329129134/6783126033',
            IOS_BANNER: 'ca-app-pub-4839718329129134/4517368423',
            IOS_INTERSTITIAL: 'ca-app-pub-4839718329129134/4176655636',
          }
        : {
            // TEST ID
            ANDROID_REWARD: 'ca-app-pub-3940256099942544/5354046379',
            ANDROID_BANNER: 'ca-app-pub-3940256099942544/6300978111',
            ANDROID_INTERSTITIAL: 'ca-app-pub-3940256099942544/1033173712',
            IOS_REWARD: 'ca-app-pub-3940256099942544/6978759866',
            IOS_BANNER: 'ca-app-pub-3940256099942544/2934735716',
            IOS_INTERSTITIAL: 'ca-app-pub-3940256099942544/4411468910',
          };
  }

  void loadRewardAds() {
    RewardedInterstitialAd.load(
      adUnitId: UNIT_ID[Platform.isIOS ? IOS_REWARD : ANDROID_REWARD]!,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('리워드 광고 로드 성공');
          rewardedInterstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError e) {
          debugPrint('리워드 광고 로드 실패: $e');
        },
      ),
    );
  }

  void showRewardAdAndStartLesson(VoidCallback onLessonStart) {
    if (rewardedInterstitialAd != null) {
      rewardedInterstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedInterstitialAd ad) {
          print('📺 광고 시작');
        },
        onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
          ad.dispose();
          rewardedInterstitialAd = null;
          loadRewardAds();

          if (isAdFullWatched) {
            isAdFullWatched = false;
            print('✅ 광고 끝까지 봄 → 레슨 시작');
            onLessonStart();
          } else {
            print('❌ 광고 중단 → 레슨 차단');
            Get.snackbar('Ad Skipped', 'You must watch the full ad to start the lesson.');
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('⚠️ 광고 재생 실패: $error');
          ad.dispose();
          rewardedInterstitialAd = null;
          Get.snackbar('Ad Error', 'Unable to play the ad. Please check your internet connection.');
        },
      );

      rewardedInterstitialAd!.show(
        onUserEarnedReward: (ad, reward) {
          isAdFullWatched = true;
          print('🎁 리워드 획득');
        },
      );
    } else {
      Get.snackbar('Ad Not Ready', 'The ad is still loading. Please try again in a moment.');
    }
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: UNIT_ID[Platform.isIOS ? IOS_INTERSTITIAL : ANDROID_INTERSTITIAL]!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('전면 광고 로드 성공');
          interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError e) {
          debugPrint('전면 광고 로드 실패: $e');
          interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onAdClosed}) {
    if (interstitialAd != null) {
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (InterstitialAd ad) {
          print('📺 전면 광고 시작');
        },
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          print('✅ 전면 광고 닫힘');
          ad.dispose(); // 광고 리소스 해제
          interstitialAd = null;
          loadInterstitialAd(); // 다음 광고 미리 로드
          onAdClosed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('⚠️ 전면 광고 재생 실패: $error');
          ad.dispose();
          interstitialAd = null;
          loadInterstitialAd();
          onAdClosed?.call();
        },
      );
      interstitialAd!.show();
    } else {
      // 만약 광고가 준비되지 않았다면, 다음을 위해 로드 시도
      print('⚠️ 전면 광고가 준비되지 않았습니다. 로드를 시도합니다.');
      loadInterstitialAd();
      onAdClosed?.call();
    }
  }

  void loadBannerAd(BuildContext context) async {
    // 기존 배너 광고를 정리
    bannerAd?.dispose();
    bannerAd = null;
    isBannerAdLoaded = false;

    final AnchoredAdaptiveBannerAdSize? size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.of(context).size.width.truncate());
    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    bannerAd = BannerAd(
      size: size,
      adUnitId: UNIT_ID[Platform.isIOS ? IOS_BANNER : ANDROID_BANNER]!,
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError e) {
          print('배너 광고 로드 실패 : $e');
          ad.dispose();
          // 상태 초기화 및 업데이트
          bannerAd = null;
          isBannerAdLoaded = false;
          update();
        },
        onAdLoaded: (Ad ad) {
          print('배너 광고 로드 성공');
          bannerAd = ad as BannerAd;
          isBannerAdLoaded = true;
          update();
        },
      ),
      request: const AdRequest(),
    )..load();
  }
}
