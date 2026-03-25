class WPPost {
  final int id;
  final String date;
  final String title;
  final String content;
  final String excerpt;
  final int featuredMediaId;
  final String? featuredMediaUrl;
  final String authorName;

  WPPost({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.featuredMediaId,
    this.featuredMediaUrl,
    required this.authorName,
  });

  factory WPPost.fromJson(Map<String, dynamic> json) {
    String parsedAuthor = '';
    if (json['_embedded'] != null && json['_embedded']['author'] != null && json['_embedded']['author'].isNotEmpty) {
      parsedAuthor = json['_embedded']['author'][0]['name'] ?? '';
    }

    return WPPost(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      title: json['title']?['rendered'] ?? '',
      content: json['content']?['rendered'] ?? '',
      excerpt: json['excerpt']?['rendered'] ?? '',
      featuredMediaId: json['featured_media'] ?? 0,
      featuredMediaUrl: json['featured_media_url'],
      authorName: parsedAuthor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'title': {'rendered': title},
      'content': {'rendered': content},
      'excerpt': {'rendered': excerpt},
      'featured_media': featuredMediaId,
      'featured_media_url': featuredMediaUrl,
      '_embedded': {
        'author': [{'name': authorName}]
      }
    };
  }

  WPPost copyWith({String? featuredMediaUrl}) {
    return WPPost(
      id: id,
      date: date,
      title: title,
      content: content,
      excerpt: excerpt,
      featuredMediaId: featuredMediaId,
      featuredMediaUrl: featuredMediaUrl ?? this.featuredMediaUrl,
      authorName: authorName,
    );
  }
}
