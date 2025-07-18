import 'package:just_audio/just_audio.dart';

class PlayAudio {

  static final PlayAudio _instance = PlayAudio.init();

  factory PlayAudio() {
    return _instance;
  }

  AudioPlayer player = AudioPlayer();

  PlayAudio.init() {
    print('playAudio 초기화');
  }

  void playCorrect() async {
    await player.setAsset('assets/audio/correct.mp3');
    await player.setVolume(0.1);
    player.play();
  }

  void playWrong() async {
    await player.setAsset('assets/audio/wrong.mp3');
    await player.setVolume(0.1);
    player.play();
  }

  void playYay() async {
    await player.setAsset('assets/audio/yay.mp3');
    await player.setVolume(0.1);
    player.play();
  }

  void playWord(String audio) async {
    await player.setAsset('assets/audio/$audio');
    await player.setVolume(1);
    player.play();
  }
}