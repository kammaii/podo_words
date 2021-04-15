import 'package:flutter/material.dart';
import 'package:podo_words/learning_words_bar.dart';

class LearningWordsQuiz1 extends StatefulWidget {

  //final Words words;

  //LearningWordsQuiz1(this.words);

  @override
  _LearningWordsQuiz1State createState() => _LearningWordsQuiz1State();
}

class _LearningWordsQuiz1State extends State<LearningWordsQuiz1> {
  int wordIndex = 0;
  String front;
  String back;
  List<String> image;

  @override
  Widget build(BuildContext context) {
    //front = widget.words.front[wordIndex];
    //back = widget.words.back[wordIndex];
    //image = widget.words.image;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: Column(
            children: [
              LearningWordsBar(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '사과',
                    textScaleFactor: 5,
                  ),
                  IconButton(
                    icon: Icon(Icons.play_circle_outline),
                    iconSize: 80.0,
                    onPressed: () => print('play button pressed'),
                  ),
                ]
                ),
              Divider(
                color: Colors.black,
              ),
              Expanded(
                child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: 4,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: (){},
                        child: Container(
                          color: Colors.yellow,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: FlutterLogo(),
                              ),
                              Text('word'),
                            ],
                          ) ,
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
