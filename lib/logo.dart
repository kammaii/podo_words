import 'package:flutter/material.dart';
import 'package:podo_words/data_storage.dart';
import 'package:podo_words/main_learning.dart';

class Logo extends StatelessWidget {

  DataStorage dataStorage;

  @override
  Widget build(BuildContext context) {
    dataStorage = DataStorage();

    return Scaffold(
      body: FutureBuilder(
        future: dataStorage.initData(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if(snapshot.hasData) {
            print('데이타 있음');

          } else {
            print('데이타 없음');
          }
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Future.delayed(const Duration(seconds: 0), () { //todo: 3초로 수정하기
              Navigator.push(context, MaterialPageRoute(builder: (context) => MainLearning()));
            });
          });
          return Stack(
            alignment: Alignment.center,
            children: [
              Center(child: Image.asset('images/podo.png')),
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
          );
        },
      ),
    );
  }
}
