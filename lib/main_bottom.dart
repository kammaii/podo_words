import 'package:flutter/material.dart';
import 'package:podo_words/main_learning.dart';
import 'package:podo_words/main_review.dart';

class MainBottom {

  BuildContext context;
  MainBottom(this.context);

  Widget getMainBottom() {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
                onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => MainLearning()));},
                child: Text('Learning')
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: ElevatedButton(
                onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => MainReview()));},
                child: Text('Reviewing')
            ),
          )
        ],
      ),
    );
  }
}