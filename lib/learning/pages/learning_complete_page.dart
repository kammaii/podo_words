import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/learning/controllers/audio_controller.dart';
import 'package:podo_words/user/user_controller.dart';
import 'package:podo_words/learning/models/word_model.dart';
import 'package:podo_words/learning/controllers/learning_controller.dart';
import 'package:podo_words/main_frame.dart';
import '../../database/database_service.dart';
import '../widgets/show_snack_bar.dart';

class LearningCompletePage extends StatefulWidget {
  const LearningCompletePage({super.key});

  @override
  State<LearningCompletePage> createState() => _LearningCompletePageState();
}

class _LearningCompletePageState extends State<LearningCompletePage> {
  final learningController = Get.find<LearningController>();
  final userController = Get.find<UserController>();

  // 비동기 작업들을 한 번만 실행하기 위한 Future
  late final Future<Map<String, int>> _completionFuture;

  @override
  void initState() {
    super.initState();
    // initState에서 학습 완료 처리 및 데이터 로딩을 시작
    _completionFuture = _processLessonCompletion();
    AudioController().playYay();
  }

  /// 학습 완료에 필요한 모든 비동기 작업을 처리하는 함수
  Future<Map<String, int>> _processLessonCompletion() async {
    try {
      // 두 비동기 작업을 병렬로 실행
      final results = await Future.wait([
        DatabaseService().getTotalWordCount(),
        userController.finishLesson(learningController.words),
      ]);

      return {
        'totalWords': results[0],
        'newWordsCount': results[1],
      };
    } catch (e, s) {
      print("💥 _processLessonCompletion에서 에러 발생: $e");
      print("STACK TRACE: \n$s");
      // 잡은 에러를 FutureBuilder로 다시 던져서 에러 UI가 표시되도록 합니다.
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SafeArea(
          child: Container(
            color: MyColors().purpleLight,
            child: Center(
              // FutureBuilder가 _completionFuture의 상태를 감시
              child: FutureBuilder<Map<String, int>>(
                future: _completionFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Text('Failed to retrieve the results.');
                  }

                  // --- 데이터 로딩 완료 후 UI 그리기 ---
                  final data = snapshot.data!;
                  final totalWords = data['totalWords']!;
                  final countNewWords = data['newWordsCount']!;

                  // 실시간으로 업데이트된 myLearnedWords 길이를 사용
                  final myWordsCount = userController.myWords.length;
                  final double percent = totalWords > 0 ? (myWordsCount / totalWords) : 0.0;
                  final List<Word> learnedWords = learningController.words;

                  return Column(
                    children: [
                      const SizedBox(height: 20.0),
                      Text('Congratulations!',
                          style: TextStyle(fontSize: 30, color: MyColors().purple, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularPercentIndicator(
                              animation: true,
                              animationDuration: 1200,
                              circularStrokeCap: CircularStrokeCap.round,
                              radius: 150.0,
                              lineWidth: 10.0,
                              percent: percent,
                              center: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${(percent * 100).toInt()}%',
                                      style: TextStyle(color: MyColors().purple, fontSize: 40)),
                                  Text('($myWordsCount / $totalWords)', style: TextStyle(color: MyColors().purple)),
                                ],
                              ),
                              progressColor: MyColors().purple,
                            ),
                            Image.asset('assets/images/confetti.png')
                          ],
                        ),
                      ),
                      Text('You have learned', style: TextStyle(color: MyColors().purple, fontSize: 20)),
                      const SizedBox(height: 10.0),
                      Text('${learnedWords.length} words',
                          style: TextStyle(color: MyColors().purple, fontWeight: FontWeight.bold, fontSize: 30)),
                      const SizedBox(height: 30.0),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: InkWell(
                          onTap: () {
                            if(countNewWords > 0) {
                              ShowSnackBar().getSnackBar(context, '$countNewWords new words are added to your review list');
                            }
                            // isFirstLesson 로직은 필요 시 userController에서 관리 가능
                            Get.offAll(() => MainFrame());
                          },
                          child: Material(
                            color: MyColors().purple,
                            borderRadius: BorderRadius.circular(30.0),
                            elevation: 5.0,
                            child: const Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Center(
                                  child: Text('Go to main', style: TextStyle(color: Colors.white, fontSize: 20))),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}