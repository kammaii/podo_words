import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:podo_words/check_active_words.dart';
import 'package:podo_words/learning_words.dart';
import 'package:podo_words/main_bottom.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/wordListItem.dart';
import 'package:podo_words/words.dart';
import 'package:swipe_to/swipe_to.dart';

class MainLearningSliver extends StatefulWidget {

  final int index;
  final Color color;

  MainLearningSliver(this.index, this.color);

  @override
  _MainLearningSliverState createState() => _MainLearningSliverState();
}

class _MainLearningSliverState extends State<MainLearningSliver> {
  ScrollController scrollController;
  static const double sliverAppBarHeight = 200.0;
  static const double sliverAppBarMinimumHeight = 60.0;
  static const double sliverAppBarStretchOffset = 100.0;
  double sliverAppBarStretchOffsetSave;
  static const String KEY_LESSON_WORDS = 'lessonWords';

  Words words;
  CheckActiveWords checkActiveWords;
  Future<List<bool>> activeList;


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
    checkActiveWords = CheckActiveWords(words.front);
    activeList = checkActiveWords.getBoolList(KEY_LESSON_WORDS);

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
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text('Total', style: TextStyle(color: Colors.white, fontSize: 17.0),),
                        Text(words.front.length.toString(), style: TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    SizedBox(width: 40.0,),
                    Column(
                      children: [
                        Text('Active', style: TextStyle(color: Colors.white, fontSize: 17.0),),
                        FutureBuilder(
                          future: activeList,
                          builder: (BuildContext context, AsyncSnapshot<List<bool>> snapshot) {                              int count = 0;
                          int activeWordCount = 0;
                          if(snapshot.hasData) {
                              for (bool b in snapshot.data) {
                                if (b) {
                                  activeWordCount ++;
                                }
                              }
                            }
                            return Text(
                            activeWordCount.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
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
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: MainBottom(context).getMainBottom(),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      height: 80.0,
      child: FutureBuilder <List<bool>> (
        future: activeList,
        builder: (BuildContext context, AsyncSnapshot<List<bool>> snapshot) {
          Widget widget;
          if(snapshot.hasData) {
            print('snapshop has data!');
            widget = WordListItem(words.front[index], words.back[index], snapshot.data[index]);
          } else if(snapshot.hasError){
            print('snapshop has error!');
          } else {
            print('snapshop has no data!');
            widget = CircularProgressIndicator();
          }
          return SwipeTo(
            onLeftSwipe: () {
              setState(() {
                checkActiveWords.addInActiveWord(KEY_LESSON_WORDS, words.front[index]);
              });
            },
            onRightSwipe: () {
              setState(() {
                checkActiveWords.removeInActiveWord(KEY_LESSON_WORDS, words.front[index]);
              });
            },
            rightSwipeWidget: Container(
              padding: EdgeInsets.all(10.0),
              child: Icon(Icons.check, color: Colors.blue,),
              color: Colors.greenAccent,
            ),
            leftSwipeWidget: Container(
              padding: EdgeInsets.all(10.0),
              child: Icon(Icons.cancel_outlined, color: MyColors().red,),
              color: MyColors().pink,
            ),            child: widget,
          );
        }
      ),
    );
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
      title: Text(words.title, style: TextStyle(
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
          childCount: words.getWords(widget.index).front.length,
        ),
      ),
    );
  }
}
