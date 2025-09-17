import 'dart:convert';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/learning/widgets/audio_button.dart';
import 'package:podo_words/learning/models/word.dart';
import 'package:podo_words/learning/controllers/learning_controller.dart';

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
                        child: controller.getWordImage(word),
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
            itemCount: controller.words.length + 1,
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
        Padding(padding: const EdgeInsets.symmetric(vertical: 20.0), child: AudioButton(word)),
      ],
    );
  }
}
