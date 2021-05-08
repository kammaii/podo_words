
class MyWord {

  String front;
  String back;
  String image;
  String audio;

  MyWord() {
    //todo: 저장된 단어를 앱 DB에서 가져오기
    //front = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N'];
    //back = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n'];
  }

  Map<String, String> toJson() => {
    'front' : front,
    'back' : back,
    'image' : image,
    'audio' : audio
  };

  MyWord.fromJson(Map<String, String> json) :
        front = json['front'],
        back = json['back'],
        image = json['image'],
        audio = json['audio'];

/*
  addMyWords(String front, String back, String image, String audio) {
    this.front.add(front);
    this.back.add(back);
    this.image.add(image);
    this.audio.add(audio);
  }

  deleteMyWords(int index) {
    this.front.removeAt(index);
    this.back.removeAt(index);
    this.image.removeAt(index);
    this.audio.removeAt(index);
  }

  getActiveMyWords(List<bool> isActive) {
    for(int i=0; i<front.length; i++) {
      if(!isActive[i]) {
        removeWord(i);
      }
    }
  }

  getInActiveMyWords(List<bool> isActive) {
    for(int i=0; i<front.length; i++) {
      if(isActive[i]) {
        removeWord(i);
      }
    }
  }

  removeWord(int index) {
    front.removeAt(index);
    back.removeAt(index);
    //image.removeAt(index);
    //audio.removeAt(index);
  }


 */

}