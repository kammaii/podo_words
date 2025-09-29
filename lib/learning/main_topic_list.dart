import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/learning/main_word_list.dart';
import 'package:podo_words/premium/premium.dart';
import 'package:podo_words/feedback/main_feedback.dart';
import 'package:podo_words/common/words.dart';
import 'package:podo_words/user/streak.dart';
import '../common/data_storage.dart';
import '../common/my_colors.dart';
import 'package:podo_words/user/user.dart' as user;

import '../user/user.dart';

class MainTopicList extends StatelessWidget {
  const MainTopicList({Key? key}) : super(key: key);

  static const double axisSpacing = 30.0;

  double getItemHeight(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemHeight = (screenWidth - axisSpacing * 3) / 2 + axisSpacing;
    return itemHeight;
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _controller = new ScrollController();
    List<String> titles = [];
    List<Color> bgColors = [MyColors().navyLight, MyColors().mustardLight, MyColors().greenLight, MyColors().pink];
    List<Color> iconColors = [MyColors().navy, MyColors().mustard, MyColors().greenDark, MyColors().wine];
    bool isPremiumUser = DataStorage().isPremiumUser;

    titles = Words().getTitles();
    double itemHeight = getItemHeight(context);
    if (_controller.hasClients) {
      _controller.animateTo(DataStorage().lastClickedItem * itemHeight,
          duration: new Duration(seconds: 1), curve: Curves.ease);
    }

    return SafeArea(
        child: Scaffold(
      floatingActionButton: Visibility(
        visible: !isPremiumUser,
        child: GestureDetector(
          onTap: () {
            Get.to(() => Premium());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond_outlined, color: Colors.white, size: 30),
                const SizedBox(width: 5),
                Text(
                  'Get Premium',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onLongPress: DataStorage().exportMyDataForMigration,
                    child: Text(
                      'Select Topic',
                      style: TextStyle(fontSize: 20.0, color: MyColors().purple, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Get.to(MainFeedback());
                    },
                    icon: Icon(Icons.email_rounded, size: 35, color: MyColors().purple)),
                GestureDetector(
                  onTap: (){
                    Get.to(()=>Streak());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: MyColors().mustardLight,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icon/podo.png',
                          width: 25,
                          height: 25,
                          color: User().hasStudyToday() ? null : Colors.grey,
                        ),
                        Text(
                          'x ${user.User().currentStreak.toString()}',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
              child: DottedLine(
                lineThickness: 3.0,
                dashColor: Colors.grey,
                dashRadius: 3.0,
                dashGapLength: 5.0,
              ),
            ),
            Expanded(
              child: GridView.builder(
                  controller: _controller,
                  shrinkWrap: true,
                  itemCount: titles.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: axisSpacing,
                    mainAxisSpacing: axisSpacing,
                  ),
                  itemBuilder: (context, index) {
                    String imageAsset = 'assets/images/$index.png';

                    return InkWell(
                      onTap: () {
                        int clickedItem = index ~/ 2;
                        DataStorage().setLastClickedItem(clickedItem);
                        Get.to(() => MainWordList(index, bgColors[index % 4], iconColors[index % 4]));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: bgColors[index % 4], borderRadius: BorderRadius.all(Radius.circular(10.0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '$index',
                                        style: TextStyle(
                                            fontSize: 40.0, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 10.0),
                                    Hero(
                                      child: Image.asset(
                                        imageAsset,
                                        color: iconColors[index % 4],
                                        width: 50.0,
                                      ),
                                      tag: 'wordTitleImage$index',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Text(
                                      titles[index],
                                      style: TextStyle(color: iconColors[index % 4], fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    ));
  }
}
