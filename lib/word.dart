
class Word {

  String front;
  String back;
  String image;
  //String pronunciation;
  //String audio;

  Word(this.front, this.back, this.image);

  Map<String, String> toJson() => {
    'front' : front,
    'back' : back,
    'image' : image,
    //'pronunciation' : pronunciation,
    //'audio' : audio
  };

  Word.fromJson(Map<String, String> json) :
        front = json['front'],
        back = json['back'],
        image = json['image'];
        //pronunciation = json['pronunciation'],
        //audio = json['audio'];
}