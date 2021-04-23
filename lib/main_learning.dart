import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:podo_words/main_bottom.dart';
import 'package:podo_words/main_learning_sliver.dart';
import 'package:podo_words/words.dart';

class MainLearning extends StatelessWidget {

  //final WordTitles wordTitles = new WordTitles();

  @override
  Widget build(BuildContext context) {
    Words words = new Words();
    List<Color> colors = [Color(0xffE0E3FF), Color(0xffFFEAAC), Color(0xffC4F6EF), Color(0xffFFDBDD)];


    //List<String> title = wordTitles.getTitle();
    //List<String> titleImage = wordTitles.getTitleImage();

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
                    itemCount: words.getTitles().length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 30.0,
                      mainAxisSpacing: 30.0,
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => MainLearningSliver(index, colors[index%4])));},
                        child: Container(
                          color: colors[index % 4],
                          child: Column(
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text('$index',
                                        style: TextStyle(
                                          fontSize: 40.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Hero(
                                        child: Icon(
                                          Icons.people,
                                          color: Colors.black,
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
                                      Text('title', style: TextStyle(
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
      bottomNavigationBar: MainBottom(context).getMainBottom(),
    );
  }
}
