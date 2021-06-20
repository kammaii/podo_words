import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'data_storage.dart';
import 'main_frame.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DataStorage dataStorage = DataStorage();

    return FutureBuilder(
      future: dataStorage.init(),
      builder: (BuildContext context, AsyncSnapshot<List<Object>> snapshot) {
        if(snapshot.hasData) {
          print('데이타 있음 : $snapshot');
          SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainFrame()));
          });
        }
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
      },
    );
  }
}
