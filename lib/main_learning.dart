import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:podo_words/data_storage.dart';
import 'package:podo_words/main_bottom.dart';
import 'package:podo_words/main_learning_sliver.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/premium.dart';
import 'package:podo_words/words.dart';

class MainLearning extends StatelessWidget {

  DataStorage dataStorage = DataStorage();
  BuildContext? context;
  Widget? _widget;
  ScrollController _controller = new ScrollController();
  double axisSpacing = 30.0;

  List<Color> bgColors = [MyColors().navyLight, MyColors().mustardLight, MyColors().greenLight, MyColors().pink];
  List<Color> iconColors = [MyColors().navy, MyColors().mustard, MyColors().greenDark, MyColors().wine];

  @override
  Widget build(BuildContext context) {
    this.context = context;

    return FutureBuilder(
      future: dataStorage.init(),
      builder: (BuildContext context, AsyncSnapshot<List<Object>> snapshot) {
        if(snapshot.hasData) {
          print('데이타 있음 : $snapshot');
          _widget = widgetMainLearning(context);
          double itemHeight = getItemHeight(context);
          if(_controller.hasClients) {
            _controller.animateTo(DataStorage().lastClickedItem * itemHeight,
                duration: new Duration(seconds: 1), curve: Curves.ease);
          }

        } else {
          print('데이타 없음');
          _widget = widgetLogo();
        }
        return _widget!;
      },
    );
  }

  double getItemHeight(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemHeight = (screenWidth - axisSpacing * 3)/2 + axisSpacing;
    return itemHeight;
  }

  Widget widgetLogo() {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(child: Image.asset('assets/images/podo.png')),
          Positioned(
            bottom: 100.0,
            child: Row(
              children: [
                SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 1.0,
                  ),
                  height: 20.0,
                  width: 20.0,
                ),
                SizedBox(width: 20.0),
                Text('Loading...')
              ],
            ),
          ),
        ],
      )
    );
  }

  Widget widgetMainLearning(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                    IconButton(
                      icon: Icon(Icons.verified,
                        size: 30.0,
                        color: MyColors().red),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => Premium()));
                      }
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
                      itemCount: Words().words.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        crossAxisSpacing: axisSpacing,
                        mainAxisSpacing: axisSpacing,
                      ),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: (){
                            int clickedItem = index~/2;
                            DataStorage().setLastClickedItem(clickedItem);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MainLearningSliver(index, bgColors[index%4], iconColors[index%4])));
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
                                          child: Image.asset(
                                            'assets/images/sample_icon.png', //todo: title_[index].png
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
                                    child: Text(Words().words[index][Words.TITLE]![0],
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
      ),
      bottomNavigationBar: MainBottom(context, 0),
    );
  }
}
