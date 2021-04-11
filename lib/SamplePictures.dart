class SamplePictures {

  List<String> samplePictures = [];

  SamplePictures(int length) {
    setPictures(length);
  }

  void setPictures(int length) {
    for(int i=0; i<length; i++) {
      this.samplePictures.add('https://picsum.photos/300/300?image=${i+50}');
    }
  }

  List<String> getSamplePictures() {
    return samplePictures;
  }
}