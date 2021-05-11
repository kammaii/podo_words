import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:podo_words/data_storage.dart';
import 'package:podo_words/learning_words.dart';
import 'package:podo_words/main_bottom.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/word.dart';
import 'package:podo_words/wordList.dart';
import 'package:podo_words/words.dart';

class MainLearningSliver extends StatefulWidget {

  final int index;
  final Color color;

  MainLearningSliver(this.index, this.color);

  @override
  MainLearningSliverState createState() => MainLearningSliverState();
}

class MainLearningSliverState extends State<MainLearningSliver> {
  ScrollController scrollController;
  double sliverAppBarHeight = 200.0;
  double sliverAppBarMinimumHeight = 60.0;
  double sliverAppBarStretchOffset = 100.0;
  double sliverAppBarStretchOffsetSave;

  List<Word> words;
  List<bool> activeList;
  int activeWordCount;


  @override
  void initState() {
    super.initState();
    scrollController = new ScrollController();
    scrollController.addListener(() => setState(() {
    }));
  }


  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    words = Words().getWords(widget.index);
    List<String> fronts = [];
    for(int i=0; i<words.length; i++) {
      fronts.add(words[i].front);
    }
    activeList = DataStorage().getBoolList(fronts);
    activeWordCount = 0;

    for(bool b in activeList) {
      if(b) {
        activeWordCount ++;
      }
    }

    double topMargin = sliverAppBarHeight - 30.0;
    double topMarginPlayBtn = sliverAppBarHeight - 25.0;

    if(scrollController.hasClients) {
      if (sliverAppBarHeight - scrollController.offset > sliverAppBarMinimumHeight ) {
        topMargin -= scrollController.offset;
        topMarginPlayBtn -= scrollController.offset;

      } else {
        topMargin = -70.0;
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
                height: 70.0,
                margin: EdgeInsets.symmetric(horizontal: 30.0),
                padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                decoration: BoxDecoration(
                  color: MyColors().navy,
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text('Total', style: TextStyle(color: Colors.white, fontSize: 17.0),),
                        Text(words.length.toString(), style: TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    SizedBox(width: 40.0,),
                    Column(
                      children: [
                        Text('Active', style: TextStyle(color: Colors.white, fontSize: 17.0),),
                        Text(
                          activeWordCount.toString(), //todo: 카운팅 코드 추가
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
                backgroundColor: Colors.white,
                child: Icon(Icons.play_arrow_rounded, color: MyColors().green, size: 50.0,),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LearningWords(widget.index)));
                  //todo: 활성화된 단어 플래시카드에 추가하기 -> 단어학습 완료 시점으로 옮길 것
                  for(int i=0; i<activeList.length; i++) {
                    Word newMyWord = words[i];
                    if(activeList[i] && !DataStorage().myWords.contains(newMyWord)) {
                      String front = words[i].front;
                      String back = words[i].back;
                      String image = words[i].image;
                      DataStorage().myWordsJson.add(json.encode(Word(front, back, image).toJson()));
                      DataStorage().myWords.add(words[i]);
                    }
                  }
                  DataStorage().setStringList(DataStorage.KEY_MY_WORDS, DataStorage().myWordsJson);
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: MainBottom(context, 0),
    );
  }

  Widget wordTitle() {
    return FlexibleSpaceBar (
      background: Stack(
        children: [
          Positioned(
            child: Hero(
              tag: 'wordTitleImage${widget.index}',
              child: Icon(Icons.people,size: 250.0, color: Colors.white,)
            ),
            bottom: -50.0,
            right: -50.0,
          )
        ],
      ),
      stretchModes: [
        StretchMode.zoomBackground,
        StretchMode.fadeTitle,
        StretchMode.blurBackground
      ],
    );
  }

  Widget wordsList(context, index) {
    return WordList(true, words[index], activeList[index]);
  }


  sliverAppBar() {
    return SliverAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded),
        color: MyColors().purple,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: widget.color,
      expandedHeight: sliverAppBarHeight,
      pinned: true,
      stretch: true,
      stretchTriggerOffset: sliverAppBarStretchOffset,
      onStretchTrigger: (){
        print('스트레치 트리거');
        //Navigator.pop(context);
        //todo: 이전 페이지로 넘어가기 안됨
        return;
      },
      title: Text(Words().getTitles()[widget.index], style: TextStyle(
        fontSize: 25.0,
        fontWeight: FontWeight.bold,
        color: MyColors().purple
      ),),
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
            return wordsList(context, index);
          },
          childCount: words.length,
        ),
      ),
    );
  }
}
