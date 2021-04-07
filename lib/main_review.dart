import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:podo_words/appBar_info.dart';
import 'package:podo_words/main_bottom.dart';
import 'package:podo_words/wordListItem.dart';


class MainReview extends StatefulWidget {
  @override
  _MainReviewState createState() => _MainReviewState();
}

class _MainReviewState extends State<MainReview> {
  @override
  Widget build(BuildContext context) {
    List<String> listA = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N'];
    List<String> listB = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n'];
    List<bool> toggleBtnSelections = List.generate(3, (_) => false);

    return Scaffold(
      body: SafeArea(
        child: Padding(
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('0 words'),
                    ToggleButtons(
                      children: <Widget>[
                        Icon(Icons.ac_unit),
                        Icon(Icons.call),
                        Icon(Icons.cake),
                      ],
                      onPressed: (int index) {
                        print('index: $index');
                        setState(() {
                          for (int i=0; i<toggleBtnSelections.length; i++) {
                            if (i == index) {
                              toggleBtnSelections[i] = true;
                            } else {
                              toggleBtnSelections[i] = false;
                            }
                          }
                          switch (index) {
                            case 0 :
                              //todo: inactive만 표시
                              break;

                            case 1 :
                            //todo: 모두 표시
                              break;

                            case 2 :
                            //todo: active만 표시
                              break;
                          }
                        });
                        print('selection : $toggleBtnSelections');
                      },
                      isSelected: toggleBtnSelections,
                      color: Colors.grey,
                      selectedColor: Colors.purple,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated (
                  shrinkWrap: true,
                  itemCount: listA.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: WordListItem(listA[index], listB[index]),
                      onTap: () {
                        print('item tapped : $index');
                      },
                      onLongPress: () {
                        print('long pressed : $index');
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MainBottom(context).getMainBottom()
    );
  }
}
