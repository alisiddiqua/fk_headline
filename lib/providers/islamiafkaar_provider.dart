import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastItem {
  final String title;
  final String link;
  final String audioUrl;
  final String speakerName; // from <description> tag
  final String duration;    // from <itunes:duration> tag
  final String pubDate;
  final String? imageUrl;

  PodcastItem({
    required this.title,
    required this.link,
    required this.audioUrl,
    required this.speakerName,
    required this.duration,
    required this.pubDate,
    this.imageUrl,
  });
}

final islamiafkaarProvider = FutureProvider<List<PodcastItem>>((ref) async {
  final response = await http.get(Uri.parse('https://islamiafkaar.com/feed/podcast/'));

  if (response.statusCode == 200) {
    final document = XmlDocument.parse(response.body);
    final items = document.findAllElements('item');

    return items.map((node) {
      final title = node.findElements('title').first.innerText
          .replaceAll('&#8211;', '–')
          .replaceAll('&amp;', '&');
      final link = node.findElements('link').firstOrNull?.innerText ?? '';
      final pubDate = node.findElements('pubDate').firstOrNull?.innerText ?? '';

      // Speaker name is stored in the <description> tag (plain text in CDATA)
      final rawDescription = node.findElements('description').firstOrNull?.innerText ?? '';
      // Strip any HTML tags if present
      final speakerName = rawDescription.replaceAll(RegExp(r'<[^>]*>'), '').trim();

      // Duration from <itunes:duration>
      final duration = node.findAllElements('duration').firstOrNull?.innerText ?? '';

      // MP3 URL from <enclosure url="...">
      final enclosure = node.findElements('enclosure').firstOrNull;
      final audioUrl = enclosure?.getAttribute('url') ?? '';

      // Thumbnail from <itunes:image href="...">
      final itunesImage = node.findAllElements('image').firstOrNull;
      final imageUrl = itunesImage?.getAttribute('href');

      return PodcastItem(
        title: title,
        link: link,
        audioUrl: audioUrl,
        speakerName: speakerName,
        duration: duration,
        pubDate: pubDate,
        imageUrl: imageUrl,
      );
    }).toList();
  } else {
    throw Exception('Failed to load Islamiafkaar feed');
  }
});
