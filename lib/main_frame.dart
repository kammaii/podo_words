import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/learning/pages/topic_list_page.dart';
import 'package:podo_words/review/review_list_page.dart';

class MainFrame extends StatefulWidget {

  @override
  _MainFrameState createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  List<Widget> pageList = [TopicListPage(), ReviewListPage()];
  int pageIndex = 0;
  bool shouldShowReview = Get.arguments ?? false;

  void showReviewRequest() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }

  @override
  void initState() {
    super.initState();
    if(shouldShowReview) {
      print('리뷰요청');
      showReviewRequest();
    }
  }

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
          });
        },
      )
    );
  }
}
