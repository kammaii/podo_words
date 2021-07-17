import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:podo_words/learning_words.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/show_snack_bar.dart';
import 'package:podo_words/word.dart';
import 'package:podo_words/word_list.dart';
import 'package:podo_words/words.dart';


class MainLearningSliver extends StatefulWidget {

  final int index;
  final Color bgColor;
  final Color iconColor;

  MainLearningSliver(this.index, this.bgColor, this.iconColor);

  @override
  MainLearningSliverState createState() => MainLearningSliverState();
}

class MainLearningSliverState extends State<MainLearningSliver> {
  ScrollController scrollController = new ScrollController();
  double sliverAppBarHeight = 200.0;
  double sliverAppBarMinimumHeight = 60.0;
  double sliverAppBarStretchOffset = 100.0;

  List<Word> words = [];
  int activeWordCount = 0;


  @override
  void initState() {
    super.initState();
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

    activeWordCount = 0;

    for(Word word in words) {
      if(word.isActive) {
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
                        Text('Total', style: TextStyle(color: Colors.white, fontSize: 17.0),),
                        Text(words.length.toString(), style: TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),),
                      ],
                    ),
                    SizedBox(width: 40.0,),
                    Column(
                      children: [
                        Text('Active', style: TextStyle(color: Colors.white, fontSize: 17.0),),
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
                backgroundColor: Colors.white,
                child: Icon(Icons.play_arrow_rounded, color: MyColors().green, size: 50.0,),
                onPressed: () {
                  if(activeWordCount >= 4) {
                    List<Word> activeWords = [];
                    for (int i = 0; i < words.length; i++) {
                      if (words[i].isActive) {
                        activeWords.add(words[i]);
                      }
                    }
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => LearningWords(activeWords)));

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
    return FlexibleSpaceBar (
      background: Stack(
        children: [
          Positioned(
            child: Hero(
              tag: 'wordTitleImage${widget.index}',
              child: Image.asset(
                'assets/images/${widget.index}.png',
                width: 250.0,
                color: Colors.white,)
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
    return WordList(true, words[index], false);
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
      backgroundColor: widget.bgColor,
      expandedHeight: sliverAppBarHeight,
      pinned: true,
      stretch: true,
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
