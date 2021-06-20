import 'package:flutter/material.dart';
import 'data_storage.dart';
import 'main_frame.dart';
import 'my_colors.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DataStorage dataStorage = DataStorage();
    bool isLoading = true;

    return FutureBuilder(
      future: dataStorage.init(),
      builder: (BuildContext context, AsyncSnapshot<List<Object>> snapshot) {
        if(snapshot.hasData) {
          print('데이타 있음 : $snapshot');
          isLoading = false;
        }
        return Scaffold(
            body: Stack(
              alignment: Alignment.center,
              children: [
                Center(child: Image.asset('assets/images/podo.png')),
                Positioned(
                  bottom: 100.0,
                  child: Column(
                    children: [
                      Visibility(
                        visible: isLoading,
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
                      Visibility(
                        visible: !isLoading,
                        child: InkWell(
                          onTap: (){
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MainFrame()));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: MyColors().purple,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                              child: Center(
                                  child: Text('Start', textScaleFactor: 1.5, style: TextStyle(color: Colors.white),
                                  )
                              ),
                            ),
                          ),
                        ),
                      ),
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
