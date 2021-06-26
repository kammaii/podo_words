import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podo_words/list_mix.dart';
import 'package:podo_words/play_audio.dart';
import 'package:podo_words/word.dart';

import 'my_colors.dart';

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
  Widget build(BuildContext context) {
    setFlashCard();

    return Scaffold(
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
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text('$count words')
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Front', textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold)),
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
                      child: Text('$front', textScaleFactor: 2)
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text('Back', textScaleFactor: 1.5, style: TextStyle(fontWeight: FontWeight.bold))
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
                          child: Text('$back', textScaleFactor: 2)
                        )
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.play_circle_outline_rounded, color: MyColors().purple,),
                  iconSize: 80.0,
                  onPressed: () => PlayAudio().playWord(audio),
                ),
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
                            child: Text(btnText, textScaleFactor: 1.5, style: TextStyle(color: Colors.white),
                            )
                        ),
                      ),
                    ),
                  ),
                )
              ]
            ),
          ),
        ),
      ),
    );
  }
}
