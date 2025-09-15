import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:podo_words/learning/controllers/ads_controller.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/learning/models/word.dart';
import 'package:podo_words/learning/controllers/learning_controller.dart';

class LearningPage extends StatefulWidget {
  LearningPage({super.key});

  @override
  _LearningFrameState createState() => _LearningFrameState();
}

class _LearningFrameState extends State<LearningPage> {
  final Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
  late bool shouldShowAds;
  late List<Word> words;
  final controller = Get.find<LearningController>();

  @override
  void initState() {
    super.initState();
    shouldShowAds = arguments['shouldShowAds'];
    words = arguments['words'];
    controller.initController(words);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (shouldShowAds) {
      AdsController().loadBannerAd(context);
    }
  }


  @override
  void dispose() {
    controller.wordIndex = 0.obs;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: MyColors().purpleLight,
          child: Column(
            children: [
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: LinearPercentIndicator(
                        animateFromLastPercent: true,
                        animation: true,
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Would you like to end the lesson?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(), // 다이얼로그 닫기
                                      child: Text('No', style: TextStyle(fontSize: 18)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); // 다이얼로그 먼저 닫기
                                        Get.back(); // 화면 나가기
                                      },
                                      child: Text('Yes', style: TextStyle(fontSize: 18)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        lineHeight: 8.0,
                        percent: controller.wordIndex.value / controller.words.length,
                        backgroundColor: MyColors().navyLight,
                        progressColor: MyColors().purple,
                        barRadius: Radius.circular(15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text('(${controller.wordIndex.value} / ${controller.words.length})'),
                    )
                  ],
                ),
              ),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Quiz'),
                    const SizedBox(width: 10),
                    Switch(
                      value: controller.isQuizOn.value,
                      activeTrackColor: MyColors().navyLight,
                      activeColor: MyColors().purple,
                      onChanged: (value) {
                        controller.setQuizToggle();
                      },
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
              GetBuilder<LearningController>(
                builder: (_) {
                  return Expanded(
                    child: Stack(
                      children: controller.content,
                    ),
                  );
                }
              ),
              shouldShowAds
                  ? GetBuilder<AdsController>(builder: (controller) {
                      if (controller.bannerAd != null && controller.isBannerAdLoaded) {
                        return Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: controller.bannerAd!.size.width.toDouble(),
                          height: controller.bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: controller.bannerAd!),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    })
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
