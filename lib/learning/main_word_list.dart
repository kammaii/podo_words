import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:podo_words/common/ads_controller.dart';
import 'package:podo_words/common/data_storage.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/common/show_snack_bar.dart';
import 'package:podo_words/common/word.dart';
import 'package:podo_words/common/words.dart';
import 'package:podo_words/learning/learning_frame.dart';
import 'package:podo_words/premium/premium.dart';

import '../common/word_list.dart';

class MainWordList extends StatefulWidget {
  final int index;
  final Color bgColor;
  final Color iconColor;

  MainWordList(this.index, this.bgColor, this.iconColor);

  @override
  MainWordListState createState() => MainWordListState();
}

class MainWordListState extends State<MainWordList> {
  ScrollController scrollController = new ScrollController();
  double sliverAppBarHeight = 200.0;
  double sliverAppBarMinimumHeight = 60.0;
  double sliverAppBarStretchOffset = 100.0;

  List<Word> words = [];
  int activeWordCount = 0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  runLesson({required bool shouldShowAds}) {
    List<Word> activeWords = [];
    for (int i = 0; i < words.length; i++) {
      if (words[i].isActive) {
        activeWords.add(words[i]);
      }
    }
    Get.to(LearningFrame(activeWords), arguments: shouldShowAds);
  }

  showDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        content: Text(
          'Would you like to watch an ad to unlock this lesson?',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: MyColors().purple),
                  onPressed: () {
                    Get.back();
                    AdsController().showRewardAdAndStartLesson((){
                      runLesson(shouldShowAds: true);
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text('Yes', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: TextButton(
              onPressed: () {
                Get.to(Premium());
              },
              child: Text('Explore Premium', style: TextStyle(color: MyColors().purple)),
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    words = Words().getWords(widget.index);
    List<String> fronts = [];
    for (int i = 0; i < words.length; i++) {
      fronts.add(words[i].front);
    }

    activeWordCount = 0;

    for (Word word in words) {
      if (word.isActive) {
        activeWordCount++;
      }
    }

    double topMargin = sliverAppBarHeight - 30.0;
    double topMarginPlayBtn = sliverAppBarHeight - 20.0;

    if (scrollController.hasClients) {
      if (sliverAppBarHeight - scrollController.offset > sliverAppBarMinimumHeight) {
        topMargin -= scrollController.offset;
        topMarginPlayBtn -= scrollController.offset;
      } else {
        topMargin = -100.0;
        topMarginPlayBtn = 5.0;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomScrollView(
              physics: BouncingScrollPhysics(),
              controller: scrollController,
              slivers: [
                sliverAppBar(),
                sliverList(),
              ],
            ),
            Positioned(
              width: MediaQuery.of(context).size.width,
              top: topMargin,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30.0),
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: widget.iconColor,
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(color: Colors.white, fontSize: 17.0),
                        ),
                        Text(
                          words.length.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 40.0,
                    ),
                    Column(
                      children: [
                        Text(
                          'Active',
                          style: TextStyle(color: Colors.white, fontSize: 17.0),
                        ),
                        Text(
                          activeWordCount.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: topMarginPlayBtn,
              right: 60.0,
              child: FloatingActionButton(
                elevation: 10,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: widget.iconColor,
                  size: 50.0,
                ),
                onPressed: () {
                  if (activeWordCount >= 4) {
                    if (!DataStorage().isPremiumUser && DataStorage().myWords.isNotEmpty) {
                      print('무료 유저');
                      if(kReleaseMode) {
                        showDialog();
                      } else {
                        runLesson(shouldShowAds: true);
                      }
                    } else {
                      print('광고 대상 아님');
                      runLesson(shouldShowAds: false);
                    }
                  } else {
                    ShowSnackBar().getSnackBar(context, 'It needs more than 4 words to start learning.');
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget wordTitle() {
    return FlexibleSpaceBar(
      background: Stack(
        children: [
          Positioned(
            child: Hero(
                tag: 'wordTitleImage${widget.index}',
                child: Image.asset(
                  'assets/images/${widget.index}.png',
                  width: 250.0,
                  color: Colors.white,
                )),
            bottom: -50.0,
            right: -50.0,
          )
        ],
      ),
      stretchModes: [StretchMode.zoomBackground, StretchMode.fadeTitle, StretchMode.blurBackground],
    );
  }

  Widget getWordList(index) {
    return WordList(true, words[index], false, widget.iconColor, widget.bgColor);
  }

  sliverAppBar() {
    return SliverAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded),
        color: widget.iconColor,
        onPressed: () {
          Get.back();
        },
      ),
      backgroundColor: widget.bgColor,
      expandedHeight: sliverAppBarHeight,
      pinned: true,
      stretch: true,
      title: Text(
        Words().getTitles()[widget.index],
        style: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
          color: widget.iconColor,
        ),
      ),
      flexibleSpace: wordTitle(),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(10.0),
        child: Text(''),
      ),
    );
  }

  sliverList() {
    return SliverPadding(
      padding: EdgeInsets.only(top: 60.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                    child: Text('Swipe left/right to pick a word to learn',
                        style: TextStyle(color: widget.iconColor)),
                  ),
                  getWordList(index),
                ],
              );
            } else {
              return getWordList(index);
            }
          },
          childCount: words.length,
        ),
      ),
    );
  }
}
