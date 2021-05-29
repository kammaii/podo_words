import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:podo_words/data_storage.dart';
import 'package:podo_words/main_bottom.dart';
import 'package:podo_words/main_learning_sliver.dart';
import 'package:podo_words/my_colors.dart';
import 'package:podo_words/words.dart';

class MainLearning extends StatelessWidget {

  DataStorage dataStorage = DataStorage();
  BuildContext? context;
  Widget? _widget;

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
          _widget = widgetMainLearning();

        } else {
          print('데이타 없음');
          _widget = widgetLogo();
        }
        return _widget!;
      },
    );
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

  Widget widgetMainLearning() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
        child: SafeArea(
            child: Column(
              children: [
                Container(
                  child: Text(
                    'Select word title',
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.deepPurpleAccent,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: DottedLine(
                    lineThickness: 3.0,
                    dashColor: Colors.grey,
                    lineLength: 200.0,
                    dashRadius: 3.0,
                    dashGapLength: 5.0,
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: Words().words.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        crossAxisSpacing: 30.0,
                        mainAxisSpacing: 30.0,
                      ),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => MainLearningSliver(index, bgColors[index%4])));},
                          child: Container(
                            color: bgColors[index % 4],
                            child: Column(
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
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: Row(
                                      children: [
                                        Text(Words().words[index][Words.TITLE]![0], style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.deepPurpleAccent
                                        ),)
                                      ],
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
      bottomNavigationBar: MainBottom(context!, 0),
    );
  }
}
