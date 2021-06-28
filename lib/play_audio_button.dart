import 'dart:async';

import 'package:flutter/material.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/play_audio.dart';

class PlayAudioButton extends StatefulWidget {

  String audio;
  PlayAudioButton(this.audio);

  @override
  _PlayAudioButtonState createState() => _PlayAudioButtonState();
}

class _PlayAudioButtonState extends State<PlayAudioButton> {

  Color color = MyColors().purple;

  @override
  Widget build(BuildContext context) {

    return ClipOval(
      child: Material(
        child: InkWell(
          child: Icon(Icons.play_circle_outline_rounded, color: color, size: 100.0),
          onTap: () {
            if(widget.audio != '') {
              PlayAudio().playWord(widget.audio);
            }
          }
        ),
      ),
    );
  }
}
