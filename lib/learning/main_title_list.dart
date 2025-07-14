import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/learning/main_word_list.dart';
import 'package:podo_words/premium/premium.dart';
import 'package:podo_words/feedback/main_feedback.dart';
import 'package:podo_words/common/words.dart';
import '../common/data_storage.dart';
import '../common/my_colors.dart';

class MainTitleList extends StatelessWidget {
  const MainTitleList({Key? key}) : super(key: key);

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
      child: SafeArea(
          child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Select Title',
                  style: TextStyle(fontSize: 20.0, color: MyColors().purple, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                  onPressed: () {
                    Get.to(MainFeedback());
                  },
                  icon: Icon(Icons.email, size: 35, color: MyColors().purple)),
              Visibility(
                visible: !isPremiumUser,
                child: IconButton(
                    icon: Image.asset('assets/images/premium.png', width: 40),
                    onPressed: () {
                      Get.to(Premium());
                    }),
              )
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
      )),
    );
  }
}
