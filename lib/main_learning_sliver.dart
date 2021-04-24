import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:podo_words/check_active_words.dart';
import 'package:podo_words/learning_words.dart';
import 'package:podo_words/main_bottom.dart';
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

    double topMargin = sliverAppBarHeight - 60.0;
    if(scrollController.hasClients) {
      if(sliverAppBarHeight - scrollController.offset > sliverAppBarMinimumHeight) {
        topMargin -= scrollController.offset;
      } else {
        topMargin = 5.0;
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
              top: topMargin,
              child: Container(
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
                        Text('50', style: TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    SizedBox(width: 40.0,),
                    Column(
                      children: [
                        Text('Active', style: TextStyle(color: Colors.white, fontSize: 17.0),),
                        Text('50', style: TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    SizedBox(width: 50.0,),
                    Container(
                      width: 50.0,
                      child: FittedBox(
                        child: FloatingActionButton(
                          onPressed: (){
                            print('FAB clicked');
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LearningWords(widget.index)));},
                          child: Icon(Icons.play_arrow, size: 30.0,),
                        ),
                      ),
                    ),
                  ],
                ),
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
            rightSwipeWidget: Icon(Icons.add),
            leftSwipeWidget: Icon(Icons.arrow_back),
            child: widget,
          );
        }
      ),
    );
  }


  sliverAppBar() {
    return SliverAppBar(
      backgroundColor: widget.color,
      expandedHeight: sliverAppBarHeight,
      pinned: true,
      floating: true,
      snap: true,
      stretch: true,
      stretchTriggerOffset: sliverAppBarStretchOffset,
      onStretchTrigger: (){
        print('스트레치 트리거');
        //Navigator.pop(context);
        //todo: 이전 페이지로 넘어가기 안됨
        return;
      },
      //flexibleSpace: Image.asset('assets/', fit: BoxFit.cover,),
      title: Text(words.title),
      flexibleSpace: wordTitle(),
    );
  }

  sliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return wordsList(context, index);
        },
        childCount: words.getWords(widget.index).front.length,
      ),
    );
  }
}
