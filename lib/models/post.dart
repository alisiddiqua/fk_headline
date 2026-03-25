class WPPost {
  final int id;
  final String date;
  final String title;
  final String content;
  final String excerpt;
  final int featuredMediaId;
  final String? featuredMediaUrl;
  final String authorName;
  final String subHeadline;
  final String shortLink;

  WPPost({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.featuredMediaId,
    this.featuredMediaUrl,
    required this.authorName,
    required this.subHeadline,
    required this.shortLink,
  });

  factory WPPost.fromJson(Map<String, dynamic> json) {
    String parsedAuthor = '';
    if (json['_embedded'] is Map && json['_embedded']['author'] is List && json['_embedded']['author'].isNotEmpty) {
      if (json['_embedded']['author'][0] is Map) {
        parsedAuthor = json['_embedded']['author'][0]['name'] ?? '';
      }
    }

    String contentRaw = json['content'] is Map ? (json['content']['rendered'] ?? '') : '';
    String linkRaw = json['link']?.toString() ?? '';
    
    // Extract short URL from content via Regex
    String extractedShort = linkRaw;
    final RegExp regExp = RegExp(r'https://english\.fikrokhabar\.com/[a-zA-Z0-9]{4,7}(?=["<\s])');
    final match = regExp.firstMatch(contentRaw);
    if (match != null) {
      extractedShort = match.group(0)!;
    }

    // ACF Sub-headline (fallback to Excerpt)
    String sub = '';
    if (json['acf'] is Map) {
      sub = json['acf']['sub_headline'] ?? json['acf']['sub_heading'] ?? '';
    }
    if (sub.isEmpty) {
      sub = (json['excerpt'] is Map ? (json['excerpt']['rendered'] ?? '') : '').replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '').trim();
    }

    return WPPost(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      title: json['title'] is Map ? (json['title']['rendered'] ?? '') : '',
      content: contentRaw,
      excerpt: json['excerpt'] is Map ? (json['excerpt']['rendered'] ?? '') : '',
      featuredMediaId: json['featured_media'] ?? 0,
      featuredMediaUrl: json['featured_media_url'],
      authorName: parsedAuthor,
      subHeadline: sub,
      shortLink: extractedShort,
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
      'link': shortLink,
      '_embedded': {
        'author': [{'name': authorName}]
      },
      'acf': {
        'sub_headline': subHeadline
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
      subHeadline: subHeadline,
      shortLink: shortLink,
    );
  }
}
