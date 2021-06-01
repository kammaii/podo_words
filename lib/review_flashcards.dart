import 'package:flutter/material.dart';
import 'package:podo_words/word.dart';

class ReviewFlashCards extends StatefulWidget {

  List<Word> words;

  ReviewFlashCards(this.words);

  @override
  _ReviewFlashCardsState createState() => _ReviewFlashCardsState();
}

class _ReviewFlashCardsState extends State<ReviewFlashCards> {

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Reviewed $count words', textScaleFactor: 2),
                    IconButton(
                      icon: Icon(Icons.exit_to_app),
                      iconSize: 50.0,
                      onPressed: (){Navigator.pop(context);},
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(border: Border.all()),
                  child: Text('사과', textScaleFactor: 3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Divider(
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(border: Border.all()),
                  child: Text('apple', textScaleFactor: 3),
                ),
              ),
              IconButton(
                icon: Icon(Icons.play_circle_outline),
                iconSize: 150.0,
                onPressed: () => print('play button pressed'),
              ),
            ]
          ),
        ),
      ),
      bottomNavigationBar: ElevatedButton(
          onPressed: (){},
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Next', textScaleFactor: 2,),
          )
      ),
    );
  }
}
