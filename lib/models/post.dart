class WPPost {
  final int id;
  final String date;
  final String title;
  final String content;
  final String excerpt;
  final int featuredMediaId;
  final String? featuredMediaUrl;
  final String authorName;
  final String subHeadline = ''; // Deprecated, removed per user request
  final String shortLink;
  final String pdfLink;

  WPPost({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.featuredMediaId,
    this.featuredMediaUrl,
    required this.authorName,
    required this.shortLink,
    required this.pdfLink,
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

    // Extract PDF URL if Magazine Plugin is used
    String extractedPdf = '';
    final RegExp pdfRegExp = RegExp(r'href="([^"]+\.pdf[^"]*)"');
    final pdfMatch = pdfRegExp.firstMatch(contentRaw);
    if (pdfMatch != null) {
      extractedPdf = pdfMatch.group(1)!;
    } else {
       final RegExp iframeRegExp = RegExp(r'src="([^"]+\.pdf[^"]*)"');
       final iframeMatch = iframeRegExp.firstMatch(contentRaw);
       if (iframeMatch != null) extractedPdf = iframeMatch.group(1)!;
    }

    // Automatic fallback to first image in article for Gallery posts
    String? mediaUrl = json['featured_media_url'];
    if (mediaUrl == null || mediaUrl.isEmpty) {
        final RegExp imgRegExp = RegExp(r'<img[^>]+src="([^">]+)"');
        final imgMatch = imgRegExp.firstMatch(contentRaw.replaceAll('data-src-fg=', 'src='));
        if (imgMatch != null) {
            mediaUrl = imgMatch.group(1)!;
        }
    }

    return WPPost(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      title: json['title'] is Map ? (json['title']['rendered'] ?? '') : '',
      content: contentRaw,
      excerpt: json['excerpt'] is Map ? (json['excerpt']['rendered'] ?? '') : '',
      featuredMediaId: json['featured_media'] ?? 0,
      featuredMediaUrl: mediaUrl,
      authorName: parsedAuthor,
      shortLink: extractedShort,
      pdfLink: extractedPdf,
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
      shortLink: shortLink,
      pdfLink: pdfLink,
    );
  }
}
