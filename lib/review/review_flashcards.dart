import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:podo_words/common/ads_controller.dart';
import 'package:podo_words/common/list_mix.dart';
import 'package:podo_words/common/play_audio.dart';
import 'package:podo_words/common/play_audio_button.dart';
import 'package:podo_words/common/word.dart';

import '../common/my_colors.dart';

class ReviewFlashCards extends StatefulWidget {

  List<Word> words;

  ReviewFlashCards(this.words);

  @override
  _ReviewFlashCardsState createState() => _ReviewFlashCardsState();
}

class _ReviewFlashCardsState extends State<ReviewFlashCards> {

  int count = 0;
  bool isReverse = false;
  late String front;
  late String back;
  late String audio;
  bool isAnswer = false;
  String btnText = 'Answer';
  bool shouldShowAds = Get.arguments;


  void setFlashCard() {
    if(!isAnswer) {
      if (!isReverse) {
        front = widget.words[count].front;
        back = widget.words[count].back;
      } else {
        front = widget.words[count].back;
        back = widget.words[count].front;
      }
      audio = widget.words[count].audio;
      PlayAudio().playWord(audio);
    }
  }


  @override
  void initState() {
    super.initState();
    ListMix().getMixedList(widget.words);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (shouldShowAds) {
      AdsController().loadBannerAd(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    setFlashCard();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: MyColors().purple),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: Container(
            color: MyColors().purpleLight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Front', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('reverse'),
                          Switch(
                            value: isReverse,
                            activeTrackColor: MyColors().navyLight,
                            activeColor: MyColors().purple,
                            onChanged: (value) {
                              setState(() {
                                isReverse = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    child: Center(
                      child: Text('$front', style: TextStyle(fontSize: 30))
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text('Back', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                    ],
                  ),
                ),
                Expanded(
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                    child: Visibility(
                      visible: isAnswer,
                      child: Center(
                          child: Text('$back', style: TextStyle(fontSize: 30))
                        )
                    ),
                  ),
                ),
                Center(child: PlayAudioButton(audio)),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: (){
                      setState(() {
                        if(isAnswer) {
                          isAnswer = false;
                          btnText = 'Answer';
                          if(count+1 < widget.words.length) {
                            count++;
                          } else {
                            count = 0;
                          }

                        } else {
                          isAnswer = true;
                          btnText = 'Next word';
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: MyColors().purple,
                          borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                            child: Text(btnText, style: TextStyle(color: Colors.white, fontSize: 20),
                            )
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
              ]
            ),
          ),
        ),
      ),
    );
  }
}
