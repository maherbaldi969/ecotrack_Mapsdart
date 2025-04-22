class Tour {
  final int id;
  final int wpPostId;
  final String title;
  final String description;
  final String locationPoint;
  final int duration;
  final String price;
  final String postTitle;
  final String postContent;

  Tour({
    required this.id,
    required this.wpPostId,
    required this.title,
    required this.description,
    required this.locationPoint,
    required this.duration,
    required this.price,
    required this.postTitle,
    required this.postContent,
  });

  factory Tour.fromMap(Map<String, dynamic> map) {
    return Tour(
      id: map['id'] ?? 0,
      wpPostId: map['wp_post_id'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      locationPoint: map['location_point'] ?? '',
      duration: map['duration'] ?? 0,
      price: map['price'] ?? '',
      postTitle: map['post_title'] ?? '',
      postContent: map['post_content'] ?? '',
    );
  }
}
