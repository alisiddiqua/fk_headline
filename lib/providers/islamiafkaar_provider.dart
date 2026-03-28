import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PodcastItem {
  final String title;
  final String link;
  final String audioUrl;
  final String description;
  final String pubDate;
  final String? imageUrl;

  PodcastItem({
    required this.title,
    required this.link,
    required this.audioUrl,
    required this.description,
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
      final title = node.findElements('title').first.innerText;
      final link = node.findElements('link').first.innerText;
      final description = node.findElements('description').first.innerText;
      final pubDate = node.findElements('pubDate').first.innerText;
      
      // Extract audio URL from <enclosure url="...">
      final enclosure = node.findElements('enclosure').firstOrNull;
      final audioUrl = enclosure?.getAttribute('url') ?? '';
      
      // Extract image from <itunes:image href="..."> or featured image
      final itunesImage = node.findElements('itunes:image').firstOrNull;
      final imageUrl = itunesImage?.getAttribute('href');

      return PodcastItem(
        title: title,
        link: link,
        audioUrl: audioUrl,
        description: description,
        pubDate: pubDate,
        imageUrl: imageUrl,
      );
    }).toList();
  } else {
    throw Exception('Failed to load Islamiafkaar feed');
  }
});
