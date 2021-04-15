import 'package:flutter/material.dart';
import 'package:podo_words/learning_words_bar.dart';

class LearningWordsQuiz2 extends StatefulWidget {

  //final Words words;

  //LearningWordsQuiz1(this.words);

  @override
  _LearningWordsQuiz2State createState() => _LearningWordsQuiz2State();
}

class _LearningWordsQuiz2State extends State<LearningWordsQuiz2> {
  int wordIndex = 0;
  String front;
  String back;

  @override
  Widget build(BuildContext context) {
    //front = widget.words.front[wordIndex];
    //back = widget.words.back[wordIndex];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: Column(
            children: [
              LearningWordsBar(),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: 4,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                        crossAxisCount: 2,
                        childAspectRatio: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                      ),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: (){},
                          child: Container(
                            color: Colors.yellow,
                            alignment: Alignment.center,
                            child: Text('word'),
                          ),
                        );
                      }
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Divider(
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      crossAxisCount: 2,
                      childAspectRatio: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: (){},
                        child: Container(
                          color: Colors.yellow,
                          alignment: Alignment.center,
                          child: Text('word'),
                        ),
                      );
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
