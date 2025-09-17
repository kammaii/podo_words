import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:podo_words/learning/models/word.dart';
import 'package:http/http.dart' as http;


class AudioController {

  static final AudioController _instance = AudioController.init();

  factory AudioController() {
    return _instance;
  }

  final Map<String, String> _localAudioPaths = {}; // key: word.id, value: 로컬 파일 경로
  final AudioPlayer audioPlayer = AudioPlayer();

  /// [추가] 레슨에 필요한 모든 오디오 파일을 로컬에 다운로드하고 캐싱하는 함수
  Future<void> cacheAllAudioFiles(List<Word> words) async {
    // 1. 앱의 임시 저장 공간 경로를 가져옵니다.
    final tempDir = await getTemporaryDirectory();

    // 2. 다운로드할 파일들의 Future 리스트를 만듭니다.
    final List<Future<void>> downloadFutures = [];

    for (final word in words) {
      // 다운로드 작업을 Future로 정의합니다.
      final downloadTask = () async {
        try {
          // 로컬에 저장할 파일 경로를 정의합니다. (예: /.../temp/word_id.m4a)
          final localPath = 'audios/${tempDir.path}/${word.id}.m4a';
          final file = File(localPath);

          // 이미 파일이 존재하지 않으면 다운로드합니다.
          if (!await file.exists()) {
            final response = await http.get(Uri.parse(word.audio));
            if (response.statusCode == 200) {
              await file.writeAsBytes(response.bodyBytes);
            }
          }
          // 다운로드 성공/실패 여부와 관계없이 맵에 경로를 저장합니다.
          _localAudioPaths[word.id] = localPath;

        } catch (e) {
          debugPrint('오디오 캐싱 실패 (Word ID: ${word.id}): $e');
        }
      };
      downloadFutures.add(downloadTask());
    }

    // 3. 모든 다운로드 작업이 끝날 때까지 병렬로 실행하고 기다립니다.
    await Future.wait(downloadFutures);
  }

  /// [추가] 캐싱된 로컬 오디오 파일을 재생하는 함수
  Future<void> playWordAudio(Word word) async {
    // 마지막 카드일 경우
    if(word.audio.isEmpty) {
      return;
    }

    final localPath = _localAudioPaths[word.id];

    if (localPath != null && await File(localPath).exists()) {
      try {
        // 로컬 파일 경로로 오디오 재생
        await audioPlayer.setFilePath(localPath);
        audioPlayer.play();
      } catch (e) {
        debugPrint('로컬 오디오 재생 실패: $e');
      }
    } else {
      // (폴백) 만약 캐싱된 파일이 없다면 URL로 직접 스트리밍
      if (word.audio.isNotEmpty) {
        try {
          await audioPlayer.setUrl(word.audio);
          audioPlayer.play();
        } catch (e) {
          debugPrint('URL 오디오 재생 실패: $e');
        }
      }
    }
  }

  AudioController.init() {
    print('playAudio 초기화');
  }

  void playCorrect() async {
    await audioPlayer.setAsset('assets/audio/correct.mp3');
    audioPlayer.play();
  }

  void playWrong() async {
    await audioPlayer.setAsset('assets/audio/wrong.mp3');
    audioPlayer.play();
  }

  void playYay() async {
    await audioPlayer.setAsset('assets/audio/yay.mp3');
    audioPlayer.play();
  }
}