import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podo_words/appBar_info.dart';


class MainReview extends StatefulWidget {
  @override
  _MainReviewState createState() => _MainReviewState();
}

class _MainReviewState extends State<MainReview> {
  @override
  Widget build(BuildContext context) {
    List<String> listA = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K'];
    List<String> listB = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k'];

    return Scaffold(
      appBar: new AppBarInfo('Review').getAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.grey, width: 2.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  borderSide: BorderSide(color: Colors.red, width: 2.0),
                ),
                hintText: 'Search'
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('collect your words'),
                Text('0/0')
              ],
            ),

          ],
        ),
      ),
    );
  }
}
