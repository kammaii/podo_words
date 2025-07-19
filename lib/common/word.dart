
class Word {

  String front;
  String back;
  String pronunciation;
  String audio;
  String image;

  int? wordId;
  bool isActive = true;
  bool isChecked = false;
  bool? shouldQUiz;


  Word(this.front, this.back, this.pronunciation, this.audio, this.image);

  Map<String, dynamic> toJson() => {
    'front' : front,
    'back' : back,
    'pronunciation' : pronunciation,
    'audio' : audio,
    'image' : image
  };

  Word.fromJson(Map<String, dynamic> json) :
        front = json['front'],
        back = json['back'],
        pronunciation = json['pronunciation'],
        audio = json['audio'],
        image = json['image'];
}