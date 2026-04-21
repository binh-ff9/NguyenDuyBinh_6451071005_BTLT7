class News {
  final int id;
  final String title;
  final String body;
  final int userId;
  final List<String> tags;
  final int views;
  final int reactions;

  News({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.tags,
    required this.views,
    required this.reactions,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as int,
      tags: List<String>.from(json['tags'] ?? []),
      views: json['views'] as int? ?? 0,
      reactions: (json['reactions'] is Map)
          ? ((json['reactions']['likes'] ?? 0) as int)
          : (json['reactions'] as int? ?? 0),
    );
  }
}
