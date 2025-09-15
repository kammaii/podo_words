// 한글 분해 결과를 담을 데이터 클래스
class DecomposedHangul {
  final List<String> jamoList; // 분해된 자모 리스트 (예: ['ㄷ','ㅗ','ㄴ'])
  final List<int> decimalList; // 분해된 자모의 십진수 코드 리스트

  DecomposedHangul({required this.jamoList, required this.decimalList});
}

class HangulService {
  // 자모음 리스트를 클래스 내부에 상수로 보관
  static const List<String> choList = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"];
  static const List<String> jungList = ["ㅏ","ㅐ","ㅑ","ㅒ","ㅓ","ㅔ","ㅕ","ㅖ","ㅗ","ㅘ","ㅙ","ㅚ","ㅛ","ㅜ","ㅝ","ㅞ","ㅟ","ㅠ","ㅡ","ㅢ","ㅣ"];
  static const List<String> jongList = ["","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ","ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ","ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"];

  /// 한글 문자열을 자모 단위로 분해합니다.
  DecomposedHangul decompose(String text) {
    List<String> jamoList = [];
    List<int> decimalList = [];

    for (var rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (char == ' ' || char == '=' || char == '/') {
        jamoList.add(char);
        continue;
      }

      if (rune >= 44032 && rune <= 55203) { // 한글 음절 범위 확인
        final unicode = rune - 44032;
        final cho = unicode ~/ (21 * 28);
        final jung = (unicode % (21 * 28)) ~/ 28;
        final jong = unicode % 28;

        jamoList.add(choList[cho]);
        jamoList.add(jungList[jung]);
        jamoList.add(jongList[jong]);

        decimalList.add(cho);
        decimalList.add(jung);
        decimalList.add(jong);
      } else {
        jamoList.add(char);
      }
    }
    return DecomposedHangul(jamoList: jamoList, decimalList: decimalList);
  }

  /// 초/중/종성 코드로 한글 글자를 조합합니다.
  String assemble({required int cho, required int jung, int jong = 0}) {
    return String.fromCharCode((cho * 588 + jung * 28 + jong) + 44032);
  }
}