import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podo_words/main_bottom.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/word.dart';
import 'package:podo_words/wordList.dart';
import 'data_storage.dart';


class MainReview extends StatefulWidget {
  @override
  MainReviewState createState() => MainReviewState();
}

class MainReviewState extends State<MainReview> {

  List<Word> myWords = [];
  List<Word> myWordsInList = [];
  List<bool> toggleSelections = [true, false, false];
  String searchInput = "";

  bool isPlayBtn = true;
  Widget floatingBtn = Icon(Icons.play_arrow_rounded, color: MyColors().green, size: 50.0);

  final textFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    textFieldController.addListener(() {setTextField();});
  }

  void setTextField() {
    setState(() {
      searchInput = textFieldController.text;
    });
  }

  @override
  Widget build(BuildContext context) {

    myWords = DataStorage().myWords;
    for(int i=0; i<myWords.length; i++) {
      myWords[i].wordId = i;
      myWords[i].isChecked = false;
    }

    myWordsInList = [];
    if(searchInput.length > 0) {
      for(Word myWord in myWords) {
        if(myWord.front.contains(searchInput) || myWord.back.contains(searchInput)) {
          myWordsInList.add(myWord);
        }
      }

    } else if(toggleSelections[0]) {
      myWordsInList = myWords;

    } else if(toggleSelections[1]) {
      for(Word myWord in myWords) {
        if(myWord.isActive) {
          myWordsInList.add(myWord);
        }
      }

    } else {
      for(Word myWord in myWords) {
        if(!myWord.isActive) {
          myWordsInList.add(myWord);
        }
      }
    }

    if(isPlayBtn) {
      floatingBtn = Icon(Icons.play_arrow_rounded, color: MyColors().green, size: 50.0);
    } else {
      floatingBtn = Icon(Icons.delete_forever, color: MyColors().red, size: 40.0);
    }

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
                    return MyColors().purple;
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
                textFieldController.clear();
                for(int i=0; i<toggleSelections.length; i++) {
                  if(i == toggleIndex) {
                    toggleSelections[i] = true;
                  } else {
                    toggleSelections[i] = false;
                  }
                }
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
                      controller: textFieldController,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.assistant_photo_outlined, color: MyColors().purple,),
                    Text(myWordsInList.length.toString(), style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: MyColors().purple)
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: ListView.builder (
                    itemCount: myWordsInList.length,
                    itemBuilder: (context, index) {
                      return WordList(false, myWordsInList[index], !isPlayBtn);
                    },
                  ),
                  onLongPress: () {
                    setState(() {
                      if(isPlayBtn) {
                        isPlayBtn = false;
                      } else {
                        isPlayBtn = true;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainBottom(context, 1),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: floatingBtn,
        onPressed: (){
          showCupertinoModalPopup(
            context: context,
            builder: (_) {
              if(isPlayBtn) {
                return playBtnClick();
              } else {
                return deleteBtnClick();
              }
            }
          );
        },
      ),
    );
  }

  CupertinoActionSheet playBtnClick() {
    return CupertinoActionSheet(
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
    );
  }

  CupertinoAlertDialog deleteBtnClick() {
    return CupertinoAlertDialog(
      title: Icon(Icons.delete_forever, size: 50.0, color: MyColors().red),
      content: Text(
        'Are you sure?',
        style: TextStyle(color: MyColors().wine, fontSize: 20.0)),
      actions: [
        CupertinoDialogAction(
          child: Text(
            'Cancel',
            style: TextStyle(color: MyColors().wine),
          ),
          onPressed: (){Navigator.pop(context);},
        ),
        CupertinoDialogAction(
          child: Text(
            'Delete',
            style: TextStyle(color: MyColors().wine, fontWeight: FontWeight.bold),
          ),
          onPressed: (){
            setState(() {
              DataStorage().removeMyWords();
              Navigator.of(context).pop();
            });
          },
        )
      ],
    );
  }
}
