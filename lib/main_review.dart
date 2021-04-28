import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podo_words/check_active_words.dart';
import 'package:podo_words/main_bottom.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/wordListItem.dart';
import 'package:podo_words/words_my.dart';
import 'package:swipe_to/swipe_to.dart';


class MainReview extends StatefulWidget {
  @override
  _MainReviewState createState() => _MainReviewState();
}

class _MainReviewState extends State<MainReview> {

  CheckActiveWords checkActiveWords;
  Future<List<bool>> futureActiveList;
  List<bool> activeList;
  static const String KEY_MY_WORDS = 'myWords';
  List<bool> toggleSelections = [true, false, false];
  MyWords myWords;



  @override
  Widget build(BuildContext context) {
    myWords = MyWords();
    checkActiveWords = CheckActiveWords(myWords.front);
    futureActiveList = checkActiveWords.getBoolList(KEY_MY_WORDS);

    Widget toggleButtons(IconData icon, int toggleIndex) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: OutlinedButton(
            style: ButtonStyle(
                shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    )
                ),
                backgroundColor: MaterialStateProperty.resolveWith((_) {
                  if(toggleSelections[toggleIndex]) {
                    return MyColors().navyDark;
                  } else {
                    return Colors.white;
                  }
                }),
                foregroundColor: MaterialStateProperty.resolveWith((_) {
                  if(toggleSelections[toggleIndex]) {
                    return Colors.white;
                  } else {
                    return MyColors().navyLight;
                  }
                }),
                side: MaterialStateProperty.resolveWith((_) {
                  return BorderSide(color: Colors.transparent);
                })
            ),
            child: Icon(icon),
            onPressed: (){
              setState(() {
                for(int i=0; i<toggleSelections.length; i++) {
                  if(i == toggleIndex) {
                    toggleSelections[i] = true;
                  } else {
                    toggleSelections[i] = false;
                  }
                }
                //todo: 토글버튼 액션 실행1

              });
            },
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: MyColors().navyLight,
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(color: MyColors().navyLight, width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          borderSide: BorderSide(color: MyColors().navyLight, width: 2.0),
                        ),
                        hintText: 'Search your words',
                        filled: true,
                        fillColor: Colors.white
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          toggleButtons(Icons.all_inclusive, 0),
                          toggleButtons(Icons.check, 1),
                          toggleButtons(Icons.close, 2),
                        ]
                      )
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('0 words'),
              ),
              Expanded(
                child: GestureDetector(
                  child: ListView.separated (
                    shrinkWrap: true,
                    itemCount: myWords.front.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder <List<bool>> (
                          future: futureActiveList,
                          builder: (BuildContext context, AsyncSnapshot<List<bool>> snapshot) {
                            activeList = snapshot.data;
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
