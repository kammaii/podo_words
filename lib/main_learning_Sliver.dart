import 'package:flutter/material.dart';
import 'package:podo_words/main_bottom.dart';
import 'package:podo_words/words.dart';

class MainLearningSliver extends StatefulWidget {

  final int index;
  final String titleImage;

  MainLearningSliver(this.index, this.titleImage);

  @override
  _MainLearningSliverState createState() => _MainLearningSliverState();
}

class _MainLearningSliverState extends State<MainLearningSliver> {
  ScrollController scrollController;
  final double sliverAppBarHeight = 200.0;
  final double sliverAppBarMinimumHeight = 60.0;


  @override
  void initState() {
    super.initState();
    scrollController = new ScrollController();
    scrollController.addListener(() => setState(() {
      print('setState!');
    }));
  }


  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double topMargin = sliverAppBarHeight - 60.0;
    if(scrollController.hasClients) {
      print('topMargin: $topMargin');
      print('offset: ${scrollController.offset}');
      if(sliverAppBarHeight - scrollController.offset > sliverAppBarMinimumHeight) {
        topMargin -= scrollController.offset;
      } else {
        topMargin = 5.0;
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: scrollController,
              slivers: [
                sliverAppBar(),
                sliverList(),
              ],
            ),
            Positioned(
              top: topMargin,
              right: 20.0,
              child: Container(
                width: 50.0,
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: (){print('FAB clicked');},
                    child: Icon(Icons.play_arrow, size: 30.0,),
                  ),
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
    return Container(
      //height: 200.0,
      child: Hero(
          tag: 'wordTitleImage${widget.index}',
          child: Image.network(widget.titleImage, fit: BoxFit.cover,)
      ),
    );
  }

  Widget wordsList(context, index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.0),
      height: 80.0,
      child: GestureDetector(
        onPanUpdate: (detail) {
          if(detail.delta.dx > 0) {
            print('오른쪽 스와이프 : $index');
          } else {
            print('왼쪽 스와이프 : $index');
          }
        },
        child: Card(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('front $index'),
              Text('back'),
            ],
          ),
        ),
      ),
    );
  }

  sliverAppBar() {
    return SliverAppBar(
      //
      // backgroundColor: Colors.green,
      expandedHeight: sliverAppBarHeight,
      pinned: true,
      floating: true,
      snap: true,
      //flexibleSpace: Image.asset('assets/', fit: BoxFit.cover,),
      title: Text(Words().title[widget.index]),
      flexibleSpace: wordTitle(),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(sliverAppBarMinimumHeight),
        child: Text('프레뻘드'),
      ),
    );
  }

  sliverList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return wordsList(context, index);
        },
        childCount: 20,
      ),
    );
  }
}
