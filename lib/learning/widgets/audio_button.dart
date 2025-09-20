import 'dart:async';

import 'package:flutter/material.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/learning/controllers/audio_controller.dart';
import 'package:podo_words/learning/models/word_model.dart';

class AudioButton extends StatefulWidget {

  Word word;
  AudioButton(this.word);

  @override
  _AudioButtonState createState() => _AudioButtonState();
}

class _AudioButtonState extends State<AudioButton> {

  Color color = MyColors().purple;

  @override
  Widget build(BuildContext context) {

    return ClipOval(
      child: Material(
        child: InkWell(
          child: Icon(Icons.play_circle_outline_rounded, color: color, size: 100.0),
          onTap: () {
            if(widget.word != '') {
              AudioController().playWordAudio(widget.word);
            }
          }
        ),
      ),
    );
  }
}
