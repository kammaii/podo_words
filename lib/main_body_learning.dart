import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:podo_words/premium.dart';
import 'package:podo_words/words.dart';
import 'data_storage.dart';
import 'main_learning_sliver.dart';
import 'my_colors.dart';

class MainBodyLearning extends StatelessWidget {
  const MainBodyLearning({Key? key}) : super(key: key);

  static const List<int> freeLesson = [0,3,5,6,9,12,15,20,22,24,28,34,36,44,47];
  static const double axisSpacing = 30.0;

  double getItemHeight(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemHeight = (screenWidth - axisSpacing * 3)/2 + axisSpacing;
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
    if(_controller.hasClients) {
      _controller.animateTo(DataStorage().lastClickedItem * itemHeight,
          duration: new Duration(seconds: 1), curve: Curves.ease);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
      child: SafeArea(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select word title',
                    style: TextStyle(
                        fontSize: 20.0,
                        color: MyColors().purple,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  Visibility(
                    visible: !isPremiumUser,
                    child: IconButton(
                        icon: Icon(Icons.verified,
                            size: 30.0,
                            color: MyColors().red),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => Premium()));
                        }
                    ),
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: axisSpacing,
                      mainAxisSpacing: axisSpacing,
                    ),
                    itemBuilder: (context, index) {
                      String imageAsset;
                      // todo: 각 레슨 타이틀에 맞는 아이콘 설정하기
                      // todo: 테스트용
                      if(DataStorage().isPremiumUser) {
                        imageAsset = 'assets/images/sample_icon.png';
                      } else {
                        if(freeLesson.contains(index)) {
                          imageAsset = 'assets/images/sample_icon.png';
                        } else {
                          imageAsset = 'assets/images/sample_icon_lock.png';
                        }
                      }

                      return InkWell(
                        onTap: (){
                          int clickedItem = index~/2;
                          DataStorage().setLastClickedItem(clickedItem);

                          if(DataStorage().isPremiumUser || freeLesson.contains(index)) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MainLearningSliver(index, bgColors[index % 4], iconColors[index % 4])));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Premium()));
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: bgColors[index % 4],
                              borderRadius: BorderRadius.all(Radius.circular(10.0))
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text('$index',
                                          style: TextStyle(
                                              fontSize: 40.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Hero(
                                        child: Image.asset(imageAsset, //todo: title_[index].png
                                          color: Colors.white,
                                          width: 50.0,
                                        ),
                                        tag: 'wordTitleImage$index',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(titles[index],
                                    textScaleFactor: 1.5,
                                    style: TextStyle(color: iconColors[index % 4]),
                                  ),
                                ),
                              )
                            ],
                          ) ,
                        ),
                      );
                    }
                ),
              ),
            ],
          )
      ),
    );
  }
}
