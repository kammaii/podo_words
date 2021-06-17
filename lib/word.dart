
class Word {

  String front;
  String back;
  String pronunciation;
  String audio;

  int? wordId;
  bool isActive = true;
  bool isChecked = false;


  Word(this.front, this.back, this.pronunciation, this.audio);

  Map<String, dynamic> toJson() => {
    'front' : front,
    'back' : back,
    'pronunciation' : pronunciation,
    'audio' : audio
  };

  Word.fromJson(Map<String, dynamic> json) :
        front = json['front'],
        back = json['back'],
        pronunciation = json['pronunciation'],
        audio = json['audio'];
}