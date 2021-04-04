import 'package:flutter/material.dart';

class MainLearningSliver extends StatelessWidget {

  final int index;
  final String titleImage;

  MainLearningSliver(this.index, this.titleImage);


  Widget wordTitle() {
    return Container(
      height: 200.0,
      child: Hero(
          tag: 'wordTitleImage$index',
          child: Image.network(titleImage)
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            sliverAppBar(),
            sliverList(),
          ],
        ),
      ),
    );
  }

  sliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.green,
      expandedHeight: 200.0,
      pinned: true,
      floating: true,
      snap: true,
      //flexibleSpace: Image.asset('assets/', fit: BoxFit.cover,),
      title: Text('Word title'),
      flexibleSpace: wordTitle(),
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
