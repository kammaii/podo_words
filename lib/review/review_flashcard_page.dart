import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:podo_words/learning/controllers/ads_controller.dart';
import 'package:podo_words/learning/controllers/audio_controller.dart';
import 'package:podo_words/learning/widgets/audio_button.dart';
import 'package:podo_words/learning/models/word.dart';
import '../common/my_colors.dart';

class ReviewFlashCardPage extends StatefulWidget {
  final List<Word> words;

  const ReviewFlashCardPage(this.words, {super.key});

  @override
  _ReviewFlashCardPageState createState() => _ReviewFlashCardPageState();
}

class _ReviewFlashCardPageState extends State<ReviewFlashCardPage> {
  late final List<Word> _shuffledWords;
  late Word _currentWord;
  int _cardIndex = 0;
  bool _isReversed = false;
  bool _isAnswerVisible = false;
  late final bool _shouldShowAds;

  @override
  void initState() {
    super.initState();
    // 1. 원본 리스트를 수정하지 않고, 복사본을 만들어 섞습니다. (부수 효과 방지)
    _shuffledWords = List.of(widget.words)..shuffle();

    // 2. 초기 카드 설정 및 오디오 재생
    _updateCurrentCard(0);

    // 3. 광고 로직 처리
    _shouldShowAds = Get.arguments ?? false;
    if (_shouldShowAds) {
      AdsController().loadBannerAd(context);
    }
  }

  /// 현재 카드를 설정하고 오디오를 재생하는 함수
  void _updateCurrentCard(int index) {
    setState(() {
      _cardIndex = index;
      _currentWord = _shuffledWords[_cardIndex];
      AudioController().playWordAudio(_currentWord);
    });
  }

  /// 'Answer' 버튼을 눌렀을 때의 로직
  void _showAnswer() {
    setState(() {
      _isAnswerVisible = true;
    });
  }

  /// 'Next word' 버튼을 눌렀을 때의 로직
  void _nextCard() {
    setState(() {
      final nextIndex = (_cardIndex + 1) % _shuffledWords.length;
      _isAnswerVisible = false;
      _updateCurrentCard(nextIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final frontText = _isReversed ? _currentWord.back : _currentWord.front;
    final backText = _isReversed ? _currentWord.front : _currentWord.back;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: MyColors().purple),
          onPressed: () => Get.back(),
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
                // --- 상단 카드 (Front) ---
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Front', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      Row(
                        children: [
                          const Text('reverse'),
                          Switch(
                            value: _isReversed,
                            onChanged: (value) {
                              setState(() {
                                _isReversed = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    child: Center(child: Text(frontText, style: const TextStyle(fontSize: 30))),
                  ),
                ),
                // --- 하단 카드 (Back) ---
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Back', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                Expanded(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    child: Center(
                      child: Visibility(
                        visible: _isAnswerVisible,
                        child: Text(backText, style: const TextStyle(fontSize: 30)),
                      ),
                    ),
                  ),
                ),
                // --- 컨트롤 버튼 ---
                Center(child: AudioButton(_currentWord)),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ElevatedButton(
                    onPressed: _isAnswerVisible ? _nextCard : _showAnswer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColors().purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                      padding: const EdgeInsets.all(15.0),
                    ),
                    child: Text(
                      _isAnswerVisible ? 'Next word' : 'Answer', // [수정] 상태에 따라 텍스트 동적 결정
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // --- 광고 위젯 ---
                if (_shouldShowAds)
                  GetBuilder<AdsController>(builder: (controller) {
                    if (controller.bannerAd != null && controller.isBannerAdLoaded) {
                      return SizedBox(
                        width: controller.bannerAd!.size.width.toDouble(),
                        height: controller.bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: controller.bannerAd!),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}