import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class LearningWordsComplete extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Congratulations', textScaleFactor: 3,),
                  ],
                ),
              ),
              Expanded(
                child: CircularPercentIndicator(
                  radius: 200.0,
                  lineWidth: 10.0,
                  percent: 0.5,
                  center: new Text("50%", textScaleFactor: 2,),
                  progressColor: Colors.green,
                ),
              ),
              Text('You have learned', textScaleFactor: 2,),
              Text('200 words', textScaleFactor: 3,),
              Padding(
                padding: const EdgeInsets.all(50.0),
                child: ElevatedButton(
                    onPressed: (){},
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text('Go to Main', textScaleFactor: 2,),
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
