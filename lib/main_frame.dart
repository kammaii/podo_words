import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/main_body_learning.dart';
import 'package:podo_words/main_body_review.dart';

class MainFrame extends StatefulWidget {

  @override
  _MainFrameState createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  List<Widget> pageList = [MainBodyLearning(), MainBodyReview()];
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: PageTransitionSwitcher(
        transitionBuilder: (Widget child, Animation<double> animation, Animation<double> secondaryAnimation) {
          return FadeThroughTransition(animation: animation, secondaryAnimation: secondaryAnimation, child: child);
        },
        child: pageList[pageIndex],

      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined, size: 30.0,),
              label: 'Learning'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.rate_review_outlined, size: 30.0,),
              label: 'Reviewing'
          ),
        ],
        selectedItemColor: MyColors().purple,
        currentIndex: pageIndex,
        backgroundColor: MyColors().navyLightLight,
        onTap: (int newValue){
          setState(() {
            pageIndex = newValue;
            // switch (newValue) {
            //   case 0 :
            //     setState(() {
            //       _widget = MainBodyLearning();
            //       pageIndex = 0;
            //     });
            //     break;
            //   case 1 :
            //     setState(() {
            //       _widget = MainBodyReview();
            //       pageIndex = 1;
            //     });
            //     break;
            // }
          });
        },
      )
    );
  }
}
