import 'package:flutter/material.dart';
import 'package:podo_words/main_learning.dart';
import 'package:podo_words/main_review.dart';
import 'package:podo_words/my_colors.dart';

class MainBottom extends StatefulWidget {

  final BuildContext context;
  final int selectedIndex;
  MainBottom(this.context, this.selectedIndex);

  @override
  _MainBottomState createState() => _MainBottomState();
}

class _MainBottomState extends State<MainBottom> {

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
      currentIndex: widget.selectedIndex,
      backgroundColor: MyColors().navyLightLight,
      onTap: (int index){
        setState(() {
          switch (index) {
            case 0 :
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MainLearning()), (Route<dynamic> route) => false);
              break;
            case 1 :
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => MainReview()), (Route<dynamic> route) => false);
              break;
          }
        });
      },
    );
  }
}
