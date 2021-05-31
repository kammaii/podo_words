import 'package:flutter/material.dart';
import 'package:podo_words/divider_text.dart';
import 'package:podo_words/word.dart';
import 'my_colors.dart';
import 'package:unicode/unicode.dart';

class LearningWordsQuiz3 extends StatefulWidget {

  List<Word> words = [];
  LearningWordsQuiz3(this.words);

  @override
  _LearningWordsQuiz3State createState() => _LearningWordsQuiz3State();
}

class _LearningWordsQuiz3State extends State<LearningWordsQuiz3> {
  int wordIndex = 0;
  String front = "";
  String back = "";

  @override
  Widget build(BuildContext context) {
    front = widget.words[wordIndex].front;
    back = widget.words[wordIndex].back;

    List<String> frontSplit = front.split('');
    //todo: frontSplit를 자모음으로 나누기
    //todo: 자모음 버튼을 클릭하면 한글로 변환하기

    String str = '사';
    double cho = ((toRune(str) - 0xAC00) / 28) / 21 + 0x1100;
    double jung = ((toRune(str) - 0xAC00) / 28) % 21 + 0x1161;
    double jong = ((toRune(str) - 0xAC00) % 28) + 0x11A8 - 1;
    print('초 : $cho');
    print('중 : $jung');
    print('종 : $jong');
    //String choString = String.fromCharCode(cho);

    print(toRune(str));
    print(String.fromCharCode(4361));
    print(String.fromCharCode(4449));
    print(String.fromCharCode(4519));




    return Scaffold(
      body: SafeArea(
        child: Container(
          color: MyColors().purpleLight,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                IconButton(
                  icon: Icon(Icons.multitrack_audio, color: MyColors().purple,),
                  iconSize: 100.0,
                  onPressed: () => print('play button pressed'),
                ),
                DividerText().getDivider('Listen & Answer'),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Center(child: Text('text', textScaleFactor: 1.5)),
                  ),
                ),
                SizedBox(height: 20.0),
                GridView.builder(
                    shrinkWrap: true,
                    itemCount: 5,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: InkWell(
                          onTap: (){
                            setState(() {

                            });
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Center(
                                child: Text('aa', textScaleFactor: 1.5),
                              )
                          ),
                        ),
                      );
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
