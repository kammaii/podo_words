import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:podo_words/learning/controllers/ads_controller.dart';
import 'package:podo_words/database/local_storage_service.dart';
import 'package:podo_words/database/database_service.dart';
import 'package:podo_words/common/my_colors.dart';
import 'package:podo_words/learning/models/topic.dart';
import 'package:podo_words/learning/models/word.dart';
import 'package:podo_words/learning/pages/learning_page.dart';
import 'package:podo_words/premium/premium_page.dart';
import 'package:podo_words/user/user_controller.dart';
import '../widgets/show_snack_bar.dart';
import '../widgets/word_list.dart';

class WordListPage extends StatefulWidget {
  final Topic topic;
  final Color bgColor;
  final Color iconColor;

  WordListPage(this.topic, this.bgColor, this.iconColor);

  @override
  WordListPageState createState() => WordListPageState();
}

class WordListPageState extends State<WordListPage> {
  ScrollController _scrollController = new ScrollController();
  double _sliverAppBarHeight = 200.0;
  double _sliverAppBarMinimumHeight = 60.0;
  double sliverAppBarStretchOffset = 100.0;

  int activeWordCount = 0;
  final DatabaseService _dbService = DatabaseService();
  late final Future<List<Word>> _wordsFuture;

  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() => setState(() {}));
    _wordsFuture = _dbService.getWordsForTopic(widget.topic.id);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _runLesson({required List<Word> words, required bool shouldShowAds}) {
    List<Word> activeWords = words.where((word) => word.isActive).toList();
    Get.to(() => LearningPage(), arguments: {
      'shouldShowAds': shouldShowAds,
      'words': activeWords,
    });
  }

  void _showDialog({required List<Word> words}) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        content: Text(
          'Would you like to watch an ad to unlock this lesson?',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: MyColors().purple),
                  onPressed: () {
                    Get.back();
                    AdsController().showRewardAdAndStartLesson(() {
                      _runLesson(words: words, shouldShowAds: true);
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text('Yes', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: TextButton(
              onPressed: () {
                Get.to(PremiumPage());
              },
              child: Text('Explore Premium', style: TextStyle(color: MyColors().purple)),
            ),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Word>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          // 로딩 중일 때
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: widget.bgColor,
              body: const Center(child: CircularProgressIndicator()),
            );
          }
          // 에러 발생 시
          if (snapshot.hasError) {
            return Scaffold(
              backgroundColor: widget.bgColor,
              appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
              body: Center(child: Text('단어를 불러오는 데 실패했습니다: ${snapshot.error}')),
            );
          }
          // 데이터가 없을 때
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Scaffold(
              backgroundColor: widget.bgColor,
              appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
              body: const Center(child: Text('이 주제에는 단어가 없습니다.')),
            );
          }

          final List<Word> words = snapshot.data!;

          double topMargin = _sliverAppBarHeight - 30.0;
          double topMarginPlayBtn = _sliverAppBarHeight - 20.0;

          if (_scrollController.hasClients) {
            if (_sliverAppBarHeight - _scrollController.offset > _sliverAppBarMinimumHeight) {
              topMargin -= _scrollController.offset;
              topMarginPlayBtn -= _scrollController.offset;
            } else {
              topMargin = -100.0;
              topMarginPlayBtn = 5.0;
            }
          }

          return Scaffold(
            body: SafeArea(
              child: Obx(() {
                final Set<String> inactiveWordIds = userController.inactiveWordIds;
                final int activeWordCount = words.where((w) => !inactiveWordIds.contains(w.id)).length;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomScrollView(
                      physics: BouncingScrollPhysics(),
                      controller: _scrollController,
                      slivers: [
                        _sliverAppBar(),
                        _sliverList(words, inactiveWordIds),
                      ],
                    ),
                    Positioned(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      top: topMargin,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 30.0),
                        padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: widget.iconColor,
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(color: Colors.white, fontSize: 17.0),
                                ),
                                Text(
                                  words.length.toString(),
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 40.0,
                            ),
                            Column(
                              children: [
                                Text(
                                  'Active',
                                  style: TextStyle(color: Colors.white, fontSize: 17.0),
                                ),
                                Text(
                                  activeWordCount.toString(),
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: topMarginPlayBtn,
                      right: 60.0,
                      child: FloatingActionButton(
                        elevation: 10,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: widget.iconColor,
                          size: 50.0,
                        ),
                        onPressed: () {
                          if (activeWordCount >= 4) {
                            if (!LocalStorageService().isPremiumUser && LocalStorageService().myWords.isNotEmpty) {
                              print('무료 유저');
                              if (kReleaseMode) {
                                _showDialog(words: words);
                              } else {
                                _runLesson(words: words, shouldShowAds: false);
                              }
                            } else {
                              print('광고 대상 아님');
                              _runLesson(words: words, shouldShowAds: false);
                            }
                          } else {
                            ShowSnackBar().getSnackBar(context, 'It needs more than 4 words to start learning.');
                          }
                        },
                      ),
                    )
                  ],
                );
              }
          )
            ),
          );
        });
  }

  Widget _wordTitle() {
    return FlexibleSpaceBar(
      background: Stack(
        children: [
          Positioned(
            child: Hero(
                tag: 'wordTitleImage${widget.topic.orderId}',
                child: Image.memory(
                  base64Decode(widget.topic.image),
                  width: 250.0,
                  color: Colors.white,
                )),
            bottom: -50.0,
            right: -50.0,
          )
        ],
      ),
      stretchModes: [StretchMode.zoomBackground, StretchMode.fadeTitle, StretchMode.blurBackground],
    );
  }

  _sliverAppBar() {
    return SliverAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_rounded),
        color: widget.iconColor,
        onPressed: () {
          Get.back();
        },
      ),
      backgroundColor: widget.bgColor,
      expandedHeight: _sliverAppBarHeight,
      pinned: true,
      stretch: true,
      title: Text(
        widget.topic.title,
        style: TextStyle(
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
          color: widget.iconColor,
        ),
      ),
      flexibleSpace: _wordTitle(),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(10.0),
        child: Text(''),
      ),
    );
  }

  _sliverList(List<Word> words, Set<String> inactiveWordIds) {
    return SliverPadding(
      padding: EdgeInsets.only(top: 60.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            Word word = words[index];
            bool isActive = !inactiveWordIds.contains(word.id);
            if (index == 0) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
                    child: Text('Swipe left/right to pick a word to learn',
                        style: TextStyle(color: widget.iconColor)),
                  ),
                  WordList(word: word, isActive: isActive, isDeleteMode: false, fontColor: widget.iconColor),
                ],
              );
            } else {
              return WordList(word: word, isActive: isActive, isDeleteMode: false, fontColor: widget.iconColor);
            }
          },
          childCount: words.length,
        ),
      ),
    );
  }
}
