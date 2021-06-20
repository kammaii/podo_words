import 'package:flutter/material.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/main_body_learning.dart';
import 'package:podo_words/main_body_review.dart';

class MainFrame extends StatefulWidget {

  @override
  _MainFrameState createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  Widget _widget = MainBodyLearning();
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: _widget,
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
        currentIndex: selectedIndex,
        backgroundColor: MyColors().navyLightLight,
        onTap: (int index){
          setState(() {
            switch (index) {
              case 0 :
                setState(() {
                  _widget = MainBodyLearning();
                  selectedIndex = 0;
                });
                break;
              case 1 :
                setState(() {
                  _widget = MainBodyReview();
                  selectedIndex = 1;
                });
                break;
            }
          });
        },
      )
    );
  }

}
