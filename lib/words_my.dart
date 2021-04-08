
class MyWords {

  List<String> front = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N'];
  List<String> back = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n'];
  List<String> image;
  List<String> audio;
  List<bool> isActive;

  MyWords() {
    //todo: 저장된 단어를 앱 DB에서 가져오기
  }


  addMyWords(String front, String back, String image, String audio) {
    this.front.add(front);
    this.back.add(back);
    this.image.add(image);
    this.audio.add(audio);
    this.isActive.add(true);
  }

  deleteMyWords(int index) {
    this.front.removeAt(index);
    this.back.removeAt(index);
    this.image.removeAt(index);
    this.audio.removeAt(index);
    this.isActive.removeAt(index);
  }

  setIsActiveMyWords(int index, bool isActive) {
    this.isActive[index] = isActive;
  }
}