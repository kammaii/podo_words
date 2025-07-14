import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:podo_words/common/ads_controller.dart';
import 'package:podo_words/learning/learning_complete.dart';
import 'package:podo_words/learning/learning_quiz_frame.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/common/play_audio.dart';
import 'package:podo_words/common/word.dart';
import 'package:podo_words/learning/learning_quiz3.dart';
import 'package:podo_words/common/play_audio_button.dart';

class LearningFrame extends StatefulWidget {
  List<Word> words;

  LearningFrame(this.words);

  @override
  _LearningFrameState createState() => _LearningFrameState();
}

class _LearningFrameState extends State<LearningFrame> {
  late List<Word> words;
  int wordIndex = 0;
  late String front;
  late String back;
  late String pronunciation;
  late String audio;
  late String image;
  bool isQuizOn = true;
  bool isRightSwipe = false;
  bool shouldShowAds = Get.arguments;

  Widget wordCard() {
    Image searchedImage = Image.asset(
      'assets/images/words/$image',
      fit: BoxFit.fitWidth,
      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
        return SizedBox(height: 0);
      },
    );

    return Material(
      elevation: 1,
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 50.0),
              child: searchedImage,
            ),
            SizedBox(height: 20.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  front,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                SizedBox(height: 5.0),
                Text(
                  pronunciation,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(height: 30.0),
                Text(
                  back,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Word> getWordListForQuiz(int wordsNoForQuiz) {
    int index = wordIndex - 1;
    List<Word> wordList = [];
    for (int i = 0; i < wordsNoForQuiz; i++) {
      Word word = words[index - i];
      wordList.add(word);
    }
    wordList = List.from(wordList.reversed);

    if (wordsNoForQuiz < 4) {
      for (int i = 0; i < 4 - wordsNoForQuiz; i++) {
        wordList.insert(i, words[i]);
      }
    }
    return wordList;
  }

  @override
  void initState() {
    super.initState();
    words = widget.words;
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
    if (wordIndex < words.length) {
      front = words[wordIndex].front;
      back = words[wordIndex].back;
      if (words[wordIndex].pronunciation != '-') {
        pronunciation = '[${words[wordIndex].pronunciation}]';
      } else {
        pronunciation = '-';
      }
      audio = words[wordIndex].audio;
      image = words[wordIndex].image;
    } else {
      front = '';
      back = '';
      pronunciation = 'Last card';
      audio = '';
    }

    if (wordIndex >= words.length) {
      // 마지막 단어 -> 퀴즈 1&2 -> 퀴즈3
      if (isQuizOn) {
        int leftWordsCount = words.length % 4;
        List<Word> wordsListForQuiz;

        if (leftWordsCount == 0) {
          leftWordsCount = 4;
        }
        wordsListForQuiz = getWordListForQuiz(leftWordsCount);

        SchedulerBinding.instance.addPostFrameCallback((_) async {
          await Get.to(() => LearningQuizFrame(leftWordsCount, wordsListForQuiz));
          Get.to(() => LearningQuiz3(words));
        });
      } else {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          Get.to(() => LearningComplete(words));
        });
      }
    } else {
      if (isQuizOn && isRightSwipe && wordIndex != 0 && wordIndex % 4 == 0) {
        // 퀴즈 1&2 -> 다음 단어 오디오 재생
        List<Word> wordListForQuiz = getWordListForQuiz(4);
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          await Get.to(() => LearningQuizFrame(4, wordListForQuiz));
          PlayAudio().playWord(audio);
        });
      } else {
        PlayAudio().playWord(audio);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: MyColors().purpleLight,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: LinearPercentIndicator(
                      animateFromLastPercent: true,
                      animation: true,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () => Get.back(),
                      ),
                      lineHeight: 8.0,
                      percent: wordIndex / words.length,
                      backgroundColor: MyColors().navyLight,
                      progressColor: MyColors().purple,
                      barRadius: Radius.circular(15),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text('($wordIndex / ${words.length})'),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Quiz'),
                  const SizedBox(width: 10),
                  Switch(
                    value: isQuizOn,
                    activeTrackColor: MyColors().navyLight,
                    activeColor: MyColors().purple,
                    onChanged: (value) {
                      setState(() {
                        isQuizOn = value;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              Expanded(
                child: Swiper(
                  itemBuilder: (context, index) {
                    return wordCard();
                  },
                  loop: false,
                  itemCount: words.length + 1,
                  viewportFraction: 0.7,
                  scale: 0.7,
                  onIndexChanged: (index) {
                    if (index > wordIndex) {
                      isRightSwipe = true;
                    } else {
                      isRightSwipe = false;
                    }
                    setState(() {
                      wordIndex = index;
                    });
                  },
                ),
              ),
              Padding(padding: const EdgeInsets.symmetric(vertical: 20.0), child: PlayAudioButton(audio)),
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
