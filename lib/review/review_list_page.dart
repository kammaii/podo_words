import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/learning/pages/learning_page.dart';
import 'package:podo_words/review/review_flashcard_page.dart';
import 'package:podo_words/learning/models/word.dart';
import 'package:podo_words/learning/widgets/word_list.dart';
import '../database/local_storage_service.dart';
import '../learning/widgets/show_snack_bar.dart';



class ReviewListPage extends StatefulWidget {
  @override
  ReviewPageState createState() => ReviewPageState();
}

class ReviewPageState extends State<ReviewListPage> {

  late List<Word> myWords;
  late List<Word> myWordsInList;
  List<bool> toggleSelections = [true, false, false];
  String searchInput = "";

  bool isPlayBtn = true;
  late Widget floatingBtn;

  final textFieldController = TextEditingController();
  final focusNode = FocusNode();

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
    myWords = LocalStorageService().myWords;
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
                shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    )
                ),
                backgroundColor: WidgetStateProperty.resolveWith((_) {
                  if(toggleSelections[toggleIndex]) {
                    return MyColors().purple;
                  } else {
                    return Colors.white;
                  }
                }),
                foregroundColor: WidgetStateProperty.resolveWith((_) {
                  if(toggleSelections[toggleIndex]) {
                    return Colors.white;
                  } else {
                    return MyColors().navyLight;
                  }
                }),
                side: WidgetStateProperty.resolveWith((_) {
                  return BorderSide(color: Colors.transparent);
                })
            ),
            child: Icon(icon),
            onPressed: (){
              setState(() {
                textFieldController.clear();
                focusNode.unfocus();
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
                      focusNode: focusNode,
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
                  children: [
                    Expanded(child: Text('- Long press a word to delete.', style: TextStyle(color: MyColors().purple, fontSize: 15))),
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
                      return WordList(word: myWordsInList[index], isActive: true, isDeleteMode: !isPlayBtn, fontColor: MyColors().purple);
                    },
                  ),
                  onLongPress: () {
                    focusNode.unfocus();
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: floatingBtn,
        onPressed: (){
          focusNode.unfocus();
          if(myWords.length > 0) {
            showCupertinoModalPopup(
                context: context,
                builder: (_) {
                  if (isPlayBtn) {
                    return playBtnClick();
                  } else {
                    return deleteBtnClick();
                  }
                }
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: MyColors().pink,
                  content: Text(
                    'It needs more than 4 words to start learning.',
                    style: TextStyle(color: MyColors().red, fontWeight: FontWeight.bold, fontSize: 18.0),
                  ),
                )
            );
          }
        },
      ),
    );
  }

  CupertinoActionSheet playBtnClick() {
    bool shouldShowAds = !LocalStorageService().isPremiumUser;
    List<Word> activeWords = [];
    for(Word word in myWords) {
      if(word.isActive) {
        activeWords.add(word);
      }
    }

    return CupertinoActionSheet(
      message: Text('Select review mode', style: TextStyle(fontSize: 20)),
      actions: [
        CupertinoActionSheetAction(
          child: Text('quiz'),
          onPressed: () {
            Get.back();
            if(activeWords.length >= 4) {
              Get.to(() => LearningPage(), arguments: {
                'shouldShowAds' : shouldShowAds,
                'words' : activeWords,
              });
            } else {
              ShowSnackBar().getSnackBar(context, 'It needs more than 4 words to start learning.');
            }
          },
        ),
        CupertinoActionSheetAction(
          child: Text('flash card'),
          onPressed: (){
            Get.back();
            Get.to(() => ReviewFlashCardPage(activeWords), arguments: shouldShowAds);
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text('cancel'),
        onPressed: (){Get.back();},
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
          onPressed: (){Get.back();},
        ),
        CupertinoDialogAction(
          child: Text(
            'Delete',
            style: TextStyle(color: MyColors().wine, fontWeight: FontWeight.bold),
          ),
          onPressed: (){
            setState(() {
              LocalStorageService().removeMyWords();
              Get.back();;
            });
          },
        )
      ],
    );
  }
}
