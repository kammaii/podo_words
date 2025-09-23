import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/common/data_storage.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/user/user.dart';

class Streak extends StatelessWidget {
  Streak({super.key});

  final List<String> compliments = [
    "Great job keeping up with your studies!",
    "You're building a strong habit — keep it going!",
    "Consistency is the key, and you're nailing it!",
    "Impressive streak! Your hard work is paying off.",
    "Every day you show up, you're getting better. Keep it up!",
    "Way to go! You're one step closer to fluency.",
    "You're on fire! Keep that learning streak alive!",
    "Proud of your commitment — you're doing fantastic!",
    "Don't stop now, you're on a roll!",
  ];

  final List<String> encouragements = [
    "Don't forget to study today — just one lesson keeps your streak alive!",
    "You're doing great — let's keep the momentum going with a quick lesson today!",
    "A little progress each day adds up. Ready for today's lesson?",
    "Your streak is waiting! Jump back in and learn something new today.",
    "Keep up the habit! Just one lesson today will make a difference.",
    "You're so close to your next milestone — start a lesson now!",
    "It’s not too late — complete a lesson before midnight!",
    "Consistency is key. Let’s get today’s learning in!",
    "You’ve come this far — let’s not skip today!",
    "Let’s keep the streak going strong. You’ve got this!",
  ];

  @override
  Widget build(BuildContext context) {
    int myWordsLength = DataStorage().myWords.length;
    bool hasStudyToday = User().hasStudyToday();
    final random = Random();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: MyColors().purple),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                Get.dialog(AlertDialog(
                  content: Text(
                      'Complete a lesson every day and collect grapes! If you finish at least one lesson before midnight, you can keep collecting grapes. Otherwise, your grape count will be reset.',
                      style: TextStyle(fontSize: 15)),
                ));
              },
              icon: Icon(Icons.info_outline_rounded),
              color: MyColors().purple)
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Image.asset(
                    'assets/icon/podo.png',
                    width: 130,
                    height: 130,
                    color: hasStudyToday ? null : Colors.grey,
                  ),
                ),
                Text('Streak Grapes', style: TextStyle(fontSize: 20, color: Colors.grey)),
                const SizedBox(height: 20),
                Text('x ${User().currentStreak.toString()}',
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)),
                const SizedBox(height: 50),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text('Best Record', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 10),
                            Text('x ${User().maxStreak.toString()}',
                                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                      VerticalDivider(),
                      Expanded(
                        child: Column(
                          children: [
                            Text('Learned Words', style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 10),
                            Text(myWordsLength.toString(),
                                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Text(
                    hasStudyToday
                        ? compliments[random.nextInt(compliments.length)]
                        : encouragements[random.nextInt(encouragements.length)],
                    style: TextStyle(fontSize: 20, color: MyColors().purple, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
