import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podo_words/check_active_words.dart';
import 'package:podo_words/main_bottom.dart';
import 'package:podo_words/wordListItem.dart';
import 'package:podo_words/words_my.dart';
import 'package:swipe_to/swipe_to.dart';


class MainReview extends StatefulWidget {
  @override
  _MainReviewState createState() => _MainReviewState();
}

class _MainReviewState extends State<MainReview> {

  CheckActiveWords checkActiveWords;
  Future<List<bool>> activeList;
  static const String KEY_MY_WORDS = 'myWords';


  @override
  Widget build(BuildContext context) {
    List<bool> toggleBtnSelections = List.generate(3, (_) => false);
    MyWords myWords = MyWords();
    checkActiveWords = CheckActiveWords(myWords.front);
    activeList = checkActiveWords.getBoolList(KEY_MY_WORDS);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                  hintText: 'Search'
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0 words'),
                    ToggleButtons(
                      children: <Widget>[
                        Icon(Icons.ac_unit),
                        Icon(Icons.call),
                        Icon(Icons.cake),
                      ],
                      onPressed: (int index) {
                        print('index: $index');
                        setState(() {
                          for (int i=0; i<toggleBtnSelections.length; i++) {
                            if (i == index) {
                              toggleBtnSelections[i] = true;
                            } else {
                              toggleBtnSelections[i] = false;
                            }
                          }
                          switch (index) {
                            case 0 :
                              //todo: inactive만 표시
                              break;

                            case 1 :
                            //todo: 모두 표시
                              break;

                            case 2 :
                            //todo: active만 표시
                              break;
                          }
                        });
                        print('selection : $toggleBtnSelections');
                      },
                      isSelected: toggleBtnSelections,
                      color: Colors.grey,
                      selectedColor: Colors.purple,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: ListView.separated (
                    shrinkWrap: true,
                    itemCount: myWords.front.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder <List<bool>> (
                          future: activeList,
                          builder: (BuildContext context, AsyncSnapshot<List<bool>> snapshot) {
                            Widget widget;
                            if(snapshot.hasData) {
                              print('snapshop has data!');
                              widget = WordListItem(myWords.front[index], myWords.back[index], snapshot.data[index]);
                            } else if(snapshot.hasError){
                              print('snapshop has error!');
                            } else {
                              print('snapshop has no data!');
                              widget = CircularProgressIndicator();
                            }
                            return SwipeTo(
                              onLeftSwipe: () {
                                setState(() {
                                  checkActiveWords.addInActiveWord(KEY_MY_WORDS, myWords.front[index]);
                                });
                              },
                              onRightSwipe: () {
                                setState(() {
                                  checkActiveWords.removeInActiveWord(KEY_MY_WORDS, myWords.front[index]);
                                });
                              },
                              rightSwipeWidget: Icon(Icons.add),
                              leftSwipeWidget: Icon(Icons.arrow_back),
                              child: widget,
                            );
                          }
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                  ),
                  onLongPress: () {
                    print('long pressed');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainBottom(context).getMainBottom(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.play_arrow),
        onPressed: (){
          showCupertinoModalPopup(
            context: context,
            builder: (_) => CupertinoActionSheet(
              message: Text('Select review mode', textScaleFactor: 2,),
              actions: [
                CupertinoActionSheetAction(
                  child: Text('quiz'),
                  onPressed: (){},
                ),
                CupertinoActionSheetAction(
                  child: Text('flash card'),
                  onPressed: (){},
                )
              ],
              cancelButton: CupertinoActionSheetAction(
                child: Text('cancel'),
                onPressed: (){Navigator.pop(context);},
              ),
            )
          );
        },
      ),
    );
  }
}
