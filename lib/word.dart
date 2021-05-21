
class Word {

  String front;
  String back;
  String image;
  //String pronunciation;
  //String audio;

  int wordId;
  bool isActive;
  bool isChecked = false;


  Word(this.front, this.back);

  Map<String, dynamic> toJson() => {
    'front' : front,
    'back' : back,
    'image' : image,
    //'pronunciation' : pronunciation,
    //'audio' : audio
  };

  Word.fromJson(Map<String, dynamic> json) :
        front = json['front'],
        back = json['back'],
        image = json['image'];
        //pronunciation = json['pronunciation'],
        //audio = json['audio'];
}