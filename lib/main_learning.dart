import 'package:flutter/material.dart';
import 'package:podo_words/words.dart';

class MainLearning extends StatelessWidget {
  
  final List<String> title = Words().getTitle();

  @override
  Widget build(BuildContext context) {
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
                      return GestureDetector(
                        onTap: (){print('GridView clicked : $index');},
                        child: Container(
                          color: Colors.yellow,
                          child: Center(
                            child: FlutterLogo()),
                        ),
                      );
                    }
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
