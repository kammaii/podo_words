class Topic {
  final String id;
  final int orderId;
  final String title;
  final String image;

  Topic({
    required this.id,
    required this.orderId,
    required this.title,
    required this.image,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      orderId: json['orderId'] as int,
      title: json['title'] as String,
      image: json['image'] as String,
    );
  }
}