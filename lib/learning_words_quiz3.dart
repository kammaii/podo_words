import 'package:flutter/material.dart';
import 'package:podo_words/learning_words_bar.dart';

class LearningWordsQuiz3 extends StatefulWidget {

  //final Words words;

  //LearningWordsQuiz1(this.words);

  @override
  _LearningWordsQuiz3State createState() => _LearningWordsQuiz3State();
}

class _LearningWordsQuiz3State extends State<LearningWordsQuiz3> {
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LearningWordsBar(),
              IconButton(
                icon: Icon(Icons.play_circle_outline),
                iconSize: 150.0,
                onPressed: () => print('play button pressed'),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(border: Border.all()),
                child: Text('word', textScaleFactor: 2,),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(
                  color: Colors.black,
                ),
              ),
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
                    return InkWell(
                      onTap: (){},
                      child: Container(
                        color: Colors.yellow,
                        alignment: Alignment.center,
                        child: Text('ㄱ'),
                      ),
                    );
                  }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
