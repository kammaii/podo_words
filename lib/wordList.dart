import 'package:flutter/material.dart';
import 'package:podo_words/main_learning_sliver.dart';
import 'package:podo_words/main_review.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/word.dart';
import 'package:swipe_to/swipe_to.dart';
import 'data_storage.dart';


typedef void StringCallback(String val);

class WordList extends StatefulWidget {

  Word word;
  bool isFromMainLearning;
  bool isDeleteMode;
  WordList(this.isFromMainLearning, this.word, this.isDeleteMode);

  @override
  _WordListState createState() => _WordListState();
}

class _WordListState extends State<WordList> {
  Color textColor = MyColors().purple;
  Color backColor = Colors.white;
  double itemHeight = 80.0;
  double iconHeight = 70.0;
  double leftMargin = 0.0;

  @override
  Widget build(BuildContext context) {
    MainReviewState? mainReviewState = context.findAncestorStateOfType<MainReviewState>();
    MainLearningSliverState? mainLearningSliverState = context.findAncestorStateOfType<MainLearningSliverState>();

    if(widget.isDeleteMode) {
      leftMargin = 50.0;
    } else {
      leftMargin = 0.0;
    }

    if(widget.word.isActive) {
      textColor = MyColors().purple;
      backColor = Colors.white;
    } else {
      textColor = MyColors().navyLight;
      backColor = MyColors().navyLightLight;
    }

    void setChecked(bool b) {
      DataStorage().myWords[widget.word.wordId!].isChecked = b;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      height: itemHeight,
      child: SwipeTo(
        onLeftSwipe: () {
          if(widget.isFromMainLearning) {
            mainLearningSliverState!.setState(() {
              DataStorage().addInActiveWord(widget.word.front);
            });
          } else {
            mainReviewState!.setState(() {
              DataStorage().addInActiveWord(widget.word.front);
            });
          }
        },
        onRightSwipe: () {
          if(widget.isFromMainLearning) {
            mainLearningSliverState!.setState(() {
              DataStorage().removeInActiveWord(widget.word.front);
            });
          } else {
            mainReviewState!.setState(() {
              DataStorage().removeInActiveWord(widget.word.front);
            });
          }
        },
        rightSwipeWidget: Container(
          height: iconHeight,
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Icon(Icons.check, color: Colors.blue,),
          color: Colors.greenAccent,
        ),
        leftSwipeWidget: Container(
          height: iconHeight,
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Icon(Icons.cancel_outlined, color: MyColors().red,),
          color: MyColors().pink,
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Visibility(
              visible: widget.isDeleteMode,
              child: Container(
                child: Checkbox(
                  value: widget.word.isChecked,
                  onChanged: (value){
                    setState(() {
                      setChecked(value!);
                    });
                  },
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(left: leftMargin),
              child: Card(
                color: backColor,
                child: InkWell(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.word.front, style: TextStyle(color: textColor, fontSize: 20.0),),
                          VerticalDivider(color: MyColors().navyLight, thickness: 2.0,),
                          Text(widget.word.back, style: TextStyle(color: textColor, fontSize: 20.0),)
                        ]
                    ),
                  ),
                  onTap: (){
                    //todo: 오디오 플레이
                    if(widget.isDeleteMode) {
                      setState(() {
                        setChecked(!widget.word.isChecked);
                      });
                    } else {
                      print('audio play');
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
