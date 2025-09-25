import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/learning/controllers/learning_controller.dart';

import '../learning/controllers/ads_controller.dart';
import '../learning/controllers/audio_controller.dart';
import '../learning/models/word_model.dart';
import '../learning/pages/learning_complete_page.dart';
import '../learning/widgets/audio_button.dart';
import '../user/user_controller.dart';

class ReviewFlashCardPage extends StatefulWidget {
  final List<Word> words;

  const ReviewFlashCardPage(this.words, {super.key});

  @override
  _ReviewFlashCardPageState createState() => _ReviewFlashCardPageState();
}

class _ReviewFlashCardPageState extends State<ReviewFlashCardPage> {
  late final List<Word> _words;
  late Word _currentWord;
  int _cardIndex = 0;
  bool _isReversed = false;
  bool _isAnswerVisible = false;
  late final bool _shouldShowAds;
  final userController = Get.find<UserController>();
  final learningController = Get.find<LearningController>();

  @override
  void initState() {
    super.initState();
    _words = List.of(widget.words);
    _updateCurrentCard(0);
    _shouldShowAds = Get.arguments ?? false;
  }

  // context를 안전하게 사용하기 위해 광고 로딩 로직을 didChangeDependencies로 이동
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shouldShowAds) {
      Get.find<AdsController>().loadBannerAd(context);
    }
  }

  void _updateCurrentCard(int index) {
    setState(() {
      _cardIndex = index;
      _currentWord = _words[_cardIndex];
      if(!_isReversed) {
        AudioController().playWordAudio(_currentWord);
      }
    });
  }

  void _showAnswer() {
    if(_isReversed) {
      AudioController().playWordAudio(_currentWord);
    }
    setState(() {
      _isAnswerVisible = true;
    });
  }

  void _nextCard() {
    final nextIndex = _cardIndex + 1;

    if(nextIndex < _words.length) {
      setState(() {
        _isAnswerVisible = false;
        _updateCurrentCard(nextIndex);
      });
    } else {
      // 복습 완료 처리
      print('플래시카드 복습 완료!');
      userController.updateReviewProgress(_words);
      learningController.words = _words;
      Get.to(() => const LearningCompletePage());
    }


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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Front', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    Row(
                      children: [
                        const Text('reverse'),
                        Switch(
                          value: _isReversed,
                          onChanged: (value) => setState(() => _isReversed = value),
                        ),
                      ],
                    ),
                  ],
                ),
                Expanded(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    child: Center(child: Text(frontText, style: const TextStyle(fontSize: 30))),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Back', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Expanded(
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                    child: Center(
                        child: Text(_isAnswerVisible ? backText : '', style: const TextStyle(fontSize: 30))),
                  ),
                ),
                _buildControlPanel(),
                if (_shouldShowAds) _buildBannerAd(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildControlPanel() {
    return Column(
      children: [
        Center(child: AudioButton(_currentWord)),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: _isAnswerVisible ? _nextCard : _showAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: MyColors().purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              padding: const EdgeInsets.all(15.0),
              minimumSize: const Size.fromHeight(50), // 버튼 높이 지정
            ),
            child: Text(
              _isAnswerVisible ? 'Next word' : 'Answer',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildBannerAd() {
    return GetBuilder<AdsController>(builder: (controller) {
      if (controller.bannerAd != null && controller.isBannerAdLoaded) {
        return SizedBox(
          width: controller.bannerAd!.size.width.toDouble(),
          height: controller.bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: controller.bannerAd!),
        );
      }
      return const SizedBox.shrink();
    });
  }
}
