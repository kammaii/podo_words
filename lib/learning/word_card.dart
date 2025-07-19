import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/common/play_audio.dart';
import 'package:podo_words/common/play_audio_button.dart';
import 'package:podo_words/common/word.dart';
import 'package:podo_words/learning/learning_controller.dart';

class WordCard extends StatefulWidget {
  WordCard({super.key});

  @override
  State<WordCard> createState() => _WordCardState();
}

class _WordCardState extends State<WordCard> {
  final controller = Get.find<LearningController>();

  @override
  Widget build(BuildContext context) {
    Word word = controller.getThisWord();
    Image wordImage = Image.asset(
      'assets/images/words/${word.image}',
      fit: BoxFit.fitWidth,
      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
        return Image.asset('assets/images/words/transparent.png', fit: BoxFit.fitWidth);
      },
    );

    return Column(
      children: [
        Expanded(
          child: Swiper(
            itemBuilder: (context, index) {
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
                        child: wordImage,
                      ),
                      SizedBox(height: 20.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            word.front,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                          SizedBox(height: 5.0),
                          Text(
                            word.pronunciation,
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 30.0),
                          Text(
                            word.back,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            loop: false,
            itemCount: controller.words.length,
            viewportFraction: 0.7,
            scale: 0.7,
            onIndexChanged: (index) {
              setState(() {
                if (index > controller.wordIndex.value) {
                  controller.swipeWordCard(isNext: true);
                } else {
                  controller.swipeWordCard(isNext: false);
                }
              });
            },
          ),
        ),
        Padding(padding: const EdgeInsets.symmetric(vertical: 20.0), child: PlayAudioButton(word.audio)),
      ],
    );
  }
}
