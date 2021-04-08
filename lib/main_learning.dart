import 'package:flutter/material.dart';
import 'package:podo_words/main_bottom.dart';
import 'package:podo_words/main_learning_Sliver.dart';
import 'package:podo_words/wordTitles.dart';

class MainLearning extends StatelessWidget {

  final WordTitles wordTitles = new WordTitles();


  @override
  Widget build(BuildContext context) {

    List<String> title = wordTitles.getTitle();
    List<String> titleImage = wordTitles.getTitleImage();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(10.0),
                  child: Text('Select word title')
              ),
              Expanded(
                child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: title.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount (
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => MainLearningSliver(index, titleImage[index])));},
                        child: Container(
                          color: Colors.yellow,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$index'),
                              Expanded(
                                child: Hero(
                                  child: Image.network(titleImage[index]),
                                  tag: 'wordTitleImage$index',
                                ),
                              ),
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
