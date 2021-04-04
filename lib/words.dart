
class Words {

  List<String> title = [];

  Words() {
    setTitle();
  }

  void setTitle() {
    for(int i=0; i<20; i++) {
      title.add('title$i');
    }
  }

  List<String> getTitle() {
    return title;
  }
}