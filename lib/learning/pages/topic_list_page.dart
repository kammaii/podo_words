import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/database/local_storage_service.dart';
import 'package:podo_words/learning/controllers/image_controller.dart';
import 'package:podo_words/learning/models/topic_model.dart';
import 'package:podo_words/feedback/feedback_page.dart';
import 'package:podo_words/learning/pages/word_list_page.dart';
import 'package:podo_words/premium/premium_page.dart';
import 'package:podo_words/streak/streak_page.dart';
import 'package:podo_words/user/user_controller.dart';
import 'package:podo_words/user/user_model.dart';
import '../../common/my_colors.dart';
import '../../database/database_service.dart';

class TopicListPage extends StatefulWidget {
  const TopicListPage({Key? key}) : super(key: key);

  @override
  State<TopicListPage> createState() => _TopicListPageState();
}

class _TopicListPageState extends State<TopicListPage> {
  final double _axisSpacing = 30.0;
  final DatabaseService _dbService = DatabaseService();
  final ScrollController _scrollController = ScrollController();

  // 상태 관리 변수
  List<Topic> _topics = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMore = true;
  final userController = Get.find<UserController>();
  final ImageController imageService = ImageController();

  @override
  void initState() {
    super.initState();
    _fetchTopics(); // 첫 데이터 로드

    // 스크롤 리스너 추가
    _scrollController.addListener(() {
      // 스크롤이 맨 끝에 도달했고, 더 불러올 데이터가 있으며, 로딩 중이 아닐 때
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 && // 맨 끝에서 200px 전에 미리 로드
          _hasMore &&
          !_isLoading) {
        _fetchTopics();
      }
    });

    // 첫 프레임이 렌더링된 후에 딱 한 번만 스크롤 위치 복원
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // controller가 ScrollView에 연결되었고, 저장된 위치가 있을 때만 실행
      if (_scrollController.hasClients && LocalStorageService().lastClickedItem > 0) {
        final double itemHeight = getItemHeight(context);
        _scrollController.animateTo(
          LocalStorageService().lastClickedItem * itemHeight,
          duration: const Duration(seconds: 1),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 데이터를 불러오는 핵심 함수
  Future<void> _fetchTopics() async {
    if (_isLoading) return; // 이미 로딩 중이면 중복 실행 방지

    setState(() {
      _isLoading = true;
    });

    final result = await _dbService.getTopicsPaginated(lastTopicDoc: _lastDocument);
    final List<Topic> topics = result['topics'];
    final DocumentSnapshot? lastDoc = result['lastDoc'];

    await imageService.cacheImageFiles(topics);

    if (mounted) {
      setState(() {
        _topics.addAll(topics); // 기존 리스트에 새로 불러온 데이터 추가
        _lastDocument = lastDoc;
        _isLoading = false;
        // 새로 불러온 데이터가 페이지당 개수보다 적으면 더 이상 데이터가 없는 것
        if (topics.length < DatabaseService.topicsPerPage) {
          _hasMore = false;
        }
      });
    }
  }

  double getItemHeight(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double itemHeight = (screenWidth - _axisSpacing * 3) / 2 + _axisSpacing;
    return itemHeight;
  }

  @override
  Widget build(BuildContext context) {
    List<Color> bgColors = [MyColors().navyLight, MyColors().mustardLight, MyColors().greenLight, MyColors().pink];
    List<Color> iconColors = [MyColors().navy, MyColors().mustard, MyColors().greenDark, MyColors().wine];

    return SafeArea(
        child: Scaffold(
      floatingActionButton: Visibility(
        visible: !userController.isPremium,
        child: GestureDetector(
          onTap: () {
            Get.to(() => PremiumPage());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.diamond_outlined, color: Colors.white, size: 30),
                const SizedBox(width: 5),
                Text(
                  'Get Premium',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                )
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Topic',
                    style: TextStyle(fontSize: 20.0, color: MyColors().purple, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Get.to(FeedbackPage());
                    },
                    icon: Icon(Icons.email_rounded, size: 35, color: MyColors().purple)),
                GestureDetector(
                  onTap: () {
                    Get.to(() => StreakPage());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: MyColors().mustardLight,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Obx(() {
                      if (userController.user.value == null) {
                        return CircularProgressIndicator();
                      }
                      return Row(
                        children: [
                          Image.asset(
                            userController.hasStudyToday ? 'assets/icon/podo.png' : 'assets/icon/podo_grey.png',
                            width: 25,
                            height: 25,
                          ),
                          Text(
                            'x ${userController.currentStreak.toString()}',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
              child: DottedLine(
                lineThickness: 3.0,
                dashColor: Colors.grey,
                dashRadius: 3.0,
                dashGapLength: 5.0,
              ),
            ),
            Expanded(
              child: GridView.builder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  itemCount: _topics.length + (_hasMore ? 1 : 0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                    crossAxisSpacing: _axisSpacing,
                    mainAxisSpacing: _axisSpacing,
                  ),
                  itemBuilder: (context, index) {
                    // 리스트의 마지막이고 더 불러올 데이터가 있다면 로딩 인디케이터 표시
                    if (index == _topics.length) {
                      // 로딩 인디케이터가 그리드 한 칸을 차지하도록 Container로 감쌈
                      return Center(child: CircularProgressIndicator());
                    }
                    final topic = _topics[index];

                    return InkWell(
                      onTap: () {
                        int clickedItem = index ~/ 2;
                        LocalStorageService().setLastClickedItem(clickedItem);
                        Get.to(() => WordListPage(topic, bgColors[index % 4], iconColors[index % 4]));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: bgColors[index % 4], borderRadius: BorderRadius.all(Radius.circular(10.0))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '$index',
                                        style: TextStyle(
                                            fontSize: 40.0, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 10.0),
                                    Hero(
                                      child: imageService.getCachedImage(topic.id, color: iconColors[index % 4]),
                                      tag: 'wordTitleImage${topic.id}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  children: [
                                    Text(
                                      topic.title,
                                      style: TextStyle(color: iconColors[index % 4], fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    ));
  }
}
